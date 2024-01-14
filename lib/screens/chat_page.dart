import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_im_list/core/chat_controller.dart';
import 'package:flutter_im_list/models/message_model.dart';
import 'package:flutter_im_list/widget/chat_list_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CharacterChatPage extends StatefulWidget {
  final String characterName;
  final String avatarUrl;

  const CharacterChatPage({Key? key, required this.characterName, required this.avatarUrl}) : super(key: key);

  @override
  _CharacterChatPageState createState() => _CharacterChatPageState();
}

class _CharacterChatPageState extends State<CharacterChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  late ChatController _chatController;
  List<DateTime> _selectedDates = []; // 選択された日付を保持するリスト

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(
      initialMessageList: _messages,
      timePellet: 60,
      scrollController: _scrollController,
    );
  }


  Future<void> _sendMessage(String text) async {
    final String endpoint = 'https://api.openai.iniad.org/api/v1/chat/completions';
    final String apiKey = 'UeOuO6C3PXFbiJDxM68LpE94iE9R3SuoFCQtmimdM9_wd8S-FAwRlAKzjNqNvWneji161chF5LpBDI7GtHZS2YQ';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    String characterContext = _getCharacterContext(widget.characterName);

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'system', 'content': characterContext},
        {'role': 'user', 'content': text},
      ],
    });

    final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final String reply = data['choices'][0]['message']['content'].trim();
      setState(() {
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch,
          content: text,
          ownerType: OwnerType.sender,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          ownerName: 'あなた',
        ));
        _messages.insert(_messages.length - 1, MessageModel(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          content: reply,
          ownerType: OwnerType.receiver,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          ownerName: widget.characterName,
        ));
      });
    } else {
      print('Error: ${response.body}');
    }
  }

  String _getCharacterContext(String characterName) {
    switch (characterName) {
      case "AI 栄養士":
        return 'あなたはAI栄養士です。栄養に関するアドバイスを提供してください。';
      case "ボディービルダー":
        return 'あなたはマッチです。筋肉王を目指しています。';
      case "坂本龍馬":
        return 'あなたは坂本龍馬です。なりきって答えて下さい。よくわからないことを聞かれても予想して書いて下さい。';
      case "マリー・アントワネット":
        return 'あなたはマリー・アントワネットです。フランス革命の時代の女王です。';
      case "陽気なインド人":
        return 'あなたは陽気なインド人です。インド文化について話してください。';
      default:
        return 'あなたはアシスタントです。';
    }
  }


  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("日付を選択"),
        content: Container(
          height: 400,
          width: double.maxFinite,
          child: CalendarCarousel(
            onDayPressed: (DateTime date, List<dynamic> events) {
              setState(() {
                if (_selectedDates.contains(date)) {
                  _selectedDates.remove(date);
                } else {
                  _selectedDates.add(date);
                }
              });
            },
            // 選択された日付を視覚的に強調表示するためのロジック
            customDayBuilder: (
                bool isSelectable,
                int index,
                bool isSelectedDay,
                bool isToday,
                bool isPrevMonthDay,
                TextStyle textStyle,
                bool isNextMonthDay,
                bool isThisMonthDay,
                DateTime day,
                ) {
              if (_selectedDates.contains(day)) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              } else {
                return null;
              }
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              _fetchAndSendData(_selectedDates); // 選択した日付を処理する
            },
          ),
        ],
      ),
    );
  }

  void _fetchAndSendData(List<DateTime> dates) async {
    var formattedDates = dates
        .map((date) => date.toIso8601String().split('T')[0])
        .toList();

    String? userId = getCurrentUserUID();
    print('Current User ID: $userId');

    final String endpoint = 'https://asia-northeast1-chatgptrecipegenerator.cloudfunctions.net/chat_carender';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'userId': userId,
      'characterName': widget.characterName,
      'dates': formattedDates,
    });

    print('Sending request with body: $body');

    final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Data sent successfully');

      // 応答データの解析
      final responseData = jsonDecode(response.body);

      // '栄養士からの評価' キーを確認
      if (responseData.containsKey('栄養士からの評価')) {
        var nutritionistEvaluation = responseData['栄養士からの評価'];
        var date = nutritionistEvaluation['日付'];
        var content = nutritionistEvaluation['内容'];

        // 不要なエスケープシーケンスをリアルな改行に置き換える
        var contentFormatted = content.replaceAll(r'\n', '\n');

        String chatGptResponse = "日付: $date\n内容:\n$contentFormatted";

        // チャットリストに応答を表示
        setState(() {
          _messages.add(MessageModel(
            id: DateTime.now().millisecondsSinceEpoch,
            content: chatGptResponse,
            ownerType: OwnerType.receiver,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            ownerName: 'システム',
          ));
        });
      } else {
        print('応答に "栄養士からの評価" キーが含まれていません: ${response.body}');
      }
    } else {
      print('Error: ${response.body}');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.characterName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showCalendarDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              chatController: _chatController,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // CircleAvatarの周りに余白を追加
                Padding(
                  padding: const EdgeInsets.all(8.0), // ここで余白を調整します
                  child: CircleAvatar(
                    radius: 40, // ここで半径を調整します
                    backgroundImage: AssetImage(widget.avatarUrl),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            _sendMessage(_controller.text);
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        _sendMessage(text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
