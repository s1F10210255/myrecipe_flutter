import 'package:flutter/material.dart';
import 'package:g14/screens/LikeVideo.dart';

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LikedVideosPage()
            ));
          },
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            fixedSize: const Size(55, 55),
          ),
          icon: const Icon(Icons.favorite,color:Colors.pinkAccent),
        ),
      ],
    );
  }
}