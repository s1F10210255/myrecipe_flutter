import 'package:flutter/material.dart';
import 'package:g14/screens/tab1.dart';

class YouTubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final int viewCount;
  final DateTime publishedAt;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.viewCount,
    required this.publishedAt,
  });
}


// YouTube動画を表示するためのカードウィジェット
class VideoCard extends StatelessWidget {
  final YouTubeVideo video;
  final bool hasPadding;
  final VoidCallback? onTap;

  const VideoCard({
    Key? key,
    required this.video,
    this.hasPadding = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hasPadding ? 12 : 0),
            child: Image.network(
              video.thumbnailUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: Theme.of(context).textTheme.headline6), // タイトル
                Text(video.channelTitle, style: Theme.of(context).textTheme.subtitle1), // チャンネル名
                Text('Views: ${video.viewCount}', style: Theme.of(context).textTheme.caption), // 視聴回数
              ],
            ),
          ),
        ],
      ),
    );
  }
}
