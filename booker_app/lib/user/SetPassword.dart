import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:booker_app/mydio/config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetPassword extends StatefulWidget {
  SetPassword({Key key}) : super(key: key);

  @override
  _SetPasswordState createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  var _password;
  var _password2;
   var _isShowPwd = false; //是否显示密码
  var _isShowPwd2 = false; //是否显示密码
  FocusNode _focusNodePassword = new FocusNode();
  FocusNode _focusNodePassword2 = new FocusNode();
  FocusNode _focusNodeButton = new FocusNode();
  TextEditingController _passwordControler = new TextEditingController();
  TextEditingController _passwordControler2 = new TextEditingController();
  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isShowClear = false; //是否显示输入框尾部的清除按钮
  var _isShowClear2 = false; //是否显示输入框尾部的清除按钮
  @override
  void initState() {
    //设置焦点监听
    _focusNodePassword.addListener(_focusNodeListener);
    _focusNodePassword2.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _passwordControler.addListener(() {
      // print(_passwordControler.text);
      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_passwordControler.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
    _passwordControler2.addListener(() {
      // print(_passwordControler.text);
      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_passwordControler2.text.length > 0) {
        _isShowClear2 = true;
      } else {
        _isShowClear2 = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // 移除焦点监听
    _focusNodePassword.removeListener(_focusNodeListener);
    _focusNodePassword2.removeListener(_focusNodeListener);
    _passwordControler.dispose();
    _passwordControler2.dispose();
    super.dispose();
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodePassword.hasFocus) {
      print("密码框获取焦点");
      _focusNodePassword2.unfocus();
      _focusNodeButton.unfocus();
    }
    if (_focusNodePassword2.hasFocus) {
      print("确认密码框获取焦点");
      _focusNodePassword.unfocus();
      _focusNodeButton.unfocus();
    }
    if (_focusNodeButton.hasFocus) {
      print('点击了完成按钮');
      _focusNodePassword.unfocus();
      _focusNodePassword2.unfocus();
    }
  }

  bool _validator() {
    if (_password == '' || _password == null) {
      _alertDialog('请输入密码');
      return false;
    } else if (_password.length < 6) {
      _alertDialog('密码长度不少于6位');
      return false;
    } else if (_password.length > 16) {
      _alertDialog('密码长度不超过16位');
      return false;
    } else {
      if (_password2 == '' || _password2 == null) {
        _alertDialog('请再次输入密码');
        return false;
      } else if (_password != _password2) {
        _alertDialog('两次输入不一致');

        return false;
      }
      return true;
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

  _successDialog(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        // timeInSecForIosWeb: 1,
        backgroundColor: Colors.green[400],
        textColor: Colors.black,
        fontSize: 16.0);
  }
  
  _changePassword() async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    print(Token.token);
    String url = ApiTypeValues[APIType.ChangePassword];
    FormData formData = FormData.fromMap({"password": _password});
    try {
      Response response = await dio.put(url, data: formData);
      print(response.data);
      print(response.statusCode);
      _successDialog('密码设置成功');
      Navigator.of(context).pop();
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        _alertDialog('token失效');
      } else if (e.response.statusCode == 404) {
        _alertDialog('用户不存在');
      } else if (e.response.statusCode == 401) {
        _alertDialog('密码格式错误');
      } else {
        print(e.message);
        _alertDialog('修改密码失败');
      }
    }
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
          title: Text(
            "设置密码",
            style: TextStyle(color: Colors.black, fontSize: 18),
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
            _focusNodePassword.unfocus();
            _focusNodePassword2.unfocus();
          },
          child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(
                                left: ScreenUtil().setSp(20),
                                top: ScreenUtil().setSp(100),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    IconFont.tips,
                                  ),
                                  Text(
                                    "  密码为不低于6位的数字字母组合",
                                    style: TextStyle(
                                        fontSize: 16, color: MyColors.text),
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: ScreenUtil().setHeight(60),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(135),
                            child: TextFormField(
                              controller: _passwordControler,
                              focusNode: _focusNodePassword,
                              // obscureText:true,
                               obscureText: !_isShowPwd,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                hintText: "新密码",
                                prefixIcon: Icon(
                                  IconFont.password,
                                  size: 20,
                                ),
                                hintStyle:
                                    TextStyle(fontSize: ScreenUtil().setSp(50)),
                                suffixIcon: IconButton(
                                    icon: Icon((_isShowPwd)
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    // 点击改变显示或隐藏密码
                                    onPressed: () {
                                      setState(() {
                                        _isShowPwd = !_isShowPwd;
                                      });
                                    },
                                  ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _password = value;
                                  print(_password);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(50),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(135),
                            child: TextFormField(
                              controller: _passwordControler2,
                              focusNode: _focusNodePassword2,
                              // obscureText:true,
                               obscureText: !_isShowPwd2,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                prefixIcon: Icon(
                                  IconFont.password,
                                  size: 20,
                                ),
                                hintText: "再次确认密码",
                                suffixIcon: IconButton(
                                    icon: Icon((_isShowPwd2)
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    // 点击改变显示或隐藏密码
                                    onPressed: () {
                                      setState(() {
                                        _isShowPwd2 = !_isShowPwd2;
                                      });
                                    },
                                  ),
                                hintStyle:
                                    TextStyle(fontSize: ScreenUtil().setSp(50)),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _password2 = value;
                                });
                              },
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(80),
                  ),
                  Container(
                      height: ScreenUtil().setHeight(120),
                      child: RaisedButton(
                          color: MyColors.primary,
                          focusNode: _focusNodeButton,
                          child: Text(
                            "确定",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(60)),
                          ),
                          // 设置按钮圆角
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          onPressed: () {
                            if (_validator()) {
                              _changePassword();
                            }
                          }))
                ],
              )),
        ),
      ),
    );
  }
}
