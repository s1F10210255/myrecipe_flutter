import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class HelloChatgpt extends StatefulWidget {
  const HelloChatgpt({Key? key}) : super(key: key);

  @override
  _HelloChatgptState createState() => _HelloChatgptState();
}

class _HelloChatgptState extends State<HelloChatgpt> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(minutes: 60), (Timer timer) => _getGreeting());
  }

  Future<void> _getGreeting() async {
    final String endpoint = 'https://api.openai.iniad.org/api/v1/chat/completions';
    final String apiKey = 'cd43qN-dzvcHSlK8aLf0v0xzRymCG09hHYSdBAmcNGOD1Y_-Wqt49APDXsytEeQS_5Z_Fkj1y19fNf7PdaujI4Q';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    var now = DateTime.now();
    var currentHour = now.hour;
    String greeting;
    if (currentHour < 12) {
      greeting = 'おはようございます';
    } else if (currentHour < 17) {
      greeting = 'こんにちは';
    } else {
      greeting = 'こんばんは';
    }

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'あなたは適切な時間に応じた挨拶と冗談を作成するのが得意で優秀な料理制作アシスタントをする優秀なAIです。現在の時間は ' + currentHour.toString() + ' 時です。' + greeting + '、そして面白い冗談を教えてください。 ',
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
    return Container();
  }
}