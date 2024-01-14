import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:g14/screens/recipegenerator.dart'; // 必要に応じて適切なパスを設定してください

// YouTube動画の詳細を取得する関数
Future<Map<String, dynamic>> _fetchVideoDetails(String videoId) async {
  final String apiKey = 'AIzaSyA8OXpQMoeDgbb7nkwX4mDpjeCh4UmQkOQ'; // APIキーを設定
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

// YouTube動画のサムネイルを表示するカードウィジェット
class YouTubeVideoCard extends StatelessWidget {
  final String videoId;
  const YouTubeVideoCard({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.45;

    return GestureDetector(
      onTap: () {
        // タップされたときにRecipeGenerator画面に遷移する
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeGenerator(videoId: videoId),
          ),
        );
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchVideoDetails(videoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            var videoData = snapshot.data!;
            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      videoData['thumbnailUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      videoData['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 他の詳細ウィジェットを追加
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
