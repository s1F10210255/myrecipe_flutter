import 'package:flutter/material.dart';
import 'package:g14/widget/CustomYoutubePlayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:fan_floating_menu/fan_floating_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:g14/widget/AdWidget.dart';
import 'package:g14/widget/rivePop.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';



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
  bool _isMenuOpen = false;

  late AdInterstitialWidget adInterstitialWidget;



  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    adInterstitialWidget = AdInterstitialWidget();
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

  Future<void> likeVideo(String userId, String videoId) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('likevideo')
        .doc(videoId) // ビデオIDをドキュメントIDとして使用
        .set({
      'likedAt': FieldValue.serverTimestamp(), // 現在のタイムスタンプを保存
      'videoId': videoId // ビデオIDも保存
    })
        .then((value) => print("Video Liked"))
        .catchError((error) => print("Failed to like video: $error"));
  }

  Future<void> saveVideoToCalendar(String userId, String videoId) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 現在の日付をフォーマット
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Calendar_video')
        .doc(formattedDate); // フォーマットされた日付をドキュメントIDとして使用

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {'videoIds': [videoId]});
      } else {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic> ?? {};
        List<dynamic> videoIds = data.containsKey('videoIds') ? List.from(data['videoIds']) : [];
        videoIds.add(videoId);
        transaction.update(docRef, {'videoIds': videoIds});
      }
    }).then((value) => print("Video Saved to Calendar"))
        .catchError((error) => print("Failed to save video: $error"));
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
      adInterstitialWidget.showAd();
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

  void _showRiveAnimation(BuildContext context, String assetName) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: RiveAnimationWidget(assetName: assetName),
      ),
    );

    // 1.5秒後にダイアログを閉じる
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.of(context).pop(); // ダイアログを閉じる
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
                AdInterstitialWidget(),
                SizedBox(height: 20),
                _isLoading
                    ? Expanded(
                    child: Center(child: CircularProgressIndicator()))
                    :Expanded(
                  child: Visibility(
                    visible: !_isMenuOpen, // メニューが開いていない時だけテキストを表示
                    child: SingleChildScrollView(
                      child: Text(
                        _responseText,
                        style: TextStyle(color: _isMenuOpen ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),

                Padding( // 追加: Rowの上に余白を追加するためのPadding
                  padding: EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.79,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            labelText: '質問してみよう',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                if (_questionController.text.isNotEmpty) {
                                  _interactWithChatGPT(getCurrentUserUID() ?? "", widget.videoId, _questionController.text);
                                  _questionController.clear();
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _interactWithChatGPT(getCurrentUserUID() ?? "", widget.videoId, value);
                              _questionController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          floatingActionButton: SpeedDial(
            child: Icon(
              Icons.add,
              size: 35, // アイコンのサイズを指定
            ),
            buttonSize: Size(65, 65),
            activeIcon: Icons.close, // メニューを閉じるためのアイコン
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            switchLabelPosition: true,
            children: [
              SpeedDialChild(
                child: Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 30, // アイコンのサイズを指定
                ),
                backgroundColor: Colors.white,

                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                label: 'いいねする',
                onTap: () {
                  String? userId = getCurrentUserUID();
                  if (userId != null) {
                    likeVideo(userId, widget.videoId);
                    _showRiveAnimation(context, 'assets/RiveAssets/twitter_like_button1.riv');
                  }
                },
              ),

              SpeedDialChild(
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                  size: 30, // アイコンのサイズを指定
                ),
                backgroundColor: Colors.white,

                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                label: 'カレンダーに保存',
                onTap: () {
                  String? userId = getCurrentUserUID();
                  if (userId != null) {
                    saveVideoToCalendar(userId, widget.videoId);
                    _showRiveAnimation(context, 'assets/RiveAssets/checkmark.riv');
                  }
                },
              ),

            ],

          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

        );
      },
    );
  }
}