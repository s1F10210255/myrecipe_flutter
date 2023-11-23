import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:g14/servise/service.dart';


class RecipeGenerator extends StatefulWidget {
  final String videoId;

  RecipeGenerator({required this.videoId});

  @override
  _RecipeGeneratorState createState() => _RecipeGeneratorState();
}

class _RecipeGeneratorState extends State<RecipeGenerator> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  late YoutubePlayerController _controller;
  String _subtitles = "";
  String? _captionText;
  String? _accessToken;


  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  Future<bool> isTokenValid(String? accessToken) async {
    if (accessToken == null) {
      return false;
    }
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$accessToken'),
    );
    return response.statusCode == 200;
  }


  Future<String?> _fetchAccessToken() async {
    // 既存のトークンが有効であるかチェック
    if (_accessToken != null && await isTokenValid(_accessToken)) {
      print("Existing access token is still valid.");
      return _accessToken;
    }

    AuthService authService = AuthService();
    _accessToken = await authService.ensureValidToken();
    print("Access Token: $_accessToken");
    return _accessToken;
  }




  Future<String?> getCaptionId(String videoId, String accessToken) async {
    final String endpoint = "https://www.googleapis.com/youtube/v3/captions";
    final Uri uri = Uri.parse(endpoint).replace(queryParameters: {
      'part': 'id',
      'videoId': videoId,
    });

    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    final response = await http.get(uri, headers: headers);
    print("Response status for getCaptionId: ${response.statusCode}");
    print("Response body for getCaptionId: ${response.body}");


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return data['items'][0]['id'];
      }
    }

    return null;
  }


  Future<String?> getCaptionData(String captionId) async {
    final String endpoint = "https://www.googleapis.com/youtube/v3/captions/$captionId";
    final Uri uri = Uri.parse(endpoint).replace(queryParameters: {
      'tfmt': 'srt',
    });

    final headers = {
      'Authorization': 'Bearer $_accessToken',
    };

    final response = await http.get(uri, headers: headers);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("Error fetching caption data: ${response.body}");
      return null;
    }
  }



  Future<void> fetchAndPrintSubtitles() async {
    String? currentToken = await _fetchAccessToken();
    if (currentToken == null) {
      print("Access token is null");
      return;
    }
    String? captionId = await getCaptionId(widget.videoId, currentToken);
    if (captionId == null) {
      print("Failed to fetch caption ID");
      return;
    }

    String? captionData = await getCaptionData(captionId);
    if (captionData == null) {
      print("Failed to fetch caption data");
      return;
    }

    print("Fetched Subtitles: \n$captionData");
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Generator'),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
          ElevatedButton(
            onPressed: fetchAndPrintSubtitles,
            child: Text('Fetch and Print Captions'),
          ),
          FutureBuilder<String?>(
            future: _fetchAccessToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Text('Token: ${snapshot.data}');
                } else {
                  return Text('Error fetching token');
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          if (_captionText != null) Text(_captionText!),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoId,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = _textController.text;
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}