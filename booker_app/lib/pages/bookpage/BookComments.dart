import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            size: 14,
            color: Colors.black,
          ),
          ClipRect(
              child: Align(
            alignment: Alignment.topLeft,
            widthFactor: factor,
            child: Icon(
              IconFont.star,
              size: 14,
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
                    width: 50, height: 50, fit: BoxFit.fill),
              ),
            ),
            title: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nickname,
                    style: TextStyle(fontSize: 22),
                  ),
                  Row(
                    children: _getGradeStar(_rating, 10),
                  ),
                  Row(
                    children: [
                      Text(_commentTime),
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
                  color: !this._islike ? Colors.grey : MyColors.primary),
              label: Text('${this._likenum}'),
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
          ),
        ]));
  }
}

class BookComments extends StatefulWidget {
  final Map arguments;
  BookComments({this.arguments});

  @override
  _BookCommentsState createState() => _BookCommentsState();
}

class _BookCommentsState extends State<BookComments> {
  List comments = [];
  DateTime _now = DateTime.now();
  var _islike = false;
  int _likenum = 2888;
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
            color: Colors.grey,
          ),
          ClipRect(
              child: Align(
            alignment: Alignment.topLeft,
            widthFactor: factor,
            child: Icon(
              IconFont.star,
              size: 12,
              color: Colors.yellow,
            ),
          ))
        ],
      );
      _list.add(_st);
    }
    return _list;
  }

  _getCommentsList() async {
    var bookid = widget.arguments["bookId"];
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.Comment] + '/list/' + bookid;
    try {
      Response response = await dio.get(url);
      setState(() {
        this.comments = response.data;
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          print('token失效');
        } else if (e.response.statusCode == 404) {
          print(' 图书不存在');
        } else {}
      } else {
        print('请求失败');
      }
    }
  }

  List<Widget> _getComments() {
    List<Widget> commentList = [];
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

  void initState() {
    super.initState();
    this._getCommentsList();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
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
            "全部书评",
            style: TextStyle(
                color: Colors.black, fontSize: ScreenUtil().setSp(60)),
          ),
          // centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  height: ScreenUtil().setHeight(100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "全部评论",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(60)),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(new Radius.circular(8)),
                  ),
                  height: ScreenUtil().setHeight(1910),
                  child: ListView(
                    children: this._getComments(),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
