import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../tools/ScoreStartWidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookInfo extends StatefulWidget {
  final Map arguments;
  BookInfo({this.arguments});
  @override
  _BookInfoState createState() => _BookInfoState();
}

class Comment extends StatefulWidget {
  bool islike = false;
  int likenum = 0;
  double rating;
  String headUrl;
  int commentId;
  String commentTime;
  String content;
  String nickname;
  Comment(this.islike, this.likenum, this.rating, this.headUrl, this.commentId,
      this.commentTime, this.content, this.nickname);
  @override
  State<StatefulWidget> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool _islike = false;
  int _likenum = 0;
  double _rating;
  String _headUrl;
  int _commentId;
  String _commentTime;
  String _content;
  String _nickname;

  @override
  void initState() {
    super.initState();
    _islike = widget.islike;
    _likenum = widget.likenum;
    _rating = widget.rating;
    _headUrl = widget.headUrl;
    _commentId = widget.commentId;
    _commentTime = widget.commentTime;
    _content = widget.content;
    _nickname = widget.nickname;
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
            size: 12,
            color: Colors.black,
          ),
          ClipRect(
              child: Align(
            alignment: Alignment.topLeft,
            widthFactor: factor,
            child: Icon(
              IconFont.star,
              size: 12,
              color: MyColors.primary,
            ),
          ))
        ],
      );
      _list.add(_st);
    }
    return _list;
  }

  _addLike() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlPersonal = ApiTypeValues[APIType.Comment] + '/user-comment';
    try {
      Response response = await dio.post(urlPersonal, queryParameters: {
        "commentId": _commentId,
      });
      setState(() {
        this._islike = !this._islike;
        this._likenum++;
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 404) {
          print('评论不存在');
        } else {}
      } else {
        print(e);
      }
    }
  }

  _removeLike() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String urlPersonal = ApiTypeValues[APIType.Comment] + '/user-comment';
    try {
      Response response = await dio.delete(urlPersonal, queryParameters: {
        "commentId": _commentId,
      });
      setState(() {
        this._islike = !this._islike;
        this._likenum--;
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(children: [
          ListTile(
            leading: Container(
              child: ClipOval(
                child: Image.network(_headUrl,
                    width: ScreenUtil().setSp(150),
                    height: ScreenUtil().setSp(150),
                    fit: BoxFit.fill),
              ),
            ),
            title: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nickname,
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: _getGradeStar(_rating, 10),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Text(_commentTime, style: TextStyle(fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
            //点赞按钮
            trailing: FlatButton.icon(
              onPressed: () {
                if (this._islike) {
                  this._removeLike();
                } else {
                  this._addLike();
                }
              },
              icon: Icon(IconFont.like,
                  color: this._islike ? MyColors.primary : Colors.grey),
              label: Text('${this._likenum}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700])),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  this._content,
                  style: TextStyle(fontSize: 16),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
          ),
          Divider(
            color: Colors.grey[300],
            thickness: 2,
          ),
        ]));
  }
}

class _BookInfoState extends State<BookInfo> {
  var _publishInfo = '';

  List<Widget> _getTags() {
    List<Widget> list = [];
    for (var elem in widget.arguments['book']['tags']) {
      RawChip rc = new RawChip(
        label: Text(elem, style: TextStyle(color: MyColors.dark, fontSize: 12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: MyColors.primary,
      );
      list.add(rc);
    }
    return list;
  }

  String _getBrief() {
    var brief = widget.arguments['book']['brief'];
    String briefText = "";
    if (brief != null) {
      for (String elem in widget.arguments['book']['brief']) {
        briefText += elem;
      }
    }
    return briefText;
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

  List<Widget> _getComments() {
    List<Widget> commentList = [];
    var comments = widget.arguments['comments'];
    for (var comment in comments) {
      bool islike = comment["hasUserLiked"];
      int likenum = comment["likes"];
      double rating = comment["rating"];
      String headUrl = comment["user"]["headUrl"];
      int commentId = comment["commentId"];
      String commentTime = comment["commentTime"];
      String content = comment["content"];
      String nickname = comment["user"]["nickname"];
      commentList.add(new Comment(islike, likenum, rating, headUrl, commentId,
          commentTime, content, nickname));
    }
    return commentList;
  }

  @override
  void initState() {
    super.initState();
    _getPublishInfo();
  }

  _setReading() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.BookInfo] +
        "/user-book/" +
        widget.arguments['book']['bookId'];
    try {
      Response response = await dio.post(url);
      setState(() {
        widget.arguments["status"] = 0;
        Fluttertoast.showToast(
            msg: "添加到在读书架成功",
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
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    Widget headField = new Container(
      decoration: new BoxDecoration(
        color: MyColors.grey,
      ),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
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
            flex: 2,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 30,
                          width: 80,
                          child: RaisedButton.icon(
                            color: MyColors.grey,
                            icon: Icon(
                              IconFont.circle,
                              size: 18,
                              color: MyColors.primary,
                            ),
                            label: Text('在读', style: TextStyle(fontSize: 12)),
                            onPressed: widget.arguments["status"] == null
                                ? () {
                                    this._setReading();
                                  }
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          height: 30,
                          width: 80,
                          child: RaisedButton.icon(
                            color: MyColors.grey,
                            icon: Icon(
                              IconFont.star,
                              size: 18,
                              color: MyColors.primary,
                            ),
                            label: Text('已读', style: TextStyle(fontSize: 12)),
                            onPressed: widget.arguments["status"] == 0 ||
                                    widget.arguments["status"] == null
                                ? () {
                                    Navigator.popAndPushNamed(
                                        context, '/mycomments',
                                        arguments: widget.arguments);
                                  }
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
    var statistics = widget.arguments['ratingStatics'];
    Widget bookRating = new ScoreStartWidget(
        score: statistics["meanRating"],
        p1: statistics["oneStar"],
        p2: statistics["twoStar"],
        p3: statistics["threeStar"],
        p4: statistics["fourStar"],
        p5: statistics["fiveStar"],
        sum: statistics["sumOfRating"]);
    Widget tagField = new Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 24,
            child: Text(
              '书籍标签',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
    Widget bookSummary = new Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              padding: EdgeInsets.only(left: 10, right: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "简介",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                      icon: Icon(
                        IconFont.toright,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/bookbrief',
                            arguments: widget.arguments);
                      })
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Text(
                this._getBrief(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ));
    Widget bookCommetsField = new Container(
        // height: 400,
        // width: 400,
        width: double.infinity,
        padding: EdgeInsets.only(top: 5, bottom: 15),
        decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.grey),
          color: Colors.grey[200],
          borderRadius: new BorderRadius.all(new Radius.circular(14)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 20,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '书评',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Text(
                          '查看全部评论',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_right,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/bookcomments',
                                arguments: {
                                  "bookId": widget.arguments['book']['bookId']
                                });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: ScreenUtil().setHeight(800),
              decoration: new BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                children: this._getComments(),
              ),
            )
          ],
        ));
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
          title: Text(
            "图书详情",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          // centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: ListView(
          padding: EdgeInsets.all(ScreenUtil().setSp(40)),
          children: [
            headField,
            bookRating,
            tagField,
            SizedBox(
              height: 15,
            ),
            bookSummary,
            SizedBox(
              height: 20,
            ),
            bookCommetsField,
          ],
        ),
      ),
    );
  }
}
