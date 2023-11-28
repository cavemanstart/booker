import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:booker_app/tools/pickCalendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:date_format/date_format.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';
import '../mydio/config.dart';

class Register3 extends StatefulWidget {
  Register3({Key key, this.arguments}) : super(key: key);
  final Map arguments;
  @override
  _Register3State createState() => _Register3State();
}

class _Register3State extends State<Register3> {
  bool isCheckCompany = false;
  int sex = 0;
  int year = 2000;
  int month = 1;
  int day = 1;
  int age = 21;
  String birthdate = '';
  String job;
  var nickname;
  List<dynamic> industyList = [];
  FocusNode _focusNodeNickName = new FocusNode();
  TextEditingController _nickNameController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _getAgeData() {
    setState(() {
      year = AgeData.year;
      month = AgeData.month;
      day = AgeData.day;
      age = AgeData.age;
      birthdate = year.toString() +
          '-' +
          (month >= 10 ? month.toString() : "0" + month.toString()) +
          '-' +
          (day >= 10 ? day.toString() : "0" + day.toString());
    });
  }

  @override
  void initState() {
    _focusNodeNickName.addListener(_focusNodeListener);

    setState(() {});
    super.initState();
    _getIndustry();
  }

  @override
  void dispose() {
    // 移除焦点监听
    _focusNodeNickName.removeListener(_focusNodeListener);

    super.dispose();
  }

  Future<Null> _focusNodeListener() async {
    if (_focusNodeNickName.hasFocus) {
      print("邮箱框获取焦点");
    }
  }

  _alertDialog(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        // timeInSecForIosWeb: 1,
        backgroundColor: MyColors.danger,
        textColor: MyColors.dark,
        fontSize: 16.0);
  }

  bool _validator() {
    if (nickname == '' || nickname == null) {
      _alertDialog('请输入昵称');
      return false;
    } else {
      if (sex == null) {
        _alertDialog('请选择性别');
        return false;
      } else {
        if (birthdate == '' || birthdate == null) {
          _alertDialog('请选择生日');
          return false;
        } else {
          if (job == '' || job == null) {
            _alertDialog('请选择行业');
            return false;
          } else {
            return true;
          }
        }
      }
    }
  }

  _getIndustry() async {
    Dio dio = new Dio();
    String url = ApiTypeValues[APIType.Company];
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        industyList = response.data;
        print('hhhhhhhhhh');
        print(industyList);
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 404) {
          _alertDialog('Not Found');
        } else if (e.response.statusCode == 401) {
          _alertDialog('授权失败');
        } else {
          _alertDialog('禁止访问');
        }
      } else {
        _alertDialog('获取行业信息失败');
      }
    }
  }

  Widget getIndusty(String industry) {
    return Container(
        height: ScreenUtil().setHeight(100),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(right: 10),
              height: ScreenUtil().setHeight(100),
              width: double.infinity,
              child: Container(
                height: ScreenUtil().setHeight(100),
                width: double.infinity,
                child: FlatButton(
                  child: Text(''),
                  onPressed: () {
                    _getChoose(industry);
                  },
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(right: 10),
                height: ScreenUtil().setHeight(100),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '         ${industry}',
                      style: TextStyle(fontSize: 16),
                    ),
                    job == industry
                        ? SizedBox(
                            width: ScreenUtil().setWidth(100),
                            child: Icon(
                              IconFont.checkOn,
                              size: 14,
                              color: Colors.grey[700],
                            ),
                          )
                        : SizedBox(
                            width: ScreenUtil().setWidth(100),
                          )
                  ],
                )),
          ],
        ));
  }

  List<Widget> getCompanyList() {
    List<Container> list = [];
    for (var i = 0; i < industyList.length; ++i) {
      list.add(getIndusty(industyList[i]));
    }
    return list;
  }

  _getChoose(String choosse) {
    setState(() {
      job = choosse;
    });
    print(job);
  }

  @override
  Widget build(BuildContext context) {
    // _getAgeData();

    Widget buildBottomSheetWidget(BuildContext context) {
      return PickBody();
    }

    showBottomSheet() {
      //用于在底部打开弹框的效果
      showModalBottomSheet(
              builder: (BuildContext context) {
                //构建弹框中的内容
                return buildBottomSheetWidget(context);
              },
              context: context)
          .then((_) {
        this._getAgeData();
      });
    }

    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        title: Text(
          "补充信息",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              IconFont.back,
              color: Colors.black,
            )),
        // centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
          onTap: () {
            // 点击空白区域，回收键盘
            _focusNodeNickName.unfocus();
            print("点击了空白区域");
            _getAgeData();
          },
          child: new Container(
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                Container(
                  child: Text(
                    "完善以下资料以提供更好的服务",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      color: MyColors.primary,
                    ),
                  ),
                  padding: EdgeInsets.only(left: 6),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
                ),
                Container(
                    height: ScreenUtil().setHeight(120),
                    child: Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(100),
                          child: Icon(
                            IconFont.user,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(140),
                          child: Text(
                            '昵称',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                            width: ScreenUtil().setWidth(600),
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _nickNameController,
                                focusNode: _focusNodeNickName,
                                decoration: InputDecoration(
                                  hintText: '给自己取个名字吧',
                                  hintStyle: TextStyle(fontSize: 16),
                                  enabledBorder: new UnderlineInputBorder(
                                    // 不是焦点的时候颜色
                                    borderSide: BorderSide(
                                      color: MyColors.dark,
                                    ),
                                  ),
                                  focusedBorder: new UnderlineInputBorder(
                                    // 焦点集中的时候颜色
                                    borderSide: BorderSide(
                                      color: MyColors.dark,
                                    ),
                                  ),
                                  //  prefixIcon: Icon
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    nickname = value;
                                  });
                                  print(nickname);
                                },
                              ),
                            ))
                      ],
                    )),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Container(
                    height: ScreenUtil().setHeight(120),
                    child: Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(100),
                          child: Icon(
                            IconFont.sex,
                            color: Colors.grey[700],
                            size: 14,
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(140),
                          child: Text(
                            '性别',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                                color: Colors.grey[700]),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(680),
                          child: Row(
                            children: <Widget>[
                              Radio(
                                // 按钮的值
                                activeColor: MyColors.primary,
                                value: 0,
                                // fillColor:,
                                // 改变事件
                                onChanged: (value) {
                                  setState(() {
                                    this.sex = value;
                                    print(sex);
                                  });
                                },
                                // 按钮组的值
                                groupValue: this.sex,
                              ),
                              Text("男"),
                              SizedBox(
                                width: 20,
                              ),
                              Radio(
                                value: 1,
                                activeColor: MyColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    this.sex = value;
                                  });
                                },
                                groupValue: this.sex,
                              ),
                              Text("女"),
                            ],
                          ),
                        )
                      ],
                    )),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Container(
                    height: ScreenUtil().setHeight(120),
                    child: Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(100),
                          child: Icon(
                            IconFont.brithday,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(140),
                          child: Text(
                            '生日',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                            width: ScreenUtil().setWidth(680),
                            child: InkWell(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${year}' +
                                        '年' +
                                        '${month}' +
                                        '月' +
                                        '${day}' +
                                        '日',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                              onTap: () {
                                showBottomSheet();
                              },
                            ))
                      ],
                    )),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Container(
                    height: ScreenUtil().setHeight(120),
                    child: Row(
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(100),
                          child: Icon(
                            IconFont.age,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(140),
                          child: Text(
                            '年龄',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: ScreenUtil().setWidth(400),
                          child: Text(
                            '${age} 岁',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                      ],
                    )),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Container(
                  height: ScreenUtil().setHeight(1000),
                  child: ExpansionTile(
                    title: Text(
                      '行业',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(IconFont.company),
                    children: [
                      Container(
                        height: ScreenUtil().setHeight(800),
                        child: ListView(
                          children: getCompanyList(),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40),
                ),
                Row(
                  children: [
                    Expanded(
                        child: RaisedButton(
                            color: MyColors.primary,
                            child: Text(
                              "下一步",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            // 设置按钮圆角
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () {
                              print(widget.arguments['account']['password']);
                              if (_validator()) {
                                Navigator.of(context).pushReplacementNamed(
                                    '/register4',
                                    arguments: {
                                      'email': widget.arguments['email'],
                                      'authorCode':
                                          widget.arguments['authorCode'],
                                      'nickname': nickname,
                                      'sex': sex,
                                      'birthdate': birthdate,
                                      'age': age,
                                      'industry': job,
                                      'account': {
                                        'password': widget.arguments['account']
                                            ['password']
                                      }
                                    });
                              }
                            })),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
