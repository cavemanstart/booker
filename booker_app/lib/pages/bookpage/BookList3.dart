import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookList3 extends StatefulWidget {
  BookList3({Key key}) : super(key: key);

  @override
  _BookList3State createState() => _BookList3State();
}

class _BookList3State extends State<BookList3> {
  List<Widget> bookList = [];
  @override
  void initState() {
    super.initState();
    _getBookList();
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

  String _getPublishInfo(author, publisher, pubDate) {
    List<String> infoList = [];
    if (author != null) {
      infoList.add(author);
    }
    if (publisher != null) {
      infoList.add(publisher);
    }
    if (pubDate != null) {
      DateTime date_show = DateTime.parse(pubDate);
      infoList.add(date_show.year.toString() +
          "-" +
          date_show.month.toString() +
          "-" +
          date_show.day.toString());
    }
    return infoList.join("/");
  }

  _getBookList() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlHighrating = ApiTypeValues[APIType.BooklistInit] + '/highRating';
    try {
      Response response = await dio.get(urlHighrating, queryParameters: {
        "limit": 50,
      });
      setState(() {
        this.bookList = [];
        var data = response.data;
        print(data);
        if (data != null) {
          for (var elem in data) {
            this.bookList.add(bookcard(elem));
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

  Widget bookcard(var bookItem) {
    return new Card(
        elevation: 5, //阴影
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        margin: EdgeInsets.only(
            left: ScreenUtil().setSp(20),
            right: ScreenUtil().setSp(20),
            top: ScreenUtil().setSp(40)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.all(15),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: Image.network(bookItem["coverImgUrl"],
                        fit: BoxFit.fill),
                  )),
            ),
            Expanded(
                flex: 5,
                child: Container(
                  child: ListTile(
                    title: Text(
                      bookItem["bookName"],
                      style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: bookItem["subtitle"] == null
                                  ? Container(width: 0, height: 0)
                                  : Text(
                                      bookItem["subtitle"],
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(40)),
                                    ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getPublishInfo(
                                  bookItem["author"],
                                  bookItem["publisher"],
                                  bookItem["publishDate"],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(35)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 30,
                    ),
                    onTap: () {
                      _getBookInfo(bookItem["bookId"]);
                    },
                  ),
                ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              IconFont.back,
              color: Colors.black,
            )),
        title: Text(
          "高分推荐",
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(60)),
        ),
        // centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(40),
            right: ScreenUtil().setSp(40),
            top: ScreenUtil().setSp(40)),
        child: ListView(
          children: this.bookList,
        ),
      ),
    );
  }
}
