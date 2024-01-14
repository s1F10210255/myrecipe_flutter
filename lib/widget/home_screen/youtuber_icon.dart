import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/screens/youtuber2.dart';

class CreatorsList extends StatelessWidget {
  const CreatorsList({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchCreators() async {
    final firestoreInstance = FirebaseFirestore.instance;
    List<Map<String, dynamic>> creators = [];
    QuerySnapshot querySnapshot = await firestoreInstance.collection('Youtuber').get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      creators.add({
        'name': data['name'] ?? 'No Name', // 'name'がnullの場合はデフォルト値を使用
        'iconUrl': data['picurl'] ?? '', // 'iconUrl'がnullの場合はデフォルト値を使用
        // 'videoIds'がnullの場合は空のリストを使用
        'videoIds': data['videoIds'] != null ? List<String>.from(data['videoIds']) : [],
      });
    }
    return creators;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCreators(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return SizedBox(
              height: 120, // 高さ調整
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => SizedBox(width: 30), // 画像間のスペース
                itemBuilder: (context, index) {
                  var creator = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YoutuberScreen(recomendNumber: index),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(creator['iconUrl']),
                          radius: 40,
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}