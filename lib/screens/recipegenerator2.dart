import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class RecipeGenerator2 extends StatefulWidget {
  final String videoId;

  RecipeGenerator2({required this.videoId});

  @override
  _RecipeGenerator2State createState() => _RecipeGenerator2State();
}

class _RecipeGenerator2State extends State<RecipeGenerator2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _responseText = "";
  final TextEditingController _questionController = TextEditingController();

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    _fetchSubtitles();
  }

  Future<void> _fetchSubtitles() async {
    try {
      String? userId = getCurrentUserUID();
      if (userId == null) {
        setState(() {
          _responseText = 'ユーザーIDが見つかりません。';
        });
        return;
      }

      final functionUrl = 'https://asia-northeast1-chatgptrecipegenerator.cloudfunctions.net/caption_firestoresave?video_id=${widget.videoId}&user_id=$userId';
      final response = await http.get(Uri.parse(functionUrl));

      if (response.statusCode == 200) {
        _sendQuestionToChatGPT(userId);
      } else {
        setState(() {
          _responseText = "Error fetching subtitles: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseText = "Error fetching subtitles: $e";
      });
    }
  }

  Future<void> _sendQuestionToChatGPT(String userId) async {
    final functionUrl = 'https://asia-northeast1-chatgptrecipegenerator.cloudfunctions.net/chatgpt_generate?video_id=${widget.videoId}&user_id=$userId';
    final response = await http.get(Uri.parse(functionUrl));

    if (response.statusCode == 200) {
      setState(() {
        _responseText = _parseResponse(response.body);
      });
    } else {
      setState(() {
        _responseText = "Error communicating with ChatGPT: ${response.body}";
      });
    }
  }

  String _parseResponse(String responseBody) {
    try {
      return json.decode(responseBody);
    } catch (e) {
      // JSONのパースに失敗した場合は、元のレスポンスボディを返す
      return responseBody;
    }
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
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: '料理の鉄人に質問',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () => _sendQuestionToChatGPT(getCurrentUserUID() ?? ""),
              child: Text('質問を送信'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_responseText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
