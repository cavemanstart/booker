import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:booker_app/tools/StringUtil.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../mydio/config.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var _email;
  var _myCode;
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodeCheckCode = new FocusNode();
  TextEditingController _emailController = new TextEditingController();
  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isShowClear = false; //是否显示输入框尾部的清除按钮
  @override
  void initState() {
    //设置焦点监听
    _focusNodeEmail.addListener(_focusNodeListener);
    _focusNodeCheckCode.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _emailController.addListener(() {
      // print(_emailController.text);
      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_emailController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // 移除焦点监听
    _focusNodeEmail.removeListener(_focusNodeListener);
    _focusNodeCheckCode.removeListener(_focusNodeListener);
    _emailController.dispose();
    super.dispose();
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodeEmail.hasFocus) {
      print("邮箱框获取焦点");
      _focusNodeCheckCode.unfocus();
    }
    if (_focusNodeCheckCode.hasFocus) {
      print("验证码框获取焦点");
      _focusNodeEmail.unfocus();
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

  bool _validatorEmail(email) {
    email = _email;
    if (email == '' || email == null) {
      _alertDialog('请输入邮箱');
      return false;
    } else if (!StringUtil.isEmail(email)) {
      _alertDialog('邮箱格式错误');
      return false;
    }
    return true;
  }

  bool _validatorYzm(code) {
    code = _myCode;
    if (code == '' || code == null) {
      _alertDialog('请填入验证码');
      return false;
    }
    return true;
  }

  _getYzm() async {
    Dio dio = new Dio();
    String url = ApiTypeValues[APIType.GetYzm];
    try {
      Response response =
          await dio.get(url, queryParameters: {'email': _email});
      print(response.data.toString());
      print(response.statusCode);
      setState(() {
        Token.token = response.data;
      });
    } on DioError catch (e) {
      if (e.response.statusCode == 412) {
        print('邮箱格式错误');
        _alertDialog('邮箱格式错误');
      } else {
        print(e.message);
        _alertDialog('获取验证码失败');
      }
    }
  }

  _confirmYzm() async {
    Dio dio = new Dio();
    String url = ApiTypeValues[APIType.ConfirmYzm];
    FormData formData = FormData.fromMap({
      "authCode": _myCode,
      "email": _email,
    });
    print(_myCode);
    dio.options.headers['token'] = Token.token;
    try {
      Response response = await dio.post(
        url,
        data: formData,
      );
      print(response.data);
      print(response.statusCode);
      setState(() {
        Navigator.of(context).pushReplacementNamed('/register2',
            arguments: {'email': _email, 'authorCode': _myCode});
      });
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        print('token失效');
      } else if (e.response.statusCode == 403) {
        print('邮箱错误');
      } else if (e.response.statusCode == 406) {
        print('验证码错误');
      } else {
        print(e.message);
      }
    }
  }

  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    Widget cheakEmailArea = new Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: MyColors.grey,
        ),
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
        child: ListView(
          children: <Widget>[
            new Form(
              key: _formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Container(
                    height: ScreenUtil().setHeight(135),
                    width: double.infinity,
                    margin: EdgeInsets.only(top: ScreenUtil().setSp(150)),
                    child: TextFormField(
                      focusNode: _focusNodeEmail,
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "邮箱",
                        hintStyle: TextStyle(fontSize: ScreenUtil().setSp(40)),
                        prefixIcon: Icon(
                          IconFont.email,
                          size: 20,
                        ),
                        // 是否显示密码
                        suffixIcon: (_isShowClear)
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  // 清空输入框内容
                                  _emailController.clear();
                                  setState(() {
                                    _email = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      // obscureText: !_isShowPwd,
                      //密码验证
                      // validator: validatePassWord,
                      //保存数据
                      onChanged: (String value) {
                        setState(() {
                          _email = value;
                        });
                        // print(_email);
                      },
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Container(
                      height: ScreenUtil().setHeight(135),
                      width: double.infinity,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(650),
                            child: TextFormField(
                              focusNode: _focusNodeCheckCode,
                              decoration: InputDecoration(
                                hintText: "验证码",
                                hintStyle:
                                    TextStyle(fontSize: ScreenUtil().setSp(50)),
                                prefixIcon: Icon(
                                  IconFont.yzm,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  _myCode = value;
                                });
                                // print(_checkCode);
                              },
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(40),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(300),
                            child: RaisedButton(
                              onPressed: () {
                                _focusNodeEmail.unfocus();
                                _focusNodeCheckCode.unfocus();
                                _formKey.currentState.save();
                                print("$_email + $_myCode");
                                if (_validatorEmail(_email)) {
                                  _getYzm();
                                }
                              },
                              color: Colors.white,
                              child: Text(
                                "获取验证码",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 12),
                              ),
                              textTheme: ButtonTextTheme.accent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          )
                        ],
                      )),
                  SizedBox(
                    height: ScreenUtil().setHeight(150),
                  ),
                ],
              ),
            ),
            Container(
              height: ScreenUtil().setHeight(120),
              child: RaisedButton(
                  color: MyColors.primary,
                  child: Text(
                    "下一步",
                    style: TextStyle(
                        color: Colors.white, fontSize: ScreenUtil().setSp(60)),
                  ),
                  // 设置按钮圆角
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed: () {
                    if (_validatorEmail(_email)) {
                      if (_validatorYzm(_myCode)) {
                        _confirmYzm()();
                      }
                    }
                    // Navigator.of(context).pushReplacementNamed('/register2');
                  }),
            )
          ],
        ));
    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        title: Text(
          "绑定邮箱",
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(60)),
        ),
        // centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              IconFont.back,
              color: Colors.black,
            )),
        // textTheme: TextTheme(headline5: ),
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          // 点击空白区域，回收键盘
          print("点击了空白区域");
          _focusNodeEmail.unfocus();
          _focusNodeCheckCode.unfocus();
        },
        child: cheakEmailArea,
      ),
    );
  }
}
