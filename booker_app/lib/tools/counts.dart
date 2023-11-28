import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' deferred as ui;
import 'dart:ui';

class CustomChartPaint extends CustomPainter {
  Paint _bgPaint;
  Paint _barPaint;
  Paint _linePaint;

  Color backgroundColor = Color(0xFFF6F6F6); //条形图背景颜色
  Color barColor = Color(0xFF5858D6); //条形图颜色
  static const Color textColor = Color(0xFF5858D6); //字体颜色
  Color lineColor = Color(0xFFD1D1D6); //X轴颜色
  double barWidth = 22.0; //条形图宽度
  double barMargin = 20.0; //两条形图间距
  double topMargin = 22.0; //图表与其他试图上边距
  double textTopMargin = 8.0; //X轴文字与X轴间距
  static const double xFontSize = 12.0; //X轴文字的字体大小
  double bottomTextDescent = 20;
  double bottomTextHeight = 20;

  List<double> dataList = [5, 7, 4, 3, 4, 3, 4, 4, 3, 5, 9, 3];
  List<String> bottomList = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];
  String xText = 'month';

  List<String> bottomTextList = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];

  List targetPercentList;
  List percentList;

  CustomChartPaint(this.dataList, this.bottomList, this.xText) {
    //print("max" + (dataList.reduce(max)+dataList.reduce(min)).toString());
    setBottomTextList(bottomList);
    setDataList(dataList, dataList.reduce(max) + dataList.reduce(min));
    init();
  }

  init() {
    _bgPaint = new Paint()
      ..isAntiAlias = true //是否启动抗锯齿
      ..color = backgroundColor; //画笔颜色

    _barPaint = new Paint()
      ..color = barColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill; //绘画风格，默认为填充;

    _linePaint = new Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;
  }

  setBottomTextList(List<String> bottomStringList) {
    this.bottomTextList = bottomStringList;
  }

  setDataList(List<double> list, double max) {
    targetPercentList = new List<double>();

    if (max == 0) max = 1;

    for (int i = 0; i < list.length; i++) {
      targetPercentList.add((1 - list[i] / max)); //当前数据占总长度的百分比
    }
  }

  Rect bgRect;
  Rect fgRect;

  @override
  void paint(Canvas canvas, Size size) {
    print("size: " + size.toString()); //画布大小

    int i = 1;
    if (targetPercentList.length != 0) {
      for (double f in targetPercentList) {
        bgRect = Rect.fromLTRB(
            barMargin * i + barWidth * (i - 1),
            topMargin,
            (barMargin + barWidth) * i,
            size.height - bottomTextHeight - textTopMargin);
        canvas.drawRect(bgRect, _bgPaint); //绘制背景柱形

        double rectLeft = barMargin * i + barWidth * (i - 1);
        double rectRight = topMargin +
            (size.height - topMargin - bottomTextHeight - textTopMargin) *
                targetPercentList[i - 1];

        //print("rectX: " + rectLeft.toString() + ", rectY: " + rectRight.toString());

        fgRect = Rect.fromLTRB(rectLeft, rectRight, (barMargin + barWidth) * i,
            size.height - bottomTextHeight - textTopMargin);
        canvas.drawRect(fgRect, _barPaint); //绘制前景柱形

        Offset textOffset =
            new ui.Offset(rectLeft - barWidth / 2, rectRight - 18);

        /// 18为具体数值与柱形顶部的间距
        _drawParagraph(
            canvas, textOffset, dataList[i - 1].toString()); //在bar上描绘具体数值

        i++;
      }

      double mViewWidth =
          (bottomTextList.length + 1.5) * (barWidth + barMargin); //整个视图的宽度

      Offset start =
          ui.Offset(0, size.height - bottomTextHeight - textTopMargin);
      Offset end =
          ui.Offset(mViewWidth, size.height - bottomTextHeight - textTopMargin);

      canvas.drawLine(start, end, _linePaint); //画一条X轴

      if (bottomTextList != null && bottomTextList.isNotEmpty) {
        i = 1;
        for (String bottomText in bottomTextList) {
          Offset bottomTextOffset = new Offset(
              barMargin * i + barWidth * (i - 2) + barWidth / 2,
              size.height - bottomTextDescent - textTopMargin);
          _drawParagraph(canvas, bottomTextOffset, bottomText); //绘制X轴描述
          i++;
        }
      }

      Offset bottomTextOffset = new Offset(barMargin * i + barWidth * (i - 1),
          size.height - bottomTextDescent - textTopMargin);
      _drawParagraph(canvas, bottomTextOffset, xText); //绘制X轴变量名

    }
  }

  _drawParagraph(Canvas canvas, Offset offset, String text,
      {double fontSize: xFontSize, Color textColor: textColor}) {
    ParagraphBuilder paragraphBuilder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        textAlign: TextAlign
            .center, //在ui.ParagraphConstraints(width: barWidth * 2);所设置的宽度中居中显示
        fontSize: fontSize,
      ),
    )..pushStyle(ui.TextStyle(color: textColor));
    paragraphBuilder.addText(text);

    ParagraphConstraints pc =
        ui.ParagraphConstraints(width: barWidth * 2); //字体可用宽度
    //这里需要先layout, 后面才能获取到文字高度
    Paragraph textParagraph = paragraphBuilder.build()..layout(pc);

    canvas.drawParagraph(textParagraph, offset); //描绘offset所表示的位置上描绘文字text
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
