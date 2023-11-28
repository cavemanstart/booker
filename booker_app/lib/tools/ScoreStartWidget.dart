import 'package:booker_app/tools/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'MyColors.dart';

class ScoreStartWidget extends StatefulWidget {
  final score;
  final p5; //五颗星的百分比
  final p4;
  final p3;
  final p2;
  final p1;
  final sum;

  ScoreStartWidget(
      {Key key,
      @required this.score,
      @required this.p1,
      @required this.p2,
      @required this.p3,
      @required this.p4,
      @required this.p5,
      @required this.sum})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScoreStartState();
  }
}

class _ScoreStartState extends State<ScoreStartWidget> {
  var lineW;

  @override
  Widget build(BuildContext context) {
    lineW = MediaQuery.of(context).size.width / 3;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: MyColors.grey,
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //评分、星星
                  children: <Widget>[
                    Text(
                      '${widget.score}',
                      style: TextStyle(fontSize: 38.0, color: MyColors.primary),
                    ),
                    RatingBar(
                      widget.score,
                      size: 12.0,
                      fontSize: 0.0,
                    )
                  ],
                ),
                padding: EdgeInsets.only(left: 10.0, right: 20.0),
              ),
              Column(
                //星星-百分比
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  startsLine(5, widget.p5),
                  startsLine(4, widget.p4),
                  startsLine(3, widget.p3),
                  startsLine(2, widget.p2),
                  startsLine(1, widget.p1),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '共有${widget.sum.toString()}人评分',
                style: TextStyle(
                  fontSize: 12,
                  color: MyColors.text,
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(50),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget getStarts(int count) {
    List<Container> list = [];
    for (int i = 0; i < count; i++) {
      list.add(Container(
        child: Row(
          children: [
            Icon(
        Icons.star,
        size: 12.0,
        color: MyColors.primary,
      ),
      SizedBox(width: ScreenUtil().setWidth(6),),
          ],
        ),
      ));
    }
    return Row(
      children: list,
    );
  }

  ///percent 百分比(0.1 -1.0)
  Widget getLine(double percent) {
    return Stack(
      children: <Widget>[
        Container(
          width: lineW,
          height: ScreenUtil().setHeight(20),
          decoration: BoxDecoration(
              color: Color(0x13000000),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
        ),
        Container(
          height: ScreenUtil().setHeight(20),
          width: lineW * percent,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 170, 71),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
        )
      ],
    );
  }

  startsLine(int startCount, double percent) {
    if (percent == null || percent.isNaN) {
      percent = 0.0;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          getStarts(startCount),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
          ),
          getLine(percent)
        ],
      ),
    );
  }
}
