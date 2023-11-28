import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Register4 extends StatefulWidget {
  Register4({Key key, this.arguments}) : super(key: key);
  final Map arguments;
  @override
  _Register4State createState() => _Register4State();
}

class _Register4State extends State<Register4> {
  int _selectIndex = 0;
  List _filters = [];
  // List<String> tagList = ['数据库', '算法', '大数据', 'AI', '数据结构', '嵌入式'];
  List<dynamic> tagList = [];
  List<String> _tags = [];
  @override
  void initState() {
    super.initState();
    _getTags();
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
    if (_tags.isEmpty) {
      _alertDialog('至少选择一个标签');
      return false;
    }
    return true;
  }

  _getTags() async {
    Dio dio = new Dio();
    String url = ApiTypeValues[APIType.Tags];
    try {
      Response response = await dio.get(
        url,
      );
      setState(() {
        tagList = response.data;
        print(tagList);
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
        _alertDialog('获取书籍标签失败');
      }
    }
  }

  _registeUser() async {
    Dio dio = new Dio();
    String url = ApiTypeValues[APIType.Register];
    dio.options.headers['token'] = Token.token;
    try {
      Response response = await dio.post(url, data: {
        "account": {'password': widget.arguments['account']['password']},
        "age": widget.arguments['age'],
        'birthdate': widget.arguments['birthdate'],
        'email': widget.arguments['email'],
        'industry': widget.arguments['industry'],
        'nickname': widget.arguments['nickname'],
        'sex': widget.arguments['sex'],
        'tags': _tags
      });
      setState(() {
        Token.token = response.data["token"];
        print(response.data);
        Navigator.pushNamed(context, '/tabs');
      });
      _successDialog('注册新用户成功');
      Navigator.pushNamed(context, '/tabs');
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response.statusCode == 401) {
          _alertDialog('Token 失效');
        } else if (e.response.statusCode == 403) {
          _alertDialog('邮箱错误');
        } else {
          _alertDialog('Not Found');
        }
      } else {
        _alertDialog('注册用户失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget tagField = new Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 5,
        runSpacing: -8,
        children: List.generate(tagList.length, (index) {
          return FilterChip(
            label: Text(tagList[index]),
            selected: _filters.contains('$index'),
            selectedColor: Colors.yellow[300],
            onSelected: (v) {
              setState(() {
                if (v) {
                  _filters.add('$index');
                  _tags.add(tagList[index]);
                } else {
                  _filters.removeWhere((f) {
                    print(f);
                    return f == '$index';
                  });
                  _tags.remove(tagList[index]);
                }
              });
              print(_tags);
            },
          );
        }).toList(),
      ),
    );
    return Container(
      child: Scaffold(
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
            "添加标签",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(left: 5),
                height: 30,
                child: Text(
                  '选择你感兴趣的标签吧...',
                  style: TextStyle(fontSize: 20, color: MyColors.primary),
                ),
              ),
              tagField,
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                      child: RaisedButton(
                          color: MyColors.primary,
                          child: Text(
                            "完成",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          // 设置按钮圆角
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          onPressed: () {
                            if (_validator()) {
                              _registeUser();
                            }
                            // Navigator.of(context).pop();
                          })),
                ],
              ),
            ],
          ),
        ),
        // body: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       MultiNormalSelectChip(
        //         allList,
        //         selectList: selectList,
        //         onSelectionChanged: (selectedList) {
        //           selectList = selectedList;
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
