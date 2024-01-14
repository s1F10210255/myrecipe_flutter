import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // intl パッケージをインポート
import 'package:g14/widget/videocard_ver2.dart' as video_card;
import 'package:g14/screens/recipegenerator.dart';

class LikedVideosPage extends StatefulWidget {
  @override
  _LikedVideosPageState createState() => _LikedVideosPageState();
}

class _LikedVideosPageState extends State<LikedVideosPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> _fetchLikedVideos() async {
    List<Map<String, dynamic>> videos = [];
    String userId = _currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('likevideo')
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime likedAt = (data['likedAt'] as Timestamp).toDate();
        String videoId = data['videoId'];

        final videoDetails = await _fetchVideoDetails(videoId);
        videos.add({
          'likedAt': likedAt,
          ...videoDetails,
        });
      }
    }

    return videos;
  }

  Future<Map<String, dynamic>> _fetchVideoDetails(String videoId) async {
    final String apiKey = 'AIzaSyA8OXpQMoeDgbb7nkwX4mDpjeCh4UmQkOQ';
    final String apiUrl = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$apiKey';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final videoData = json.decode(response.body)['items'][0];
      return {
        'id': videoData['id'],
        'title': videoData['snippet']['title'],
        'thumbnailUrl': videoData['snippet']['thumbnails']['high']['url'],
        'channelTitle': videoData['snippet']['channelTitle'],
        'viewCount': int.parse(videoData['statistics']['viewCount']),
        'publishedAt': DateTime.parse(videoData['snippet']['publishedAt']),
      };
    } else {
      throw Exception('Failed to load video details');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('いいねした　動画'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLikedVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No liked videos.'));
          }

          List<Map<String, dynamic>> videos = snapshot.data!;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var video = videos[index];
              var videoInfo = video_card.YouTubeVideo(
                id: video['id'],
                title: video['title'],
                thumbnailUrl: video['thumbnailUrl'],
                channelTitle: video['channelTitle'],
                viewCount: video['viewCount'],
                publishedAt: video['publishedAt'],
              );
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeGenerator(videoId: video['id']),
                    ),
                  );
                },
                child: Column(
                  children: [
                    video_card.VideoCard(video: videoInfo),
                    Text('いいねした日: ${DateFormat('yyyy年MM月dd日').format(
                        video['likedAt'])}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}