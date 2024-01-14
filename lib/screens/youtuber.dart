import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g14/widget/home_screen/food_card2.dart';
import 'package:g14/widget/home_screen/home_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/widget/home_screen/youtuber_icon.dart';
import 'package:g14/widget/profile_box.dart';


class YoutuberScreen extends StatelessWidget {
  final int recomendNumber;

  const YoutuberScreen({Key? key, required this.recomendNumber}) : super(key: key);

  Future<Map<String, dynamic>> fetchCreatorData() async {
    final firestoreInstance = FirebaseFirestore.instance;
    String docId = 'recomend${recomendNumber + 1}'; // 1を足すことで1から始まる番号に対応
    var document = await firestoreInstance.collection('Youtuber').doc(docId).get();

    if (document.exists) {
      return document.data()!;
    } else {
      throw 'Document not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCreatorData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var creatorData = snapshot.data!;
            List<String> videoIds = creatorData['videoid'] != null
                ? List<String>.from(creatorData['videoid'])
                : []; // 'videoIds'がnullの場合は空のリストを使用

            // videoIds を使用して動画一覧を表示
            return Scaffold(
              appBar: AppBar(
                title: Text(creatorData['name']), // クリエイターの名前を表示
              ),
              body: ListView.builder(
                itemCount: videoIds.length,
                itemBuilder: (context, index) {
                  return YouTubeVideoCard(videoId: videoIds[index]);
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}