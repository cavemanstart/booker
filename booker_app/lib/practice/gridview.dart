import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("我是Title!"),
        ),
        body: HomeContent(),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  // 自定义方法
  List<Widget> _getListData() {
    List<Widget> list = [];
    for (var i = 0; i < 20; i++) {
      list.add(Container(
        color: Colors.blue,
        alignment: Alignment.center,
        child: Text(
          "this is the NO.$i banana.",
          style: TextStyle(color: Colors.yellow, fontSize: 20),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, //三列
      children: this._getListData(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.763,
      padding: EdgeInsets.all(10),
    );
  }
}
