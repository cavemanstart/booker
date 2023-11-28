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
          height: 400,
          width: 300,
          color: Colors.pink,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.search,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Icon(
                  Icons.deck,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              Positioned(
                child: Icon(
                  Icons.dangerous,
                  size: 40,
                  color: Colors.white,
                ),
                left: 100,
                top: 200,
              )
            ],
          )),
    );
  }
}
