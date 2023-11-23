import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ChatGPTrecipePage extends StatefulWidget {
  const ChatGPTrecipePage({Key? key}) : super(key: key);

  @override
  _ChatGPTrecipePageState createState() => _ChatGPTrecipePageState();
}

class _ChatGPTrecipePageState extends State<ChatGPTrecipePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  Future<void> _sendMessage(String text) async {
    final String endpoint = 'https://api.openai.iniad.org/api/v1/chat/completions';
    final String apiKey = 'cd43qN-dzvcHSlK8aLf0v0xzRymCG09hHYSdBAmcNGOD1Y_-Wqt49APDXsytEeQS_5Z_Fkj1y19fNf7PdaujI4Q';  // Be cautious about sharing your API key in public forums.

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': '日本語で対応してください。あなたは料理のできる優秀なアシスタントです。以下にyoutubeの字幕を提供するので内容を理解し、材料の一覧を見やすく表示しその下に、その料理の工程を要約してください。そしてuserから対応を求められた時は対応してください。',
        },
        {
          'role': 'user',
          'content': text,
        },
      ],
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null &&
          data.containsKey('choices') &&
          data['choices'] is List &&
          data['choices'].isNotEmpty &&
          data['choices'][0] is Map &&
          data['choices'][0].containsKey('message') &&
          data['choices'][0]['message'] is Map &&
          data['choices'][0]['message'].containsKey('content') &&
          data['choices'][0]['message']['content'] is String) {
        final String reply = data['choices'][0]['message']['content'].trim();
        setState(() {
          _messages.add('User: $text');
          _messages.add('GPT: $reply');
        });
      } else {
        print('Unexpected response format');
      }
    } else {
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your widget tree here
    return Container();  // placeholder for now
  }
}
