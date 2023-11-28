import 'dart:ui';
import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import '../mydio/config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();
  //用户名输入框控制器，此控制器可以监听用户名输入框操作
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _password = ''; //用户名
  String _username = ''; //密码
  var _isShowPwd = false; //是否显示密码
  var _isShowClear = false; //是否显示输入框尾部的清除按钮
  bool _isChecked = false;
  IconData _checkIcon = Icons.check_box_outline_blank;
  String message = '';
  @override
  void initState() {
    //设置焦点监听
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    //监听用户名框的输入改变
    _userNameController.addListener(() {
      print(_userNameController.text);
      // 监听文本框输入变化，当有内容的时候，显示尾部清除按钮，否则不显示
      if (_userNameController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
    super.initState();
    setState(() {
      _isChecked = false;
    });
    _focusNodePassWord.unfocus();
    _focusNodeUserName.unfocus();
  }

  @override
  void dispose() {
    // 移除焦点监听
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _userNameController.dispose();
    super.dispose();
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

  bool _validatorUser(var username) {
    username = _username;
    if (username == '' || username == null) {
      _alertDialog('用户名不能为空');
      return false;
    }
    // if (!StringUtil.isEmail(username)) {
    //   _alertDialog('用户名（邮箱）格式错误');
    //   _userNameController.clear();
    //   print('邮箱错了');
    //   return false;
    // }
    return true;
  }

  bool _validatorPassword(String password) {
    password = _password;
    if (password == '' || password == null) {
      _alertDialog('请输入密码');
      return false;
    }
    if (password.length < 6 || password.length > 16) {
      _alertDialog('密码长度为6-16个字符');
      return false;
    }
    return false;
  }

  bool _validator() {
    if (_username == '' || _username == null) {
      _alertDialog('用户名不能为空');
      return false;
    } else {
      if (_password == '' || _password == null) {
        _alertDialog('请输入密码');
        return false;
      }
      if (_password.length < 6 || _password.length > 16) {
        _alertDialog('密码长度为6-16个字符');
        return false;
      }
      return true;
    }
  }

  // 监听焦点
  Future<Null> _focusNodeListener() async {
    if (_focusNodeUserName.hasFocus) {
      print("用户名框获取焦点");
      // 取消密码框的焦点状态
      _focusNodePassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密码框获取焦点");
      // 取消用户名框焦点状态
      _focusNodeUserName.unfocus();
    }
    // if (!_focusNodeUserName.hasFocus && !_focusNodePassWord.hasFocus) {
    //   _validatorUser(_username);
    //   _validatorPassword(_password);
    // }
  }

  /**
   * 验证用户名
   */

  /// 验证密码
  String validatePassWord(value) {
    if (value.isEmpty) {
      return '密码不能为空';
    } else if (value.trim().length < 6 || value.trim().length > 18) {
      return '密码长度不正确';
    }
    return null;
  }

  _login() async {
    Dio dio = new Dio();
    String url = ApiTypeValues[APIType.Login];

    ///发送 FormData:
    FormData formData =
        FormData.fromMap({"username": _username, "password": _password});
    try {
      Response response = await dio.post(url, data: formData);
      setState(() {
        Token.token = response.data;
        print(Token.token);
        Navigator.pushNamed(context, '/tabs');
      });
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 404) {
          _alertDialog('用户不存在');
        } else if (e.response.statusCode == 406) {
          _alertDialog('密码错误');
        } else {
          _alertDialog('数据格式错误');
        }
      } else {
        _alertDialog('请求失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
    // logo 图片区域
    Widget logoImageArea = new Container(
        height: ScreenUtil().setHeight(400),
        width: ScreenUtil().setHeight(400),
        alignment: Alignment.topCenter,
        // 设置图片为圆形
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.fill,
        ));
    //输入文本框区域
    Widget inputTextArea = new Container(
      margin: EdgeInsets.only(
          left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: MyColors.grey),
      child: new Form(
        key: _formKey,
        child: new Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Container(
              height: ScreenUtil().setHeight(135),
              child: TextFormField(
                controller: _userNameController,
                focusNode: _focusNodeUserName,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: "用户名/邮箱",
                    hintStyle: TextStyle(fontSize: ScreenUtil().setSp(35)),
                    prefixIcon: Icon(
                      IconFont.user,
                      size: 20,
                    ),
                    //尾部添加清除按钮
                    suffixIcon: (_isShowClear)
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              // 清空输入框内容
                              setState(() {
                                _username = null;
                              });
                              _userNameController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onChanged: (String value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(50),
            ),
            new Container(
              height: ScreenUtil().setHeight(135),
              child: TextFormField(
                focusNode: _focusNodePassWord,
                controller: _passwordController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    hintText: "密码",
                    hintStyle: TextStyle(fontSize: ScreenUtil().setSp(35)),
                    prefixIcon: Icon(
                      IconFont.password,
                      size: 18,
                    ),
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
                    )),
                obscureText: !_isShowPwd,
                // validator: validatePassWord,
                onChanged: (String value) {
                  setState(() {
                    print(value);
                    _password = value;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
    // 登录按钮区域
    Widget loginButtonArea = new Container(
      height: ScreenUtil().setHeight(120),
      margin: EdgeInsets.only(
          left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
      child: new RaisedButton(
          color: MyColors.primary,
          child: Text(
            "登录",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(60), color: Colors.white),
          ),
          // 设置按钮圆角
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: this._isChecked
              ? () {
                  //点击登录按钮，解除焦点，回收键盘
                  _focusNodePassWord.unfocus();
                  _focusNodeUserName.unfocus();
                  _formKey.currentState.save();
                  print("$_username + $_password");
                  if(_validator()){
                     _login();
                  }
                }
              : null),
    );

    //第三方登录区域
    Widget thirdLoginArea = new Container(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 80,
                height: 1.0,
                color: Colors.grey,
              ),
              Text('第三方登录'),
              Container(
                width: 80,
                height: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
          new SizedBox(
            height: 10,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(150),
                width: ScreenUtil().setHeight(150),
                child: Image.asset('assets/wechat.png'),
              ),
              Container(
                height: ScreenUtil().setHeight(150),
                width: ScreenUtil().setHeight(150),
                child: Image.asset('assets/qq.png'),
              ),
            ],
          )
        ],
      ),
    );
    //用户隐私协议
    Widget tips = new Container(
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          IconButton(
              icon: Icon(_checkIcon),
              color: Colors.orange,
              iconSize: ScreenUtil().setSp(50),
              onPressed: () {
                setState(() {
                  _isChecked = !_isChecked;
                  if (_isChecked) {
                    _checkIcon = Icons.check_box;
                  } else {
                    _checkIcon = Icons.check_box_outline_blank;
                  }
                });
              }),
          Expanded(
            child: RichText(
                text: TextSpan(
                    text: '我已经详细阅读并同意',
                    style: TextStyle(
                        color: Colors.black, fontSize: ScreenUtil().setSp(30)),
                    children: <TextSpan>[
                  TextSpan(
                      text: '《隐私政策》',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                  TextSpan(text: '和'),
                  TextSpan(
                      text: '《用户协议》',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline))
                ])),
          )
        ],
      ),
    );
    //忘记密码  立即注册
    Widget bottomArea = new Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            child: Text(
              "忘记密码?",
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.0,
              ),
            ),
            //忘记密码按钮，点击执行事件 fontsize: sceenUtil().setSp(60),

            onPressed: () {
              _focusNodePassWord.unfocus();
              _focusNodeUserName.unfocus();
              _userNameController.clear();
              _passwordController.clear();
              setState(() {
                _username = null;
                _password = null;
              });
              Navigator.pushNamed(context, "/forgot");
            },
          ),
          TextButton(
            child: Text(
              "快速注册",
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.0,
              ),
            ),
            //点击快速注册、执行事件
            onPressed: () {
              _focusNodePassWord.unfocus();
              _focusNodeUserName.unfocus();
              Navigator.pushNamed(context, '/register');
              _userNameController.clear();
              _passwordController.clear();
              setState(() {
                _username = null;
                _password = null;
              });
            },
          )
        ],
      ),
    );
    Widget notes = new Container(
      margin: EdgeInsets.only(bottom: 5),
      alignment: Alignment.center,
      child: Text(
        "本App版权由@DHU Ourselves开发团队所有",
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
    return Scaffold(
      backgroundColor: MyColors.grey,
      appBar: AppBar(
        title: Text(
          "登录",
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(60)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      // 外层添加一个手势，用于点击空白部分，回收键盘
      body: new GestureDetector(
        onTap: () {
          // 点击空白区域，回收键盘
          print("点击了空白区域");
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
          // _validatorUser(_username);
          // _validatorPassword(_password);
        },
        child: new ListView(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
          children: <Widget>[
            new SizedBox(
              height: ScreenUtil().setHeight(120),
            ),
            logoImageArea,
            new SizedBox(
              height: ScreenUtil().setHeight(250),
            ),
            inputTextArea,
            new SizedBox(
              height: ScreenUtil().setHeight(80),
            ),
            loginButtonArea,
            tips,
            new SizedBox(
              height: ScreenUtil().setHeight(60),
            ),
            thirdLoginArea,
            new SizedBox(
              height: ScreenUtil().setHeight(10),
            ),
            bottomArea,
            new SizedBox(
              height: ScreenUtil().setHeight(80),
            ),
            notes,
          ],
        ),
      ),
    );
  }
}
