import 'package:flutter/material.dart';
import 'package:g14/widget/CustomYoutubePlayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:fan_floating_menu/fan_floating_menu.dart';



class RecipeGenerator extends StatefulWidget {
  final String videoId;

  RecipeGenerator({required this.videoId});

  @override
  _RecipeGeneratorState createState() => _RecipeGeneratorState();
}

class _RecipeGeneratorState extends State<RecipeGenerator> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _responseText = "";
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;
  late YoutubePlayerController _controller;

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
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
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent, // AppBarを透明にする
            elevation: 0, // 影をなくす
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black), // アイコンの色を変更
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('', style: TextStyle(color: Colors.black)), // タイトルを空にする
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                player,
                // プレイヤーの下に続くウィジェット
                SizedBox(height: 20),
                _isLoading
                    ? Expanded(
                    child: Center(child: CircularProgressIndicator()))
                    : Expanded(
                    child: SingleChildScrollView(child: Text(_responseText))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // これで右寄りに配置されます
                  children: [
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.8, // 画面幅の50%のサイズに設定
                      padding: EdgeInsets.symmetric(
                          horizontal: 20),
                      child: TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          labelText: '料理の鉄人に質問',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
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

          // FanFloatingMenu を追加
          floatingActionButton: Padding(
            padding: EdgeInsets.only(left: 20), // 右に余白を追加
            child: FanFloatingMenu(
              menuItems: [
                FanMenuItem(
                    onTap: () {
                      // ここにアクションを追加
                    },
                    icon: Icons.edit_rounded,
                    title: 'テキストを編集'
                ),
                FanMenuItem(
                    onTap: () {
                      // ここにアクションを追加
                    },
                    icon: Icons.save_rounded,
                    title: 'ノートを保存'
                ),
                FanMenuItem(
                    onTap: () {
                      // ここにアクションを追加
                    },
                    icon: Icons.send_rounded,
                    title: '画像を送信'
                ),
              ],
              fanMenuDirection: FanMenuDirection.ltr,
              expandItemsCurve: Curves.easeInOutBack,
              toggleButtonWidget: null,
              // または好きなウィジェット
              toggleButtonIconColor: Colors.white,
              toggleButtonColor: Colors.pink,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation
              .endFloat, // FABの位置を右側に設定
        );
      },
    );
  }
}