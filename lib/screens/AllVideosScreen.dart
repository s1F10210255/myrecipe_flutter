import 'package:flutter/material.dart';
import 'package:g14/widget/videocard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/widget/home_screen/food_card2.dart';

class AllVideosScreen extends StatefulWidget {
  final String categoryKey;
  const AllVideosScreen({Key? key, required this.categoryKey}) : super(key: key);

  @override
  _AllVideosScreenState createState() => _AllVideosScreenState();
}

class _AllVideosScreenState extends State<AllVideosScreen> {
  Future<List<String>> fetchVideoIds() async {
    final firestoreInstance = FirebaseFirestore.instance;
    var document = await firestoreInstance.collection('VideoIds').doc('youtube_videos').get();

    if (document.exists) {
      var data = document.data();
      if (data != null && data.containsKey(widget.categoryKey)) {
        return List<String>.from(data[widget.categoryKey]);
      } else {
        throw 'Field ${widget.categoryKey} not found in the document';
      }
    } else {
      throw 'Document "youtube_videos" not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // タイトルを削除
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // 戻るボタンの機能
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchVideoIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return YouTubeVideoCard(videoId: snapshot.data![index]);
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
