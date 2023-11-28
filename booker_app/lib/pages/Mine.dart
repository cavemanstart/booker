import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../fonts/fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class Mine extends StatefulWidget {
  Mine({Key key}) : super(key: key);
  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> {
  var username = "";
  var nickname = "";
  var gender = "";
  var age = "";
  var birthdate = "";
  var avatarUrl = "";
  var industry = "";
  var likeNum = "";
  var readNum = "";
  _getMyInfo() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.User] + "/";
    try {
      Response response = await dio.get(url);
      setState(() {
        var data = response.data;
        this.username = data["account"]["username"].toString();
        this.likeNum = data["likeNum"].toString();
        this.nickname = data["nickname"].toString();
        this.readNum = data["readNum"].toString();
        this.industry = data["industry"].toString();
        this.avatarUrl = data["headUrl"];
        this.birthdate = data["birthdate"].toString();
        this.gender = data["sex"] == 0 ? '男' : '女';
        this.age = data["age"].toString();
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

  _logout() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.User] + "/logout";
    try {
      Response response = await dio.post(url);
      setState(() {
        Navigator.of(context).popAndPushNamed("/login");
      });
    } on DioError catch (e) {
      Navigator.of(context).pop();
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
    _getMyInfo();
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
          backgroundColor: Colors.white,
          title: Text(
            "我的",
            style: TextStyle(
                color: Colors.black, fontSize: ScreenUtil().setSp(60)),
          ),
          centerTitle: true,
        ),
        body: Container(
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ScreenUtil().setHeight(500),
                padding: EdgeInsets.only(top: ScreenUtil().setSp(40)),
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1579512285,1477364538&fm=26&gp=0.jpg'),
                      fit: BoxFit.fill),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 10,
                      ),
                      height: ScreenUtil().setHeight(250),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: ClipOval(
                              child: Image.network(this.avatarUrl,
                                  width: ScreenUtil().setHeight(180),
                                  height: ScreenUtil().setHeight(180),
                                  fit: BoxFit.fill),
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(800),
                            child: ListTile(
                              title: Text(
                                this.nickname,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                'Id:${this.username}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FlatButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            icon: Icon(
                              IconFont.like,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: null,
                            label: Text(
                              this.likeNum,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          FlatButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            icon: Icon(
                              IconFont.book,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: null,
                            label: Text(this.readNum,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Card(
                  elevation: 5, //阴影
                  shape: const RoundedRectangleBorder(
                    //形状
                    //修改圆角
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: ScreenUtil().setHeight(110),
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Row(
                          children: [
                            Text('昵称',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            SizedBox(
                              width: 20,
                            ),
                            Text(this.nickname, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setHeight(110),
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text('性别',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            SizedBox(
                              width: 20,
                            ),
                            Text(this.gender, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setHeight(110),
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text('年龄',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            SizedBox(
                              width: 20,
                            ),
                            Text('${this.age}岁',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setHeight(110),
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: Row(
                          children: [
                            Text('生日',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            SizedBox(
                              width: 20,
                            ),
                            Text(this.birthdate,
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setHeight(110),
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text('行业',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            SizedBox(
                              width: 20,
                            ),
                            Text(this.industry, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(400),
                margin: EdgeInsets.only(left: 15, top: 20, right: 15),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: Colors.grey,
                      thickness: 2,
                    ),
                    Container(
                      height: ScreenUtil().setHeight(150),
                      padding: EdgeInsets.only(left: 10, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('修改密码', style: TextStyle(fontSize: 20)),
                          IconButton(
                              icon: Icon(
                                IconFont.toright,
                                size: 20,
                              ),
                              onPressed: () {Navigator.of(context).pushReplacementNamed('/setpassword');})
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: ScreenUtil().setHeight(135),
                margin: EdgeInsets.only(left: 20, top: 30, right: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: RaisedButton(
                            color: Colors.red[600],
                            child: Text(
                              "退出登录",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            // 设置按钮圆角
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () {
                              this._logout();
                            }))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
