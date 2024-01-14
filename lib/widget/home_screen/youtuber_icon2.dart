import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



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
              height: 120, // Adjust the size accordingly
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 8.0), // リストの左右のパディング
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => SizedBox(width: 10), // アイコンどうしの間隔を指定
                itemBuilder: (context, index) {
                  var creator = snapshot.data![index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement navigation to creator's video list
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(creator['iconUrl']),
                          radius: 40, // Adjust the size accordingly
                        ),
                      ),
                      SizedBox(height: 8), // アイコンと名前の間隔
                      Flexible(
                        child: Text(
                          creator['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        // Show a loading spinner while the data is being fetched
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
