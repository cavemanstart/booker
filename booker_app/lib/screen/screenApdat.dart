import 'dart:ui';

import 'package:flutter/material.dart';

//自适应屏幕
class ScreenAdapt {
  //第一步 获取设备对象属性
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static double screenwidth; //设备屏幕宽度width
  static double screenheight; //设备屏幕高度height
  static double topheight; //顶部空白高度
  static double bottomheight; //底部空白高度
  static double devicepixelratio = mediaQuery.devicePixelRatio; //分辨比
  static var screenWratio; //屏幕宽比
  static var screenHratio; //屏幕高比
  //初始化 UI设计稿：比如750、1920等  uinumber变量设计稿宽
  static initialize(int uiwidth, int uiheight) {
    print('调用了初始化方法');
    screenwidth = mediaQuery.size.width;
    screenheight = mediaQuery.size.height;
    int uiwidth1 = uiwidth is int ? uiwidth : 1080; //默认是1920 ui设计图
    int uiheight1 = uiheight is int ? uiheight : 2400; //默认是1920 ui设计图
    screenWratio = screenwidth / uiwidth; //屏幕宽比  设备宽度 : ui设计图宽度
    screenHratio = screenheight / uiheight; //屏幕宽比  设备宽度 : ui设计图宽度
  }

  //实现填写像素  number：设计稿的像素
  static pxWidth(number) {
    print('像素值是');
    print(number * screenWratio);
    return number * screenWratio; //返回处理好的像素数值
  }

  //获取屏幕宽度
  static screenWidth() {
    screenwidth = mediaQuery.size.width;
    return screenwidth;
  }

  //获取设备屏幕高度
  static screenHeight() {
    screenheight = mediaQuery.size.height;
    return screenheight;
  }

  //获取设备顶部空白高度
  static topHeight() {
    topheight = mediaQuery.padding.top;
    return topheight;
  }

  //获取设备底部空白高度
  static bottomHeight() {
    bottomheight = mediaQuery.padding.bottom;
    return bottomheight;
  }
}
