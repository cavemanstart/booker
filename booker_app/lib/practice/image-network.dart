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
      // height: 300,
      // width: 300,
      // decoration: BoxDecoration(
      //   color: Colors.yellow,
      //   borderRadius: BorderRadius.circular(150),
      //   image: DecorationImage(
      //     image: NetworkImage("https://pics1.baidu.com/feed/0ff41bd5ad6eddc4b8b690fa1b4e0dfb536633fd.jpeg?token=18c3ddd58f715fad02f392f4c38790fb"),
      //     fit:BoxFit.cover
      //   )
      // ),
      child: ClipOval(
        child: Image.network(
            "https://pics1.baidu.com/feed/0ff41bd5ad6eddc4b8b690fa1b4e0dfb536633fd.jpeg?token=18c3ddd58f715fad02f392f4c38790fb",
            width: 200,
            height: 200,
            fit: BoxFit.cover),
      ),
    ));
  }
}
