import 'package:flutter/material.dart';

class HowToPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/images/oyako2.png"), // アップロードされた画像のパスに注意してください。
            // 他に追加したいウィジェットがあれば、ここに記述します。
          ],
        ),
      ),
    );
  }
}
