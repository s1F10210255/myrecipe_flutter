import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:g14/widget/videocard.dart' as video_card;
import 'package:g14/screens/recipegenerator.dart';


class Tab4 extends StatefulWidget {
  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
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
        Map<DateTime, List> events = {};
        for (var doc in querySnapshot.docs) {
          // Firestoreの日付文字列からUTCのDateTimeオブジェクトを生成
          DateTime utcDate = DateFormat('yyyy-MM-dd').parseUtc(doc.id);
          // UTC日付の深夜時刻を持つDateTimeオブジェクトを作成
          DateTime dateWithMidnightUtc = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);
          events[dateWithMidnightUtc] = doc['videoIds'];
          print('Date with events: $dateWithMidnightUtc with events: ${doc['videoIds']}');
        }
        setState(() {
          _events = events;
          print('Events map updated: $_events');
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

  Future<void> _fetchVideoDetails(List<String> videoIds) async {
    final String apiKey = 'AIzaSyAd6OIW60UHOBRO_10VhujI6FujyBQsTB4'; // 実際のAPIキーをセキュアな場所から取得してください
    List<video_card.YouTubeVideo> videosWithDetails = [];

    for (var videoId in videoIds) {
      final String apiUrl = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$apiKey';
      final response = await http.get(Uri.parse(apiUrl));

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
            selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _videosWithDetails.clear(); // ビデオリストをクリア
                });
                _fetchVideoIds(); // 新しい選択された日付に基づいてビデオIDを取得
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
          Expanded(
            child: ListView.builder(
              itemCount: _videosWithDetails.length,
              itemBuilder: (context, index) {
                final video = _videosWithDetails[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RecipeGenerator(videoId: video.id),
                    ));
                  },
                  child: video_card.VideoCard(video: video),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
