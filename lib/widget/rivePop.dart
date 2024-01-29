import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAnimationWidget extends StatelessWidget {
  final String assetName;

  RiveAnimationWidget({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200, // 適切なサイズに調整
        height: 200,
        child: RiveAnimation.asset(assetName),
      ),
    );
  }
}
