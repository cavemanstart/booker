import 'package:booker_app/fonts/fonts.dart';
import 'package:booker_app/tools/MyColors.dart';
import 'package:flutter/material.dart';

class BookBrief extends StatefulWidget {
  BookBrief({Key key, this.arguments}) : super(key: key);
  final Map arguments;
  @override
  _BookBriefState createState() => _BookBriefState();
}

List<Container> _briefList = [];

class _BookBriefState extends State<BookBrief> {
  _getBrief() {
    List<Container> list = [];
    var brief = widget.arguments['book']['brief'];
    String briefText = "";
    if (brief != null) {
      for (String elem in widget.arguments['book']['brief']) {
        Widget container = new Container(
          child: Text(elem, style: TextStyle(fontSize: 15)),
        );
        list.add(container);
      }
    }
    return list;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _briefList = _getBrief();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          backgroundColor: MyColors.grey,
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
              "简介",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            // centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: MyColors.grey,
            ),
            child: ListView(
              children: _briefList,
            ),
          )),
    );
  }
}
