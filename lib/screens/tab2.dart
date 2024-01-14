import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:g14/screens/recipegenerator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:g14/widget/videocard.dart' as video_card;
import 'package:g14/widget/AdWidget_tab2.dart';



class Tab2 extends StatefulWidget {
  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  static const String key = "AIzaSyAd6OIW60UHOBRO_10VhujI6FujyBQsTB4"; // 実験用のAPIキー
  YoutubeAPI youtube = YoutubeAPI(key, maxResults: 20, type: 'video');
  List<video_card.YouTubeVideo> videoResult = [];
  bool _isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> callAPI(String query) async {
    setState(() {
      _isLoading = true;
      videoResult.clear(); // 前の検索結果をクリア
    });

    // 最初にYouTube APIで動画を検索
    var searchResults = await youtube.search(query, order: 'relevance', videoDuration: 'any', regionCode: 'JP');
    List<String> videoIds = searchResults.map((video) => video.id).where((id) => id != null).cast<String>().toList();

    // 字幕の有無を確認するためにGoogle Cloud Functionを呼び出し
    var captionsResponse = await http.post(
      Uri.parse('https://asia-northeast1-dotted-crane-403823.cloudfunctions.net/youtube_subtitles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'video_ids': videoIds}),
    );

    if (captionsResponse.statusCode == 200) {
      var captionsData = json.decode(captionsResponse.body);
      var captions = captionsData['captions'] as Map<String, dynamic>;
      // 字幕がある動画IDのリストを作成
      var videoIdsWithCaptions = captions.entries.where((entry) => entry.value == true).map((entry) => entry.key).toList();

      // 字幕がある動画のみの詳細情報を取得
      var videoDetailsResponse = await http.get(
          Uri.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=${videoIdsWithCaptions.join(',')}&key=${key}')
      );

      if (videoDetailsResponse.statusCode == 200) {
        var videoDetailsData = json.decode(videoDetailsResponse.body);
        List<video_card.YouTubeVideo> videosWithDetails = [];

        for (var videoData in videoDetailsData['items']) {
          var newVideo = video_card.YouTubeVideo(
            id: videoData['id'],
            title: videoData['snippet']['title'],
            thumbnailUrl: videoData['snippet']['thumbnails']['high']['url'],
            channelTitle: videoData['snippet']['channelTitle'],
            viewCount: int.parse(videoData['statistics']['viewCount']),
            publishedAt: DateTime.parse(videoData['snippet']['publishedAt']),
          );
          videosWithDetails.add(newVideo);
        }

        setState(() {
          videoResult = videosWithDetails;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<bool> checkForCaptions(String? videoId) async {
    if (videoId == null) return false;

    final response = await http.post(
      Uri.parse('https://asia-northeast1-dotted-crane-403823.cloudfunctions.net/youtube_subtitles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'video_ids': [videoId]}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['captions'][videoId] ?? false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'YouTube検索',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      callAPI(searchController.text);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  callAPI(value);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: videoResult.length,
                itemBuilder: (context, index) {
                  return video_card.VideoCard(
                    video: videoResult[index],
                    onTap: () {
                      String? selectedVideoId = videoResult[index].id;
                      if (selectedVideoId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeGenerator(videoId: selectedVideoId),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            BannerAdWidget(),
          ],

        ),
        _isLoading
            ? Center(child: Image.asset('assets/gif/road.gif'))
            : SizedBox.shrink(),
      ],
    );
  }
}
