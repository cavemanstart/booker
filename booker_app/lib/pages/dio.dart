import 'package:flutter/material.dart';
import 'package:booker_app/fonts/fonts.dart';
import 'package:dio/dio.dart';
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _msg = '';
  List _result = [];
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    var response = await Dio().get('https://jd.itying.com/api/pcate');
    print(response.data);
    print(response.statusCode);
    setState(() {
      _result = response.data["result"];
    });
  }

  _postData() async {
    var response = await Dio().post('https://jd.itying.com/api/httpPost',
        data: {'username': 'zz', 'age': 20});
    print(response.data);
    print(response.statusCode);
    setState(() {
      _msg = response.data["msg"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      IconFont.search,
                      size: 28,
                      color: Colors.grey[800],
                    ),
                    hintText: "搜索",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 5,
                      ),
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text("get请求"),
                onPressed: _getData,
              ),
              Text(this._msg),
              SizedBox(
                height: 20,
              ),
              RaisedButton(child: Text("post请求"), onPressed: _postData),
              Text(this._msg),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                  child: Text("数据渲染"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/hhh');
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
