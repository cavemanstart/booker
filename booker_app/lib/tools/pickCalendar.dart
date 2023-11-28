import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import '../mydio/config.dart';
import 'MyColors.dart';
import 'changeNongliYangli.dart';

void incrementCounter(context) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
// 用Scaffold返回显示的内容，能跟随主题

      return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Scaffold(
              backgroundColor: Colors.transparent, // 设置透明背影

              body: Stack(children: <Widget>[PickBody()])));
    },
  );
}

class PickBody extends StatefulWidget {
  PickBody({Key key}) : super(key: key);
  @override
  _PickBodyState createState() => _PickBodyState();
}

class _PickBodyState extends State<PickBody> {
  DateTime now = DateTime.now();
  bool gongli = true;

  String sYear = "2000";

  String sMonth = '1';

  String sDay = '1';

  String sTime = '24';

  List year = [], month = [], yMonth = [], day = [], yday = [];

  List nMonth = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];

  List time = [
    '时辰未知',
    '0时子',
    '1时丑',
    '2时丑',
    '3时寅',
    '4时寅',
    '5时',
    '6时',
    '7时',
    '8时',
    '9时',
    '10时',
    '11时',
    '12时',
    '13时丑',
    '14时丑',
    '15时寅',
    '16时寅',
    '17时',
    '18时',
    '19时',
    '20时',
    '21时',
    '22时',
    '23时'
  ];

  List nday = [
    '初一',
    '初二',
    '初三',
    '初四',
    '初五',
    '初六',
    '初七',
    '初八',
    '初九',
    '初十',
    '十一',
    '十二',
    '十三',
    '十四',
    '十五',
    '十六',
    '十七',
    '十八',
    '十九',
    '二十',
    '廿一',
    '廿二',
    '廿三',
    '廿四',
    '廿五',
    '廿六',
    '廿七',
    '廿八',
    '廿九',
    '三十',
    '三十一'
  ];

  FixedExtentScrollController yearController =
      new FixedExtentScrollController(initialItem: 20);

  FixedExtentScrollController monthController =
      new FixedExtentScrollController(initialItem: 5);

  FixedExtentScrollController dayController =
      new FixedExtentScrollController(initialItem: 14);

  FixedExtentScrollController timeController =
      new FixedExtentScrollController();

  @override
  void initState() {
// TODO: implement initState

    super.initState();

// 获取当天的日期，年份默认选择的是2000年,月份默认是6月，日期默认是15日，时间默认是不详

    DateTime today = DateTime.now();

// 请空之前的数据

    for (var y = 1980; y < today.year + 1; y++) {
      year.add('$y');
    }

    yMonth = [];

    for (int m = 1; m < 13; m++) {
      yMonth.add('$m');
    }

// 获取默认年份和月份之下的天数

    int count = getYangliDay(int.parse(sYear), int.parse(sMonth));

    print('count---$count');

    yday = [];

    for (int m = 1; m < count + 1; m++) {
      yday.add('$m');
    }
  }

  @override
  Widget build(BuildContext context) {
// 切换农历和阳历的时候更换月份和天的称呼

    if (gongli) {
      month = yMonth;

      day = yday;
    } else {
      month = nMonth;

      int count = getNongliDay(int.parse(sYear), int.parse(sMonth));

      print('农历的天数==${count}');

      List old = nday;

      List newDay = old.sublist(0, count);

// 初始化当前的选中的月份的天数

      day = newDay;
    }

    return Container(
        height: 300,
        decoration: BoxDecoration(color: Colors.white),

// padding: EdgeInsets.all(10),

        child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 2, color: MyColors.primary))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    child: Text('取消',
                        style: TextStyle(color: MyColors.dark, fontSize: 16)),
                    onTap: () {
                      print('关闭弹框');
                      Navigator.pop(
                        context,
                      );
                    },
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        FlatButton(
                          child: Text('公历'),
                          onPressed: () {
                            setState(() {
                              gongli = true;
                            });
                          },
                          color: gongli ? MyColors.primary : Colors.white,
                          textColor: gongli ? Colors.white : MyColors.primary,
                          shape: BeveledRectangleBorder(
                              side:
                                  BorderSide(color: MyColors.primary, width: 1),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  bottomLeft: Radius.circular(3))),
                        ),
                        FlatButton(
                          child: Text('农历'),
                          splashColor: MyColors.primary,
                          color: gongli ? Colors.white : MyColors.primary,
                          textColor: gongli ? MyColors.primary : Colors.white,
                          shape: BeveledRectangleBorder(
                              side:
                                  BorderSide(color: MyColors.primary, width: 1),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3))),
                          onPressed: () {
                            setState(() {
                              gongli = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: Text('确定',
                        style: TextStyle(color: MyColors.dark, fontSize: 16)),
                    onTap: () {
                      print('确定 关闭弹框');
                      print(sYear);
                      print(sMonth);
                      print(sDay);
                      print(sTime);
                      setState(() {
                        AgeData.year = int.parse(sYear);
                        AgeData.month = int.parse(sMonth);
                        AgeData.day = int.parse(sDay);
                        AgeData.age = now.year - int.parse(sYear);
                      });
                      print('hhhhhhhhh');
                      print(AgeData.year is int);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                        height: 200,
                        child: CupertinoPicker(
                          useMagnifier: true,

                          magnification: 1.2,

                          squeeze: 1,

                          diameterRatio: 1.5,

                          looping: false,

                          backgroundColor: Colors.transparent, //选择器背景色

                          itemExtent: 35, //item的高度

                          onSelectedItemChanged: (index) {
                            print('index === $index');

                            int selectYear = 1980 + index;

// 更改年的时候，查询选中的年和月的天数

                            print("选中年 = ${selectYear}");

                            setState(() {
                              sYear = '$selectYear';

// 更换年的时候检测是阳历还是农历

                              updateDay();

// monthController.jumpToItem(3);
                            });
                          },

                          scrollController: yearController,

                          children: XZItem(year, '年'),
                        ))),
                Expanded(
                    flex: 1,
                    child: Container(
                        height: 200,
                        child: CupertinoPicker(
                          useMagnifier: true,

                          magnification: 1.2,

                          squeeze: 1,

                          diameterRatio: 1.5,

                          looping: false,

                          backgroundColor: Colors.transparent, //选择器背景色

                          itemExtent: 35, //item的高度

                          onSelectedItemChanged: (index) {
//选中item的位置索引

                            print("月index = $index}");

                            setState(() {
                              sMonth = '${index + 1}';
                            });

                            sMonth = '${index + 1}';

                            updateDay();
                          },

                          scrollController: monthController,

                          children: XZItem(month, '月'),
                        ))),
                Expanded(
                    flex: 1,
                    child: Container(
                        height: 200,
                        child: CupertinoPicker(
                          useMagnifier: true,

                          magnification: 1.2,

                          squeeze: 1,

                          diameterRatio: 1.5,

                          looping: false,

                          backgroundColor: Colors.transparent, //选择器背景色

                          itemExtent: 35, //item的高度

                          onSelectedItemChanged: (index) {
//选中item的位置索引

                            print("日index = $index}");

                            setState(() {
                              sDay = '${index + 1}';
                            });

                            sDay = '${index + 1}';
                          },

                          scrollController: dayController,

                          children: XZItem(day, '日'),
                        ))),
//                     Expanded(
//                         flex: 1,
//                         child: Container(
//                             height: 200,
//                             child: CupertinoPicker(
//                               useMagnifier: true,

//                               magnification: 1.2,

//                               squeeze: 1,

//                               diameterRatio: 1.5,

//                               looping: false,

//                               backgroundColor: Colors.transparent, //选择器背景色

//                               itemExtent: 35, //item的高度

//                               onSelectedItemChanged: (index) {
// //选中item的位置索引
//                                 print("index = $index}");

//                                 setState(() {
//                                   if (index == 0) {
//                                     sTime = '24';
//                                   } else {
//                                     sTime = '${index - 1}';
//                                   }
//                                 });
//                               },

//                               scrollController: timeController,

//                               children: XZItem(time, ''),
//                             ))),
              ])
        ]));
  }

  updateDay() {
    if (gongli) {
// 公历// 截取天数
      print('widget.sYear ==== ${sYear}');

      print('widget.sMonth ==== ${sMonth}');

      print('widget.sDay ==== ${sDay}');

      int count = getYangliDay(int.parse(sYear), int.parse(sMonth));

      print('count---$count');

      yday = [];

      for (int m = 1; m < count + 1; m++) {
        yday.add('$m');
      }
    } else {
      int count = getNongliDay(int.parse(sYear), int.parse(sMonth));

      print('农历的天数==${count}');

      List old = day;

      List newDay = old.sublist(0, count);

      print(old);

      print(newDay);

      day = newDay;
    }
  }

  List<Widget> XZItem(_data, type) {
    List<Widget> list = new List();
    for (var i = 0; i < _data.length; i++) {
      list.add(Text('${_data[i]}$type',
          style: TextStyle(color: Colors.black, fontSize: 14)));
    }
    return list;
  }
}
