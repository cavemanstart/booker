import 'package:booker_app/tools/MyColors.dart';
import 'package:flutter/material.dart';
import '../HomePage.dart';
import '../bookpage/Book.dart';
import '../Analyze.dart';
import '../Mine.dart';
import '../../fonts/fonts.dart';

class Tabs extends StatefulWidget {
  Tabs({Key key}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  List _pageList = [
    HomePage(),
    Book(),
    Analyze(),
    Mine(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this._pageList[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: this._currentIndex,
        // unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            this._currentIndex = index;
          });
        },
        selectedItemColor: MyColors.primary,
        // fixedColor: MyColors.primary,

        items: [
          BottomNavigationBarItem(
            icon: Icon(
              IconFont.homepage,
              size: 20,
              // color: Colors.black
            ),
            label: "首页",
            // style: TextStyle(color: Colors.black),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconFont.library,
              size: 20,
              // color: Colors.black
            ),
            label: "书架",
            // style: TextStyle(color: Colors.black),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconFont.analysis,
              size: 20,
              // color: Colors.black
            ),
            label: "分析",
            // style: TextStyle(color: Colors.black),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconFont.my,
              size: 20,
              // color: Colors.black,
            ),
            label: "我的",
            // style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
