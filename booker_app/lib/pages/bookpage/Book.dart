import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Book extends StatefulWidget {
  Book({Key key}) : super(key: key);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String words;
  var readingList = [];
  var readedList = [];
  _getReadingList() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.BookInfo] + '/list/reading';
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        this.readingList = response.data;
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 404) {
          print('数据未找到');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  _getReadedList() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.BookInfo] + '/list/read';
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        this.readedList = response.data;
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

  List<Widget> _getReadingListData() {
    List<Widget> list = [];
    for (var elem in this.readingList) {
      list.add(
        picAndTextButton(elem["coverImgUrl"], elem["bookName"], elem["bookId"]),
      );
    }
    return list;
  }

  List<Widget> _getReadedListData() {
    List<Widget> list = [];
    for (var elem in this.readedList) {
      list.add(
        picAndTextButton(elem["coverImgUrl"], elem["bookName"], elem["bookId"]),
      );
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    this._getReadedList();
    this._getReadingList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                      print(bookid);
                      Navigator.pushNamed(context, '/booknoteslist',
                          arguments: {'bookId': bookid}).then((value) {
                        this._getReadedList();
                        this._getReadingList();
                      });
                      // _getBookInfo(bookid);
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
    Widget divider = new Divider(
      color: Colors.grey,
    );

    Widget readingGridview = new GridView.count(
      crossAxisCount: 3, //三列
      children: this._getReadingListData(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
      padding: EdgeInsets.only(left: 20, right: 30, top: 30),
      // padding: EdgeInsets.only(left: 20, right: 30, top: 30),
    );

    Widget readedGridview = new GridView.count(
      crossAxisCount: 3, //三列
      children: this._getReadedListData(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
      padding: EdgeInsets.only(left: 20, right: 30, top: 30),
    );
    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        automaticallyImplyLeading: false, //去掉leading位置的返回箭头
        title: Text(
          "我的书架",
          style: TextStyle(
              fontSize: ScreenUtil().setHeight(60),
              fontWeight: FontWeight.w200,
              color: MyColors.dark),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: TabBar(
          labelColor: MyColors.primary,
          unselectedLabelColor: MyColors.text,
          controller: _tabController,
          indicatorColor: MyColors.primary,
          tabs: [
            Tab(
              child: Text('已读',
                  style: TextStyle(
                    fontSize: ScreenUtil().setHeight(50),
                    fontWeight: FontWeight.w200,
                  )),
            ),
            Tab(
              child: Text(
                '在读',
                style: TextStyle(
                  fontSize: ScreenUtil().setHeight(50),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [readedGridview, readingGridview]),
    );
  }
}
