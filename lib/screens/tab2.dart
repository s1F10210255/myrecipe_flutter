import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:g14/screens/recipegenerator2.dart';

class Tab2 extends StatefulWidget {
  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  static const String key = "AIzaSyA8OXpQMoeDgbb7nkwX4mDpjeCh4UmQkOQ"; // あなたのAPIキーを使用してください

  YoutubeAPI youtube = YoutubeAPI(key);
  List<YouTubeVideo> videoResult = [];

  Future<void> callAPI() async {
    String query = "有名シェフレシピ";
    videoResult = await youtube.search(
      query,
      order: 'relevance',
      videoDuration: 'any',
      regionCode: 'JP',
    );
    setState(() {});
  }





  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videoResult.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.network(videoResult[index].thumbnail.small.url ?? ''),
          title: Text(videoResult[index].title),
          subtitle: Text(videoResult[index].channelTitle),
          onTap: () {
            String? selectedVideoId = videoResult[index].id;
            if (selectedVideoId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecipeGenerator2(videoId: selectedVideoId),
                ),
              );
            }
          },
        );
      },
    );
  }
}
