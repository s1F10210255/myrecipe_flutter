import 'package:flutter/material.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import 'package:g14/screens/chat_page.dart';
import 'package:g14/widget/AdWidget_tab2.dart';

class Tab3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> titles = ["坂本龍馬", "ボディビルダー", "AI 栄養士", "マリー・アントワネット", "陽気なインド人"];
    final List<String> avatarUrls = [
      'assets/images/nigaoe_sakamoto_ryouma.png',
      'assets/images/sports_bodybuilder_man.png',
      'assets/images/medical_eiyoushi.png',
      'assets/images/marie_antoinette.png',
      'assets/images/dance_india_woman.png',
    ];

    final List<Widget> images = List.generate(
      titles.length,
          (index) => Image.asset(avatarUrls[index], fit: BoxFit.contain),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "AIに相談しよう",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: VerticalCardPager(
                titles: titles,
                images: images,
                textStyle: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))],
                ),
                onPageChanged: (page) {},
                onSelectedItem: (index) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterChatPage(characterName: titles[index], avatarUrl: avatarUrls[index]),
                    ),
                  );
                },
                align: ALIGN.CENTER,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter, // Center the banner horizontally
              child: BannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
