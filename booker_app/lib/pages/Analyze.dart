import 'dart:math';
import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/MyDialog.dart';

class Analyze extends StatefulWidget {
  @override
  _AnalyzeState createState() => _AnalyzeState();
}

class _AnalyzeState extends State<Analyze> {
  List<String> _tagListInfo = [];
  List<int> dataList = [
    100,
    100,
    100,
    100,
    100,
    100,
    100,
    100,
    100,
    100,
    100,
    100
  ];
  int _hasReadedNum = 1;
  var _planNum = 1;
  String xText = '月';
  List<String> bottomTextList = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];
  _showDialog() async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return MyDialog();
        });
    print(result);
  }

  _getAnalysis() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String planUrl = ApiTypeValues[APIType.Analysis] + '/reading-plan';
    String historyUrl = ApiTypeValues[APIType.Analysis] + "/read-history";
    String interestUrl = ApiTypeValues[APIType.Analysis] + "/interest-tags";
    try {
      Response responsePlan = await dio.get(planUrl);
      Response responseHistory = await dio.get(historyUrl);
      Response responseInterest = await dio.get(interestUrl);
      setState(() {
        this._planNum = responsePlan.data;
        this.dataList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        for (int i = 0; i < responseHistory.data.length; i++) {
          this.dataList[i] += responseHistory.data[i];
        }
        this._hasReadedNum = 0;
        for (var elem in this.dataList) {
          this._hasReadedNum += elem;
        }
        this._tagListInfo = [];
        for (var elem in responseInterest.data) {
          this._tagListInfo.add(elem);
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

  @override
  void initState() {
    super.initState();
    this._getAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    Widget readingPlan = new Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ScreenUtil().setWidth(180),
                  child: Icon(
                    IconFont.plan,
                    size: 30,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(720),
                  child: ListTile(
                    title: Text(
                      '阅读计划',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(60),
                          fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '在下方制定你的年度阅读计划吧',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(42),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5, //阴影
            shape: const RoundedRectangleBorder(
              //形状
              //修改圆角
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: EdgeInsets.only(top: 4, left: 5, right: 5),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  height: ScreenUtil().setHeight(120),
                  child: Text('2021年已完成阅读书籍${this._hasReadedNum}本',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(60),
                      )),
                ),
                Container(
                  height: ScreenUtil().setHeight(100),
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 10,
                  ),
                  child: Stack(
                    children: [
                      ///灰色线进度条
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: ScreenUtil().setHeight(120),
                        width: ScreenUtil().setWidth(800),
                        decoration: BoxDecoration(
                          color: Color(0xffD7D7D7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: ScreenUtil().setHeight(120),
                        width: ScreenUtil().setWidth(800) *
                            (this._planNum == 0
                                ? 0
                                : (((this._hasReadedNum / this._planNum) > 1.0
                                    ? 1
                                    : (this._hasReadedNum / this._planNum)))),
                        decoration: BoxDecoration(
                          color: MyColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, top: 5),
                  height: ScreenUtil().setHeight(80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(200),
                        child: Text(
                            '${this._planNum == 0 ? 0 : ((this._hasReadedNum * 100) / this._planNum).round() > 100 ? 100 : ((this._hasReadedNum * 100) / this._planNum).round()}%',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(50))),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(300),
                        child: Text('${this._hasReadedNum}/${this._planNum}本',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(50))),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(180),
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        style: ButtonStyle(
                            side: MaterialStateProperty.all(
                                BorderSide(width: 2, color: Colors.grey[400])),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            )),
                        icon: Icon(
                          IconFont.myplan,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _showDialog().then((score) async {
                            this._getAnalysis();
                          });
                        },
                        label: Text('制定计划',
                            style: TextStyle(
                                color: MyColors.dark,
                                fontSize: ScreenUtil().setSp(42))),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
    List<Widget> _getRectangle() {
      List<Widget> list = [];
      Container first = new Container(
        width: ScreenUtil().setWidth(60),
        height: ScreenUtil().setHeight(400),
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(20)),
        child: Text(
          '本/每月',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
          ),
        ),
      );
      Container last = new Container(
        width: ScreenUtil().setWidth(200),
        height: ScreenUtil().setHeight(450),
        padding: EdgeInsets.only(left: ScreenUtil().setSp(30)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Positioned(
              top: 50,
              child: Text(
                '2021年',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(50),
                    fontWeight: FontWeight.w600),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '月份',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(25),
                ),
              ),
            ),
          ],
        ),
      );
      list.add(first);
      for (var i = 0; i < 12; i++) {
        Container stack = new Container(
          margin: EdgeInsets.only(
              left: ScreenUtil().setSp(12), top: ScreenUtil().setSp(40)),
          width: ScreenUtil().setWidth(42),
          height: ScreenUtil().setHeight(400),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 10,
                child: Container(
                  height: ScreenUtil().setHeight(400),
                  width: ScreenUtil().setWidth(42),
                  decoration: BoxDecoration(
                    color: Color(0xffD7D7D7),
                    // borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Container(
                  height: dataList[i] /
                      dataList.reduce(max) *
                      ScreenUtil().setHeight(360),
                  alignment: Alignment.topCenter,
                  width: ScreenUtil().setWidth(42),
                  decoration: BoxDecoration(
                    color: dataList[i] > 10
                        ? Colors.blue[700]
                        : (dataList[i] > 5 && dataList[i] <= 10
                            ? Colors.blue[400]
                            : Colors.blue[100]),
                    // borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(dataList[i]).round()}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  bottomTextList[i],
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                  ),
                ),
              ),
            ],
          ),
        );
        list.add(stack);
      }
      list.add(last);
      return list;
    }

    List<Widget> _getTags() {
      List<Widget> list = [];
      for (var i = 0; i < _tagListInfo.length; ++i) {
        RawChip rc = new RawChip(
          label: Text(_tagListInfo[i]),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.yellow[400],
        );
        list.add(rc);
      }
      return list;
    }

    Widget readingCounts = new Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(ScreenUtil().setSp(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ScreenUtil().setWidth(180),
                  child: Icon(
                    IconFont.counts,
                    size: 30,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(720),
                  child: ListTile(
                    title: Text(
                      '阅读统计',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(60),
                          fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '每个月份阅读书籍数量',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(42),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: ScreenUtil().setHeight(500),
            margin: EdgeInsets.only(left: 5, right: 5),
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 10,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2, color: Colors.grey[300]),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: _getRectangle(),
            ),
          )
        ],
      ),
    );
    Widget tags = new Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(ScreenUtil().setSp(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ScreenUtil().setWidth(180),
                  child: Icon(
                    IconFont.plan,
                    size: 30,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(720),
                  child: ListTile(
                    title: Text(
                      '兴趣标签',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(60),
                          fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '统计您最感兴趣的标签',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(42),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2, color: Colors.grey[300]),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              runSpacing: 0,
              children: _getTags(),
            ),
          )
        ],
      ),
    );
    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        automaticallyImplyLeading: false, //去掉leading位置的返回箭头
        title: Text("阅读分析",
            style: TextStyle(
                fontSize: ScreenUtil().setHeight(60), color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: ListView(
          children: [
            readingPlan,
            readingCounts,
            tags,
          ],
        ),
      ),
    );
  }
}
