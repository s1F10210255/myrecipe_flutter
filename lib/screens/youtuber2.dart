import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/widget/videocard.dart';
import 'package:g14/widget/home_screen/food_card2.dart';
import 'package:g14/widget/profile_box.dart';

class YoutuberScreen extends StatelessWidget {
  final int recomendNumber;

  const YoutuberScreen({Key? key, required this.recomendNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 'recomendNumber' を使ってドキュメントIDを作成します。
    String docId = 'recomend${recomendNumber + 1}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // タイトルを削除
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              // 'AboutProfileBox' ウィジェットに 'docId' を渡します。
              child: AboutProfileBox(documentId: docId),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                // 再度、Firestoreからデータを非同期で取得します。
                future: FirebaseFirestore.instance.collection('Youtuber').doc(docId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data!.exists) {
                    // ドキュメントのデータからビデオIDのリストを取得します。
                    List<String> videoIds = List<String>.from(snapshot.data!['videoid'] ?? []);
                    // ビデオカードのリストビューを構築します。
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: videoIds.length,
                      itemBuilder: (context, index) {
                        return YouTubeVideoCard(videoId: videoIds[index]);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('エラーが発生しました');
                  }
                  // データを取得中の場合は、プログレスインジケータを表示します。
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
