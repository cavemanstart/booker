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
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 300,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(
          color: Colors.blue,
          width: 5,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      padding: EdgeInsets.fromLTRB(10, 20, 10, 20), //内边距
      // margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
      // transform: Matrix4.translationValues(100, 0, 0),
      transform: Matrix4.rotationZ(0.1),
      alignment: Alignment.bottomCenter,
      child: Text(
        "我是一个Container里面的文本！",
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textScaleFactor: 2,
        style: TextStyle(
          fontSize: 12,
          color: Colors.green,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.lineThrough,
          decorationColor: Colors.red,
        ),
      ),
    ));
  }
}
