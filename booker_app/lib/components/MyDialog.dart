import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyDialog extends Dialog {
  _setPlan(plan) async {
    Dio dio = new Dio();
    dio.options.headers['token'] = Token.token;
    String url = ApiTypeValues[APIType.Analysis] + '/reading-plan';
    try {
      Response response =
          await dio.put(url, queryParameters: {"readingPlan": plan});
      print("ok");
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
    final planController = TextEditingController();
    return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: MyColors.grey,
            ),
            height: ScreenUtil().setHeight(620),
            width: ScreenUtil().setWidth(1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: ScreenUtil().setHeight(120),
                  padding: EdgeInsets.only(left: 15, top: 15),
                  child: Text('制定计划',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
                ),
                Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white),
                    height: ScreenUtil().setHeight(260),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Text('今年我要完成阅读书籍',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w200)),
                          width: ScreenUtil().setWidth(500),
                        ),
                        Container(
                            width: ScreenUtil().setWidth(200),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: planController,
                              decoration: InputDecoration(
                                hintText: '       ?',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )),
                        Container(
                          child: Text('本',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w200)),
                          width: ScreenUtil().setWidth(100),
                        )
                      ],
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  height: ScreenUtil().setHeight(200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () async {
                          int score = 0;
                          try {
                            score = int.parse(planController.text);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "计划不是整数",
                                timeInSecForIos: 1,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: MyColors.danger,
                                textColor: MyColors.text,
                                fontSize: 16.0);
                            return;
                          }
                          if (score <= 0) {
                            Fluttertoast.showToast(
                                msg: "计划必须大于0",
                                timeInSecForIos: 1,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: MyColors.danger,
                                textColor: MyColors.text,
                                fontSize: 16.0);
                          } else {
                            await this._setPlan(score);
                            Navigator.of(context).pop(score);
                          }
                        },
                        color: Colors.white,
                        child: Text('确定',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.pop(context, 'Cancel');
                        },
                        color: Colors.white,
                        child: Text('取消',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

// _alertDialog() async {
//   var result = await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('取消'),
//           content: Text('您确定要删除吗?'),
//           actions: [
//             FlatButton(
//                 onPressed: () {
//                   Navigator.pop(context, 'Cancel');
//                 },
//                 child: Text('确定')),
//             FlatButton(
//                 onPressed: () {
//                   Navigator.pop(context, 'OK');
//                 },
//                 child: Text('确定')),
//           ],
//         );
//       });
//   print(result);
// }
