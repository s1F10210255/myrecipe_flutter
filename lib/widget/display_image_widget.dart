import 'package:flutter/material.dart';
import 'dart:io';

class DisplayImage extends StatefulWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const DisplayImage({
    Key? key,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  _DisplayImageState createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(64, 105, 225, 1);

    return Center(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Stack(
          children: [
            buildImage(color, context),
            Positioned(
              child: buildEditIcon(color),
              right: 4,
              top: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage(Color color, BuildContext context) {
    return CircleAvatar(
      radius: 75,
      backgroundColor: color,
      child: CircleAvatar(
        radius: 70,
        backgroundImage: _isError
            ? AssetImage('assets/images/default_image.jpg') as ImageProvider<Object> // デフォルトのアバター画像
            : NetworkImage(widget.imagePath) as ImageProvider<Object>, // 外部から渡された画像のパス
        onBackgroundImageError: (exception, stackTrace) {
          if (!_isError) {
            setState(() {
              _isError = true;
            });
            debugPrint('画像の読み込みに失敗しました: $exception');
          }
        },
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
    all: 8,
    child: Icon(
      Icons.edit,
      color: color,
      size: 20,
    ),
  );

  Widget buildCircle({
    required Widget child,
    required double all,
  }) => ClipOval(
    child: Container(
      padding: EdgeInsets.all(all),
      color: Colors.white,
      child: child,
    ),
  );
}
