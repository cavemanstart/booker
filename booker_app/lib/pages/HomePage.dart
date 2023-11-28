import 'dart:ui';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:booker_app/fonts/fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../mydio/config.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var imgpath;
  var bookname;
  List<Widget> personal = [];
  List<Widget> highRating = [];
  List<Widget> popular = [];

  String words;
  @override
  void initState() {
    super.initState();
    print('主页面初始化');
    _getBookListHighRating();
    _getBookListPersonal();
    _getBookListPopular();
  }

  _getBookListPersonal() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlPersonal = ApiTypeValues[APIType.BooklistInit] + '/personal';

    try {
      Response response = await dio.get(urlPersonal, queryParameters: {
        "limit": 3,
      });
      setState(() {
        var data = response.data;
        if (data != null) {
          for (var elem in data) {
            this.personal.add(picAndTextButton(
                elem["coverImgUrl"], elem["bookName"], elem["bookId"]));
          }
        }
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 412) {
          print('数据格式错误');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  _getBookListPopular() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlPopular = ApiTypeValues[APIType.BooklistInit] + '/popular';
    try {
      Response response = await dio.get(urlPopular, queryParameters: {
        "limit": 3,
      });
      try {
        setState(() {
          var data = response.data;
          if (data != null) {
            for (var elem in data) {
              this.popular.add(picAndTextButton(
                  elem["coverImgUrl"], elem["bookName"], elem["bookId"]));
            }
          }
        });
      } catch (e) {}
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 412) {
          print('数据格式错误');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  _getBookListHighRating() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlHighrating = ApiTypeValues[APIType.BooklistInit] + '/highRating';
    try {
      Response response = await dio.get(urlHighrating, queryParameters: {
        "limit": 3,
      });
      setState(() {
        var data = response.data;
        if (data != null) {
          for (var elem in data) {
            this.highRating.add(picAndTextButton(
                elem["coverImgUrl"], elem["bookName"], elem["bookId"]));
          }
        }
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 412) {
          print('数据格式错误');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  _getBookInfo(String bookid) async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.BookInfo] + '/' + bookid;
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        print(response.statusCode);
        print(response.data);
        Navigator.pushNamed(context, '/bookinfo', arguments: response.data);
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 412) {
          print('数据格式错误');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  Widget picAndTextButton(String imgpath, String bookname, String bookid) {
    return Container(
        decoration: new BoxDecoration(
          border: new Border.all(width: 2.0, color: Colors.grey),
          color: Colors.white,
          borderRadius: new BorderRadius.all(new Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey, //底色,阴影颜色
              offset: Offset(0, 0), //阴影位置,从什么位置开始
              blurRadius: 1, // 阴影模糊层度
              spreadRadius: 1, //阴影模糊大小
            )
          ],
        ),
        padding: EdgeInsets.all(ScreenUtil().setSp(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: ScreenUtil().setHeight(300),
                width: ScreenUtil().setWidth(240),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage(imgpath), fit: BoxFit.fill),
                ),
                // alignment: Alignment.center,
                child: Container(
                  height: ScreenUtil().setHeight(300),
                  width: ScreenUtil().setWidth(240),
                  child: FlatButton(
                    onPressed: () {
                      _getBookInfo(bookid);
                    },
                    child: Text(
                      '',
                    ),
                  ),
                )),
            SizedBox(
              height: ScreenUtil().setHeight(8),
            ),
            Container(
              height: ScreenUtil().setHeight(50),
              width: ScreenUtil().setWidth(240),
              child: Text(
                bookname,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: ScreenUtil().setSp(40)),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    Widget search = new Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10), right: ScreenUtil().setSp(10)),
      child: Row(
        children: [
          Expanded(
              child: Container(
            color: Colors.white,
            height: ScreenUtil().setHeight(135),
            child: OutlineButton(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.only(left: ScreenUtil().setSp(20)),
                  child: Row(
                    children: [
                      Icon(
                        IconFont.search,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "搜索图书",
                        style: TextStyle(color: MyColors.text, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                }),
          ))
        ],
      ),
    );
    Widget booklistPersonal = new Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: this.personal));
    Widget booklistPopular = new Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: this.popular,
    ));
    Widget booklistHighRating = new Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: this.highRating,
    ));
    Widget divider = new Divider(
      // height: 2,
      // thickness: 1,
      color: Colors.grey,
    );
    Widget textField1 = new Container(
      width: double.infinity,
      padding: EdgeInsets.only(right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '个性推荐',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(60),
            ),
          ),
          Container(
            height: ScreenUtil().setHeight(90),
            child: OutlineButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booklist1');
              },
              child: Text(
                "更多>>",
                style: TextStyle(
                  color: MyColors.text,
                  fontSize: ScreenUtil().setSp(50),
                ),
              ),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
              textTheme: ButtonTextTheme.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
    Widget textField2 = new Container(
      width: double.infinity,
      padding: EdgeInsets.only(right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '热度推荐',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(60),
            ),
          ),
          Container(
            height: ScreenUtil().setHeight(90),
            child: OutlineButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booklist2');
              },
              child: Text(
                "更多>>",
                style: TextStyle(
                  color: MyColors.text,
                  fontSize: ScreenUtil().setSp(50),
                ),
              ),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
              textTheme: ButtonTextTheme.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
    Widget textField3 = new Container(
      width: double.infinity,
      padding: EdgeInsets.only(right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '高分推荐',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(60),
            ),
          ),
          Container(
            height: ScreenUtil().setHeight(90),
            child: OutlineButton(
              onPressed: () {
                Navigator.pushNamed(context, '/booklist3');
              },
              child: Text(
                "更多>>",
                style: TextStyle(
                  color: MyColors.text,
                  fontSize: ScreenUtil().setSp(50),
                ),
              ),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
              textTheme: ButtonTextTheme.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        automaticallyImplyLeading: false, //去掉leading位置的返回箭头
        title: Text(
          "首页",
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(60)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
        child: ListView(
          children: [
            SizedBox(
              height: ScreenUtil().setHeight(50),
            ),
            search,
            SizedBox(
              height: ScreenUtil().setHeight(50),
            ),
            textField1,
            divider,
            booklistPersonal,
            divider,
            SizedBox(
              height: ScreenUtil().setHeight(50),
            ),
            textField2,
            divider,
            booklistPopular,
            divider,
            SizedBox(
              height: ScreenUtil().setHeight(50),
            ),
            textField3,
            divider,
            booklistHighRating,
            divider,
            SizedBox(
              height: ScreenUtil().setHeight(50),
            ),
          ],
        ),
      ),
    );
  }
}
