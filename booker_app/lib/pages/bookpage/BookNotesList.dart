import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookNotesList extends StatefulWidget {
  final Map arguments;
  BookNotesList({this.arguments});

  @override
  _BookNotesListState createState() => _BookNotesListState();
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX; // X方向的偏移量
  double offsetY; // Y方向的偏移量
  CustomFloatingActionButtonLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}

class _BookNotesListState extends State<BookNotesList> {
  var _bookInfo;
  var _notesList = [];

  _getBookInfo(String bookid) async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.BookInfo] + '/' + bookid;
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        this._bookInfo = response.data;
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

  _getnotesList(String bookid) async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.Note] + '/list/' + bookid;
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        this._notesList = response.data;
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

  List<Widget> _getGradeStar(double score, double total) {
    score = score / 2.0;
    total = total / 2;
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
            size: 14,
            color: Colors.grey,
          ),
          ClipRect(
              child: Align(
            alignment: Alignment.topLeft,
            widthFactor: factor,
            child: Icon(
              IconFont.star,
              size: 14,
              color: Colors.yellow,
            ),
          ))
        ],
      );
      _list.add(_st);
    }
    return _list;
  }

  List<Widget> _getNotes() {
    List<Widget> _list = [];
    for (var elem in this._notesList) {
      Widget mynotes = new Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: ScreenUtil().setHeight(100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(elem["title"],
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                      Container(
                        width: ScreenUtil().setWidth(200),
                        child: IconButton(
                            icon: Icon(
                              IconFont.write,
                              size: 22,
                              color: Colors.grey[700],
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, "/updatenotes",
                                  arguments: {
                                    "bookId": widget.arguments["bookId"],
                                    "noteId": elem["noteId"],
                                    "title": elem["title"],
                                    "content": elem["content"]
                                  }).then((value) async {
                                await this._getnotesList(value);
                              });
                            }),
                      ),
                    ],
                  )),
              Container(
                height: ScreenUtil().setHeight(180),
                child: Text(
                  elem["content"],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(400),
                      child: Text(
                        elem["editTime"],
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(200),
                      child: IconButton(
                          icon: Icon(
                            IconFont.delete,
                            color: MyColors.danger,
                            size: 20,
                          ),
                          onPressed: () {
                            this._removeNote(elem["noteId"]);
                          }),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
              )
            ],
          ));
      _list.add(mynotes);
    }
    return _list;
  }

  _removeNote(noteId) async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlPersonal = ApiTypeValues[APIType.Note] + '/' + noteId.toString();
    try {
      Response response = await dio.delete(urlPersonal);
      setState(() {
        Fluttertoast.showToast(
            msg: "删除读书笔记成功",
            timeInSecForIos: 1,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: MyColors.info,
            textColor: MyColors.text,
            fontSize: 16.0);
        Navigator.popAndPushNamed(context, "/booknoteslist",
            arguments: {"bookId": widget.arguments["bookId"]});
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 404) {
          print('评论不存在');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  Widget _getBookInfoTitle() {
    return new Container(
      // height: ,
      // decoration: new BoxDecoration(
      // border: new Border.all(width: 2.0, color: Colors.grey),
      // color: MyColors.grey,
      // borderRadius: new BorderRadius.all(new Radius.circular(8)),
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.grey, //底色,阴影颜色
      //     offset: Offset(0, 0), //阴影位置,从什么位置开始
      //     blurRadius: 1, // 阴影模糊层度
      //     spreadRadius: 1, //阴影模糊大小
      //   )
      // ],
      // ),
      // padding: EdgeInsets.all(10),
      // width: ScreenUtil().setWidth(700),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: ScreenUtil().setWidth(135),
            decoration: BoxDecoration(
                // border: new Border.all(width: 2.0, color: Colors.grey),
                borderRadius: new BorderRadius.all(new Radius.circular(12)),
                image: DecorationImage(
                    image: NetworkImage(this._bookInfo["book"]["coverImgUrl"]),
                    fit: BoxFit.cover)),
            // padding: EdgeInsets.only(left: 10, right: 10),
            height: ScreenUtil().setHeight(150),
            child: Text(''),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(30),
          ),
          Container(
              height: ScreenUtil().setHeight(200),
              width: ScreenUtil().setWidth(335),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(this._bookInfo["book"]["bookName"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontSize: 14)),
                    height: ScreenUtil().setHeight(100),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(70),
                    child: Row(
                      children: _getGradeStar(
                          this._bookInfo["ratingStatics"]["meanRating"], 10),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  _removeFromShelf() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.BookInfo] +
        "/user-book/" +
        widget.arguments['bookId'];
    try {
      Response response = await dio.delete(url);
      setState(() {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "移除书架成功",
            timeInSecForIos: 1,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: MyColors.info,
            textColor: MyColors.text,
            fontSize: 16.0);
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

  @override
  void initState() {
    super.initState();
    this._getBookInfo(widget.arguments["bookId"]);
    this._getnotesList(widget.arguments["bookId"]);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                IconFont.back,
                color: Colors.black,
              )),
          title: this._bookInfo == null
              ? Container(height: 80)
              : _getBookInfoTitle(),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 2),
              child: FlatButton(
                  onPressed: () {
                    this._removeFromShelf();
                  },
                  child: Text('移除书架',
                      style: TextStyle(
                          color: Colors.red[600],
                          fontSize: ScreenUtil().setHeight(50)))),
            )
          ],
          backgroundColor: Colors.white,
        ),
        body: Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2.0, color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: ListView(
            children: _getNotes(),
          ),
        ),
        floatingActionButton: Container(
          height: 70,
          width: 70,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40), color: Colors.white),
          child: FloatingActionButton(
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
            backgroundColor: MyColors.primary,
            onPressed: () {
              Navigator.pushNamed(context, '/addnotes',
                  arguments: widget.arguments);
            },
          ),
        ),
        floatingActionButtonLocation: CustomFloatingActionButtonLocation(
            FloatingActionButtonLocation.endFloat, -20, -75),
      ),
    );
  }
}
