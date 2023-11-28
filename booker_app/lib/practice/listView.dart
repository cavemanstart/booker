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
    return ListView(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      children: <Widget>[
        Image.network("https://www.itying.com/images/flutter/1.png"),
        Container(
          child: Text(
            "哈哈哈哈",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.yellow),
          ),
          height: 40,
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        ),
        Image.network("https://www.itying.com/images/flutter/2.png"),
        Image.network("https://www.itying.com/images/flutter/3.png"),
        Image.network("https://www.itying.com/images/flutter/4.png"),
        Image.network("https://www.itying.com/images/flutter/5.png"),
        Image.network("https://www.itying.com/images/flutter/6.png"),
      ],
    );
  }
}
