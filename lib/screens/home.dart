import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g14/screens/tab1.dart';
import 'package:g14/screens/tab2.dart';
import 'package:g14/screens/tab4.dart';
import 'package:g14/screens/tab5.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 現在のタブインデックス
  User? _currentUser;

  final List<Widget> _pages = [
    Tab1(),  // 1つ目のタブの中身
    Tab2(),  // 2つ目のタブの中身
    Center(child: Text('Tab 3')),  // 3つ目のタブの中身
    Tab4(),
    Tab5(),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;  // <-- 現在のユーザーを取得
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_currentUser != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(child: Text(_currentUser!.email ?? '')),
            ),
        ],
      ),
      body: _pages[_currentIndex],  // 現在のタブインデックスに応じたページを表示
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // タップされたタブのインデックスを更新
          });
        },
        items: [
          CustomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.person),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
          ),
          CustomNavigationBarItem(
            icon: Icon(Icons.attachment),
          ),
        ],
        isFloating: true,  // <-- これを追加します
        bubbleCurve: Curves.easeInOutCubic,  // <-- これを追加します
        scaleCurve: Curves.decelerate,  // <-- これを追加します
      ),
    );
  }
}
