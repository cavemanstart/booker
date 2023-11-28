import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:booker_app/tools/ratingStarts/star.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../tools/ratingStarts/custom_rating.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyComments extends StatefulWidget {
  final Map arguments;
  MyComments({this.arguments});
  @override
  _MyCommentsState createState() => _MyCommentsState();
}

class _MyCommentsState extends State<MyComments> {
  List _tagListInfo = [];
  String _publishInfo;
  var _bookName;
  var _subtitle;
  var _imgageUrl;
  var _rating;
  final commentController = TextEditingController();
  List<Widget> sign = [
    Text(
      '很不好看',
      style: TextStyle(fontSize: 16, color: MyColors.purple),
    ),
    Text(
      '不好看',
      style: TextStyle(fontSize: 16, color: MyColors.purple),
    ),
    Text(
      '一般',
      style: TextStyle(fontSize: 16, color: MyColors.purple),
    ),
    Text(
      '好看',
      style: TextStyle(fontSize: 16, color: MyColors.purple),
    ),
    Text(
      '很好看',
      style: TextStyle(fontSize: 16, color: MyColors.purple),
    ),
  ];
  int idx = 4;
  @override
  void initState() {
    super.initState();
    this._rating = 10;
    this._bookName = widget.arguments["book"]["bookName"];
    this._subtitle = widget.arguments["book"]["subtitle"];
    this._imgageUrl = widget.arguments["book"]["coverImgUrl"];
    this._tagListInfo = widget.arguments["book"]["tags"];
    this._getPublishInfo();
  }

  _getPublishInfo() {
    var author = widget.arguments['book']['author'];
    var publisher = widget.arguments['book']['publisher'];
    var pubDate = widget.arguments['book']['publishDate'];
    var pageNum = widget.arguments['book']['pageNum'];
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
    this._publishInfo = infoList.join("/");
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
        Navigator.popAndPushNamed(context, '/bookinfo',
            arguments: response.data);
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

  List<Widget> _getTags() {
    List<Widget> list = [];
    for (var i = 0; i < _tagListInfo.length; ++i) {
      RawChip rc = new RawChip(
        label: Text(_tagListInfo[i]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: MyColors.primary,
      );
      list.add(rc);
    }
    return list;
  }

  _publishComment() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.Comment];
    try {
      Response response = await dio.post(url, queryParameters: {
        "bookId": widget.arguments["book"]["bookId"],
      }, data: {
        "content": commentController.text,
        "tags": this._tagListInfo,
        "rating": this._rating,
      });
      this._getBookInfo(widget.arguments["book"]["bookId"]);
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
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    Widget bookInfo = new Container(
      decoration: new BoxDecoration(
        color: MyColors.grey,
      ),
      padding: EdgeInsets.only(
          bottom: ScreenUtil().setSp(20), left: ScreenUtil().setSp(20)),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
                padding: EdgeInsets.only(
                  right: 10,
                  top: 10,
                ),
                child: AspectRatio(
                  aspectRatio: 0.75,
                  child: Image.network(widget.arguments['book']['coverImgUrl'],
                      fit: BoxFit.fill),
                )),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.only(top: 10),
              // height: ScreenUtil().setHeight(450),
              child: ListTile(
                title: Text(
                  widget.arguments['book']['bookName'],
                  style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                ),
                subtitle: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: widget.arguments['book']['subtitle'] == null
                              ? Container(
                                  height: 0,
                                  width: 0,
                                )
                              : Text(widget.arguments['book']['subtitle'],
                                  style: TextStyle(fontSize: 12)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(this._publishInfo,
                              style: TextStyle(fontSize: 11)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
    Widget myRating = new Card(
      elevation: 5, //阴影
      shape: const RoundedRectangleBorder(
        //形状
        //修改圆角
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.only(top: 20, right: 5, left: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 5, top: 15, bottom: 15),
              // width: 150,
              child: Text(
                '  星级评分  ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              // width: 200,
              // padding: EdgeInsets.all(10),
              child: CustomRating(
                  star: Star(
                      num: 5,
                      fillColor: Colors.yellow,
                      fat: 0.6,
                      emptyColor: Colors.grey.withAlpha(88)),
                  onRating: (s) {
                    setState(() {
                      idx = s.round() - 1;
                      this._rating = (idx + 1) * 2;
                      print(this._rating);
                    });
                  }),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
              child: sign[idx],
            ),
            flex: 2,
          )
        ],
      ),
    );
    Widget chooseTags = new Container(
      padding: EdgeInsets.only(left: ScreenUtil().setSp(40),right: ScreenUtil().setSp(40),top:ScreenUtil().setSp(10)),
      margin: EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: new Border.all(width: 2.0, color: Colors.grey[300]),
        borderRadius: new BorderRadius.all(new Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 2,top:8),
            child: Text(
                    '书籍标签',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
          Container(
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 5,
              runSpacing: -8,
              children: _getTags(),
            ),
          )
        ],
      ),
    );
    Widget commentArea = new Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: new Border.all(width: 2.0, color: Colors.grey[300]),
        borderRadius: new BorderRadius.all(new Radius.circular(12)),
      ),
      height: 400,
      child: Container(
         padding: EdgeInsets.only(left: ScreenUtil().setSp(50),right: ScreenUtil().setSp(50),top:ScreenUtil().setSp(20)),
        child: TextFormField(
          keyboardType: TextInputType.text,
          maxLength: 500,
          maxLines: 18,
          controller: commentController,
          decoration: InputDecoration(
            hintText: ' ✏️ 在这里评价这本书哦 ',
            enabledBorder: new UnderlineInputBorder(
              // 不是焦点的时候颜色
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            focusedBorder: new UnderlineInputBorder(
              // 焦点集中的时候颜色
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
          )),
      )
    );
    return Container(
      child: Scaffold(
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
          title: Text("图书评价",
              style: TextStyle(
                  color: Colors.black, fontSize: ScreenUtil().setSp(60))),
          // centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: FlatButton(
                  onPressed: () {
                    _publishComment();
                  },
                  child: Text(
                    '发布',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(60),
                        color: MyColors.primary),
                  )),
            )
          ],
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40),
              right: ScreenUtil().setSp(40),
              top: ScreenUtil().setSp(40)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(new Radius.circular(8)),
          ),
          child: ListView(
            children: [
              bookInfo,
              myRating,
              chooseTags,
              commentArea,
            ],
          ),
        ),
      ),
    );
  }
}
