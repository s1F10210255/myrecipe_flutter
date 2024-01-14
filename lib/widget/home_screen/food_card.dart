import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:g14/screens/recipegenerator.dart';
import 'package:g14/widget/videocard.dart';


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
  const YouTubeVideoCard({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    // カード全体のサイズを定義
    final double cardWidth = MediaQuery.of(context).size.width * 0.60;
    final double imageHeight = 132;

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchVideoDetails(videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          var videoData = snapshot.data!;
          // GestureDetectorを使用してタップ可能にする
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeGenerator(videoId: videoId),
              ),
            ),
            // Containerでカードをラップして影をつける
            child: Container(
              width: cardWidth, // カードの幅を設定
              margin: EdgeInsets.symmetric(vertical: 10.0), // 上下の余白を設定
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0), // 全体の角を丸くする
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 影の色
                    spreadRadius: 1, // 影の範囲を広げる
                    blurRadius: 5, // 影をぼかす
                    offset: Offset(0, 3), // 影の方向を下に設定
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // ClipRRectで画像の角を丸くする
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      videoData['thumbnailUrl'],
                      height: imageHeight, // 画像の高さを設定
                      width: cardWidth, // 画像の幅をカードの幅に合わせる
                      fit: BoxFit.cover, // 画像をカバーするように設定
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        videoData['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2, // タイトルは最大2行まで表示
                        overflow: TextOverflow.ellipsis, // 長いテキストは省略記号で表示
                      ),
                    ),
                    // 必要に応じて他の動画情報をここに追加
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // データをロード中はプログレスインジケータを表示
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}