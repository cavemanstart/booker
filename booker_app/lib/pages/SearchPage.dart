import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List searchlist = [];
  var _searchInfo;
  FocusNode _focusNodeSearch = new FocusNode();
  TextEditingController _searchController = new TextEditingController();
  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isShowClear = false; //是否显示输入框尾部的清除按钮
  @override
  void initState() {
    //设置焦点监听
    _focusNodeSearch.addListener(_focusNodeListener);
    _focusNodeSearch.hasFocus;
    //监听用户名框的输入改变
    _searchController.addListener(() {
      // print(_emailController.text);
      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_searchController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
    super.initState();
    print('搜索框获取了焦点');
    _focusNodeSearch.hasFocus;
  }

  @override
  void dispose() {
    // 移除焦点监听
    _focusNodeSearch.removeListener(_focusNodeListener);
    _searchController.dispose();
    super.dispose();
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

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodeSearch.hasFocus) {
      print("搜索框获取焦点");
    }
  }

  _alertDialog(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        // timeInSecForIosWeb: 1,
        backgroundColor: Colors.red[400],
        textColor: Colors.black,
        fontSize: 16.0);
  }

  _searchBook() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.SearchBook];
    try {
      Response response = await dio.get(url, queryParameters: {
        "searchValue": _searchInfo,
      });
      setState(() {
        if (response.data != null) {
          this.searchlist = response.data;
        }
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 404) {
          print('查询无结果');
          _alertDialog('查询无结果');
        } else if (e.response.statusCode == 401) {
          _alertDialog('未授权');
        }
      } else {
        _alertDialog("请求失败");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _getSearchList() {
      List<Widget> list = [];
      for (var elem in this.searchlist) {
        var imageUrl = elem["coverImgUrl"];
        var subtitle = elem["subtitle"];
        var author = elem['author'];
        var publisher = elem['publisher'];
        var pubDate = elem['publishDate'];
        var pageNum = elem['pageNum'];
        String bookid = elem['bookId'];
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
        if (pageNum != null) {
          infoList.add(pageNum + '页');
        }
        var publishInfo = infoList.join("/");
        Widget bookInfo = new Container(
          height: ScreenUtil().setHeight(280),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(50),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(10)),
                    image: DecorationImage(
                        image: NetworkImage(imageUrl), fit: BoxFit.cover)),
                padding: EdgeInsets.all(
                  ScreenUtil().setWidth(40),
                ),
                height: ScreenUtil().setHeight(250),
                width: ScreenUtil().setWidth(180),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(50),
              ),
              Container(
                height: ScreenUtil().setHeight(250),
                width: ScreenUtil().setWidth(600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(elem["bookName"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w300)),
                    ),
                    Container(
                      child: subtitle == null
                          ? Container(width: 0, height: 0)
                          : Text(subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              )),
                    ),
                    Container(
                      child: Text(publishInfo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                  height: ScreenUtil().setHeight(250),
                  width: ScreenUtil().setWidth(100),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_right_sharp,
                      size: 30,
                    ),
                    onPressed: () {
                      this._getBookInfo(bookid);
                    },
                  )),
            ],
          ),
        );
        list.add(bookInfo);
      }
      return list;
    }

    Widget search = new Container(
      width: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      height: ScreenUtil().setHeight(130),
      child: Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: _searchController,
            focusNode: _focusNodeSearch,
            decoration: InputDecoration(
              prefixIcon: Icon(
                IconFont.search,
                size: 20,
                color: MyColors.text,
              ),
              hintText: "搜索",
              hintStyle: TextStyle(fontSize: ScreenUtil().setSp(32)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              suffixIcon: (_isShowClear)
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        // 清空输入框内容
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchInfo = value;
                print(_searchInfo);
                _searchBook();
              });
            },
          )),
    );
    return Container(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false, //去掉leading位置的返回箭头
              title: search,
              leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    IconFont.back,
                    color: Colors.black,
                  )),
            ),
            body: GestureDetector(
                onTap: () {
                  // 点击空白区域，回收键盘
                  _focusNodeSearch.unfocus();
                },
                child: ListView(
                  padding: EdgeInsets.only(top: ScreenUtil().setSp(50)),
                  children: this.searchlist.length == 0
                      ? [
                          SizedBox(
                            height: ScreenUtil().setHeight(20),
                          ),
                          Text('      暂无搜索内容',
                              style: TextStyle(color: MyColors.text))
                        ]
                      : _getSearchList(),
                ))));
  }
}
