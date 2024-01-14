import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutProfileBox extends StatelessWidget {
  final String documentId; // FirestoreのドキュメントID

  const AboutProfileBox({
    Key? key,
    required this.documentId, // コンストラクタでドキュメントIDを受け取る
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Youtuber').doc(documentId).get(),
      builder: (context, snapshot) {
        // データ取得の状態をデバッグ出力
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // エラーがあった場合はエラーメッセージを表示
          return Center(child: Text('エラー: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          // データがない場合はメッセージを表示
          return Center(child: Text('データが利用できません'));
        }

        // データがある場合はプロフィール情報を表示
        var channelData = snapshot.data!.data() as Map<String, dynamic>;
        String name = channelData['name'] ?? '名前なし';
        String picUrl = channelData['picurl'] ?? '';
        String subscribers = channelData['Subscribers'] ?? 'N/A';
        String views = channelData['Views'] ?? 'N/A';
        String post = channelData['post'] ?? 'N/A';
        String about = channelData['about'] ?? 'N/A';


        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(picUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About me",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      about, // Firestoreから取得したaboutテキストを表示
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20), // スペーシング
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _InfoBox(
                      value: post,
                      label: 'Posts',
                      context: context,
                    ),
                    _InfoBox(
                      value: subscribers + '万',
                      label: 'Followers',
                      context: context,
                    ),
                    _InfoBox(
                      value: views,
                      label: 'Views',
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String value;
  final String label;
  final BuildContext context;

  const _InfoBox({
    Key? key,
    required this.value,
    required this.label,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
