import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/mydio/config.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateNotes extends StatefulWidget {
  final Map arguments;
  UpdateNotes({this.arguments});

  @override
  _UpdateNotesState createState() => _UpdateNotesState();
}

class _UpdateNotesState extends State<UpdateNotes> {
  final noteTitleController = TextEditingController();
  final noteController = TextEditingController();
  _updateNote() async {
    if (this.noteTitleController.text == null ||
        this.noteTitleController.text == "") {
      Fluttertoast.showToast(
          msg: "标题不能为空",
          timeInSecForIos: 1,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: MyColors.danger,
          textColor: MyColors.text,
          fontSize: 16.0);
    } else {
      Dio dio = new Dio();
      dio.options.headers['token'] = Token.token;
      String urlPersonal = ApiTypeValues[APIType.Note] +
          '/' +
          widget.arguments["noteId"].toString();
      try {
        Response response = await dio.put(urlPersonal, data: {
          "content": noteController.text,
          "title": noteTitleController.text,
        });
        setState(() {
          print(response.data);
          Navigator.pop(context, widget.arguments["bookId"]);
        });
      } on DioError catch (e) {
        if (e.response != null) {
          if (e.response.statusCode == 401) {
            print('token失效');
          } else if (e.response.statusCode == 404) {
            print('图书不存在');
          } else {}
        } else {
          print(e);
        }
      }
    }
  }

  Widget commentArea() {
    return new Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: new Border.all(width: 2.0, color: Colors.grey[300]),
          borderRadius: new BorderRadius.all(new Radius.circular(12)),
        ),
        height: ScreenUtil().setHeight(1200),
        child: Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(50),
              right: ScreenUtil().setSp(50),
              top: ScreenUtil().setSp(20)),
          child: TextFormField(
              keyboardType: TextInputType.text,
              maxLength: 800,
              maxLines: 40,
              controller: noteController,
              decoration: InputDecoration(
                hintText: '✏️ 写下你的读书感悟吧',
                enabledBorder: new UnderlineInputBorder(
                  // 不是焦点的时候颜色
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusedBorder: new UnderlineInputBorder(
                  // 焦点集中的时候颜色
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
              )),
        ));
  }

  @override
  void initState() {
    super.initState();
    this.noteController.text = widget.arguments["content"];
    this.noteTitleController.text = widget.arguments["title"];
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 1080, height: 2400, allowFontScaling: true)
          ..init(context);
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
          title: Text('写笔记',
              style: TextStyle(
                  fontSize: ScreenUtil().setHeight(60), color: Colors.black)),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: TextButton(
                  onPressed: () {
                    this._updateNote();
                  },
                  child: Text('完成',
                      style: TextStyle(
                          fontSize: ScreenUtil().setHeight(60),
                          color: MyColors.primary))),
            )
          ],
          backgroundColor: Colors.white,
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              Container(
                height: 50,
                width: 100,
                child: TextFormField(
                  controller: this.noteTitleController,
                  decoration: InputDecoration(
                    hintText: '标题',
                    hintStyle: TextStyle(fontSize: 14),
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
                ),
              ),
              SizedBox(
                height: 20,
              ),
              commentArea(),
            ],
          ),
        ),
      ),
    );
  }
}
