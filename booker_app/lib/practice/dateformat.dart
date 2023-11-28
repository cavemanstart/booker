import 'package:flutter/material.dart';

import 'package:date_format/date_format.dart';

class Data extends StatefulWidget {
  @override
  _DataState createState() => _DataState();
}

class _DataState extends State<Data> {
  DateTime _now = DateTime.now();
  _showDatePicker() async {
    var result = await showDatePicker(
      context: context,
      initialDate: this._now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      
    );
    setState(() {
      this._now = result;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("日期选择组件"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${formatDate(this._now, [yyyy,'年',mm,'月',dd,'日'])}"),
                // formatDate(this._now, [yyyy,'年',mm,'月',dd,'日'])
                Icon(Icons.arrow_drop_down),
              ],
            ),
            onTap: _showDatePicker,
          )
        ],
      ),
    );
  }
}
