import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:g14/widget/YoutubeVideoPlayer.dart';


class RecipeGenerator2 extends StatefulWidget {
  final String videoId;

  RecipeGenerator2({required this.videoId});

  @override
  _RecipeGenerator2State createState() => _RecipeGenerator2State();
}

class _RecipeGenerator2State extends State<RecipeGenerator2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _responseText = "";
  late YoutubePlayerController _youtubePlayerController;  // YouTubeプレイヤーコントローラの追加
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    _youtubePlayerController = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
    _saveSubtitles();
  }

  Future<void> _saveSubtitles() async {
    String? userId = getCurrentUserUID();
    setState(() {
      _isLoading = false;
      _responseText = "準備中... しばらくお待ちください。";
    });
    if (userId == null) {
      setState(() {
        _responseText = 'ユーザーIDが見つかりません。';
      });
      return;
    }

    final captionUrl = 'https://asia-northeast1-chatgptrecipegenerator.cloudfunctions.net/caption_firestoresave?video_id=${widget
        .videoId}&user_id=$userId';
    final captionResponse = await http.get(Uri.parse(captionUrl));

    if (captionResponse.statusCode == 200) {
      _generateSummary(userId);
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _responseText =
        "Error in caption_firestoresave: ${captionResponse.body}";
      });
    }
  }

  Future<void> _generateSummary(String userId) async {
    final generateUrl = 'https://asia-northeast1-chatgptrecipegenerator.cloudfunctions.net/chatgpt_generate?video_id=${widget
        .videoId}&user_id=$userId';
    final generateResponse = await http.get(Uri.parse(generateUrl));

    if (generateResponse.statusCode == 200) {
      setState(() {
        _isLoading = false;
        _responseText = "要約が完了しました。質問を送信してください。";
      });
    } else {
      setState(() {
        _isLoading = false;
        _responseText = "Error in chatgpt_generate: ${generateResponse.body}";
      });
    }
  }

  Future<void> _interactWithChatGPT(String userId, String videoId,
      String userQuestion) async {
    setState(() {
      _isLoading = true;
    });

    final chatUrl = 'https://asia-northeast1-chatgptrecipegenerator.cloudfunctions.net/chatgptresponce';
    final response = await http.post(
      Uri.parse(chatUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'video_id': videoId,
        'user_input': userQuestion,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _responseText = responseData['choices'][0]['message']['content'];
      _questionController.clear();
    } else {
      _responseText = "Error communicating with ChatGPT: ${response.body}";
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChatGPTとの連携')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            YoutubePlayer(
              controller: _youtubePlayerController,
              aspectRatio: 16 / 9,

            ),
            SizedBox(height: 20),
            _isLoading
                ? Expanded(child: Center(
                child: CircularProgressIndicator()))
                : Expanded(
                child: SingleChildScrollView(child: Text(_responseText))),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: '料理の鉄人に質問',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  _interactWithChatGPT(
                      getCurrentUserUID() ?? "", widget.videoId,
                      _questionController.text),
              child: Text('質問を送信'),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _youtubePlayerController.close();
    super.dispose();
  }
}

