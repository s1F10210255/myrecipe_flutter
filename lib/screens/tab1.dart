import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:g14/screens/recipegenerator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

import 'package:g14/screens/recipegenerator2.dart';


class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  static const String key = "AIzaSyAd6OIW60UHOBRO_10VhujI6FujyBQsTB4";

  YoutubeAPI youtube = YoutubeAPI(key, maxResults: 20, type: 'video');

  List<YouTubeVideo> videoResult = [];

  String selectedQuery = "簡単レシピ"; // 初期値を簡単レシピに設定

  bool _isLoading = true; //API呼び出し中trueにしておく

  Future<void> callAPI() async {
    setState(() {
      _isLoading = true; // API呼び出し開始時にtrueに設定
    });

    List<YouTubeVideo> videos = await youtube.search(
      selectedQuery,
      order: 'relevance',
      videoDuration: 'any',
      regionCode: 'JP',
    );

    // ここで字幕の有無を確認
    List<YouTubeVideo> videosWithCaptions = [];
    for (var video in videos) {
      if (await checkForCaptions(video.id)) {
        videosWithCaptions.add(video);
      }
    }

    // 字幕があるビデオだけをセット
    setState(() {
      videoResult = videosWithCaptions;
      _isLoading = false;
    });
  }

  Future<bool> checkForCaptions(String? videoId) async {
    if (videoId == null) return false;

    final response = await http.post(
      Uri.parse(
          'https://asia-northeast1-dotted-crane-403823.cloudfunctions.net/youtube_subtitles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'video_ids': [videoId]}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Use a non-nullable string for the key
      return data['captions'][videoId] ?? false;
    } else {
      return false;
    }
  }

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    callAPI();
  }


  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            DropdownButton<String>(
              value: selectedQuery,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedQuery = newValue;
                    _isLoading = true; // ローディング状態をtrueに設定
                    callAPI(); // 新しいクエリでAPIを再呼び出し
                  });
                }
              },
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: "簡単レシピ",
                  child: Text("簡単レシピ"),
                ),
                DropdownMenuItem<String>(
                  value: "和食　レシピ",
                  child: Text("和食"),
                ),
                DropdownMenuItem<String>(
                  value: "洋食　レシピ",
                  child: Text("洋食"),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: videoResult.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      videoResult[index].thumbnail.small.url ?? '',
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error); // エラー時はエラーアイコンを表示
                      },
                    ),
                    title: Text(videoResult[index].title),
                    onTap: () {
                      String? selectedVideoId = videoResult[index].id;
                      if (selectedVideoId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeGenerator2(
                                  videoId: selectedVideoId,
                                ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        _isLoading
            ? Center(child: Image.asset('assets/gif/road.gif')) // ロード中はGIFを表示
            : SizedBox.shrink(), // ロード完了後は表示しない
      ],
    );
  }
}