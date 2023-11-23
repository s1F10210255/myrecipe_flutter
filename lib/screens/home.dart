import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g14/screens/tab1.dart';
import 'package:g14/screens/tab2.dart';
import 'package:g14/screens/tab4.dart';



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
    Center(child: Text('Tab 5')),  // 3つ目のタブの中身

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
        title: Text('Cock!!'),
      actions: [
        if (_currentUser != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text(_currentUser!.email ?? '')),
          ),],),

      body: _pages[_currentIndex],  // 現在のタブインデックスに応じたページを表示
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // タップされたタブのインデックスを更新
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tab 1',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tab 2',
            backgroundColor: Colors.yellow,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tab 3',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
            label: 'Tab 4',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attachment),
            label: 'Tab 5',
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
