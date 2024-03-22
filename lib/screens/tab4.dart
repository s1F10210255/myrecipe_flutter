import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:g14/widget/videocard.dart' as video_card;
import 'package:g14/screens/recipegenerator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class Tab4 extends StatefulWidget {
  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedDayMemo = "";

  final DateFormat _formatter = DateFormat('yyyy-MM-dd');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<DateTime, List> _events = {};
  List<video_card.YouTubeVideo> _videosWithDetails = [
  ]; // video_card.YouTubeVideo を使っている

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _retrieveEvents();
  }

  String? getCurrentUserUID() {
    return _auth.currentUser?.uid;
  }


  void _retrieveEvents() {
    final String? userUID = getCurrentUserUID();
    if (userUID != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('Calendar_video')
          .get()
          .then((QuerySnapshot querySnapshot) {
        Map<DateTime, List<dynamic>> events = {};
        for (var doc in querySnapshot.docs) {
          DateTime date = DateFormat('yyyy-MM-dd').parseUtc(doc.id);
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic> ?? {};
          List<dynamic> videoIds = docData['videoIds'] ?? [];

          String memo = docData.containsKey('memo') ? docData['memo'] ?? '' : '';

          // イベントリストを初期化し、ビデオIDとメモを追加
          List<dynamic> eventList = [];
          eventList.addAll(videoIds);
          if (memo.isNotEmpty) {
            eventList.add({'memo': memo});
          }
          events[date] = eventList;
        }
        setState(() {
          _events = events;
        });
      });
    }
  }


  Future<void> _fetchVideoIds() async {
    final String formattedDate = _formatter.format(_selectedDay!);
    final String? userUID = getCurrentUserUID();

    if (userUID != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userUID)
          .collection('Calendar_video')
          .doc(formattedDate)
          .get();

      if (snapshot.exists && snapshot.data()!.containsKey('videoIds')) {
        List<String> videoIds = List.from(snapshot.get('videoIds'));
        await _fetchVideoDetails(videoIds); // ビデオの詳細を取得する
      }
    }
  }

  Future<void> _deleteVideo(String videoId) async {
    final String formattedDate = _formatter.format(_selectedDay!);
    final String? userUID = getCurrentUserUID();

    if (userUID != null) {
      DocumentReference docRef = FirebaseFirestore
          .instance
          .collection('users')
          .doc(userUID)
          .collection('Calendar_video')
          .doc(formattedDate);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          List<dynamic> videoIds = List.from(snapshot.get('videoIds'));
          videoIds.remove(videoId); // ビデオIDをリストから削除
          transaction.update(docRef, {'videoIds': videoIds});
        }
      }).then((value) {
        print("Video Deleted");
        _fetchVideoIds(); // 削除後にビデオリストを更新
      }).catchError((error) => print("Failed to delete video: $error"));
    }
  }

  Widget _buildVideoItem(video_card.YouTubeVideo video) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RecipeGenerator(videoId: video.id),
        ));
      },
      child: Dismissible(
        key: Key(video.id),
        onDismissed: (direction) {
          _deleteVideo(video.id); // スワイプして削除
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white),
              Text('削除する',
                  style: TextStyle(color: Colors.white, fontSize: 30)),
            ],
          ),
        ),
        child: video_card.VideoCard(video: video),
      ),
    );
  }


  Future<void> saveMemo(String userId, String formattedDate,
      String memo) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Calendar_video')
        .doc(formattedDate);

    return docRef.set({
      'memo': memo,
    }, SetOptions(merge: true)); // 既存のデータにマージ
  }

  void _showAddMemoDialog() async {
    TextEditingController memoController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('メモを追加'),
          content: TextField(
            controller: memoController,
            decoration: InputDecoration(hintText: "メモを入力してください"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () {
                if (memoController.text.isNotEmpty) {
                  saveMemo(
                      getCurrentUserUID()!, _formatter.format(_selectedDay!),
                      memoController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _videosWithDetails.clear();

        // メモの取得とデバッグ情報の出力
        var dayEvents = _events[selectedDay] ?? [];
        if (dayEvents.isNotEmpty) {
          for (var event in dayEvents) {
            if (event is Map<String, dynamic> && event.containsKey('memo')) {
              _selectedDayMemo = event['memo'];
              print("Memo for $_selectedDay: $_selectedDayMemo");
              break;
            }
          }
        } else {
          _selectedDayMemo = '';  // イベントが空の場合はメモをクリア
          print("No events for $_selectedDay");
        }
      });
      _fetchVideoIds();
    }
  }





  Future<void> _fetchVideoDetails(List<String> videoIds) async {
    final String apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    List<video_card.YouTubeVideo> videosWithDetails = [];

    for (var videoId in videoIds) {
      final String apiUrl = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$apiKey';
      final response = await http.get(Uri.parse(apiUrl));

      if (apiKey.isEmpty) {
        // エラー処理やユーザーへの通知を行う
        print('API key is not found in .env file.');
        return;
      }

      if (response.statusCode == 200) {
        final videoData = json.decode(response.body)['items'][0];

        var newVideo = video_card.YouTubeVideo( // 修正されたコンストラクタ
          id: videoData['id'],
          title: videoData['snippet']['title'],
          thumbnailUrl: videoData['snippet']['thumbnails']['high']['url'],
          channelTitle: videoData['snippet']['channelTitle'],
          viewCount: int.parse(videoData['statistics']['viewCount']),
          publishedAt: DateTime.parse(videoData['snippet']['publishedAt']),
        );

        videosWithDetails.add(newVideo);
      } else {
        throw Exception('Failed to load video details');
      }
    }

    setState(() {
      _videosWithDetails = videosWithDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          TableCalendar(
            firstDay: DateTime.utc(2022, 4, 1),
            lastDay: DateTime.utc(2029, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
            _selectedDay != null && isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {


              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _videosWithDetails.clear(); // ビデオリストをクリア
                });
                _fetchVideoIds();
              }
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      width: 7,
                      height: 7,
                    ),
                  );
                }
              },
            ),
          ),
          if (_selectedDayMemo.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                _selectedDayMemo,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _videosWithDetails.length,
              itemBuilder: (context, index) {
                final video = _videosWithDetails[index];
                return _buildVideoItem(video);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemoDialog,
        child: Icon(Icons.note_add),
        tooltip: 'メモを追加',
      ),
    );
  }
}