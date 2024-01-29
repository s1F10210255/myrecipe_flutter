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

  bool _isLoading = false;


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
    final String apiKey = 'hWiSFsRT2ctgrafvYEyQxHFEq0x3wKdE2fwCm_vExpMK0jxt55rLwFqeC63s4bZ5kV4y6hqMYwP07ExorqQ-4Yw';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    setState(() {
      _isLoading = true; // ローディング開始
    });

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
      setState(() {
        _isLoading = false; // ローディング終了
      });
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
        return 'あなたはAI栄養士です。栄養に関するアドバイスを提供してください。聞かれた質問に対しては常に栄養価の観点を考慮して健康的な食生活になるようにアドバイスしてください。また、アドバイスに加えて具体的な献立を提供してください。';
      case "ボディービルダー":
        return 'あなたはマッチです。筋肉王を目指しています。筋肉の作り方、ダイエット方法などに詳しいです。プロテインが好きです。なりきってください';
      case "坂本龍馬":
        return 'あなたは日本の歴史上の偉人、坂本龍馬です。江戸時代の視点から、坂本龍馬の知識と経験に基づいて答えてください。質問に対する回答は、まるで坂本龍馬自身が話しているかのように表現してください。常に過去の時代の視点と知識を用いてください。';
      case "マリー・アントワネット":
        return 'あなたはマリーアントワネット、フランス革命前夜のフランス王妃です。オーストリアの皇女として生まれ、若くしてルイ16世の妃となりました。あなたの生活は華やかさと贅沢に満ちており、とにかく贅沢で常に高級な食べ物や物品を使っていました。';
      case "陽気なインド人":
        return 'あなたは陽気なインド人です。インド文化について話してください。食生活について問われたらインド由来の食べ物に関して答えてください。また、口調は陽気なイメージとなるようにラフに答えてください。また、インド人なのでカタコトな日本語を表現するためにたまにカタカナを使用してください。';
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

    setState(() {
      _isLoading = true; // ローディング開始
    });

    final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Data sent successfully');
      setState(() {
        _isLoading = false; // ローディング終了
      });

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
      body: Stack(
        children: [
          Column(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 40,
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
          _isLoading ? Center(child: CircularProgressIndicator()) : Container(),
        ],
      ),
    );
  }
}

