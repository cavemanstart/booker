import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final text;
  final press;
  final double height;
  final double width;
  const MyButton(
      {this.text = '', this.press = null, this.height = 40.0 , this.width = 60.0});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      child: RaisedButton(
        child: Text(this.text),
        onPressed: () {
          this.press;
        },
      ),
    );
  }
}
