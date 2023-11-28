import 'package:booker_app/fonts/fonts.dart';
import 'package:flutter/material.dart';

//搜索栏
Widget search = new Container(
  color: Colors.white,
  height: 45,
  child: TextField(
    decoration: InputDecoration(
        prefixIcon: Icon(
          IconFont.search,
          size: 28,
          color: Colors.grey[800],
        ),
        hintText: "搜索",
        suffixIcon: Icon(
          IconFont.cancel,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          // borderSide: BorderSide(
          //   color: Colors.white,
          // width: 5,
          // ),
        )),
  ),
);
//星级评分
List<Widget> _getGradeStar(double score, int total) {
  List<Widget> _list = [];
  for (var i = 0; i < total; i++) {
    double factor = (score - i);
    if (factor >= 1) {
      factor = 1.0;
    } else if (factor < 0) {
      factor = 0;
    }
    Stack _st = Stack(
      children: <Widget>[
        Icon(
          IconFont.star,
          color: Colors.grey,
        ),
        ClipRect(
            child: Align(
          alignment: Alignment.topLeft,
          widthFactor: factor,
          child: Icon(
            IconFont.star,
            color: Colors.yellow,
          ),
        ))
      ],
    );
    _list.add(_st);
  }
  return _list;
}

Widget bookcard = new Card(
    elevation: 5, //阴影
    shape: const RoundedRectangleBorder(
      //形状
      //修改圆角
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    margin: EdgeInsets.all(10),
    child: Row(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
            padding: EdgeInsets.all(15),
            height: 160,
            child: AspectRatio(
              aspectRatio: 0.825,
              child: Image.network(
                  'https://www.itying.com/images/flutter/1.png',
                  fit: BoxFit.fill),
            )),
        Container(
          height: 160,
          width: 400,
          child: ListTile(
            title: Text(
              "傲慢与偏见",
              style: TextStyle(fontSize: 28),
            ),
            subtitle: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text("讲述了一段奇幻的爱情故范围丰富发呢噢房间诶啊那非of和捏五百次电脑开机恩覅恩纷纷"),
                    )
                  ],
                ),
                Row(
                  children: _getGradeStar(4.5, 5),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text("出版社。。。"),
                    )
                  ],
                )
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              size: 40,
            ),
            onTap: () {},
          ),
        )
      ],
    ));
