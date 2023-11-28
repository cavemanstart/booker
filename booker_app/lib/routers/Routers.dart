import 'package:booker_app/pages/bookpage/updateNotes.dart';
import 'package:flutter/material.dart';
import '../pages/SearchPage.dart';
import '../user/RegisterPage.dart';
import '../user/LoginPage.dart';
import '../user/RegisterPage2.dart';
import '../user/Forgot.dart';
import '../user/SetPassword.dart';
import '../pages/tabs/Tabs.dart';
import '../user/RegisterPage3.dart';
import '../user/RegisterPage4.dart';
import '../pages/bookpage/BookList1.dart';
import '../pages/bookpage/BookList2.dart';
import '../pages/bookpage/BookList3.dart';
import '../pages/bookpage/BookInfo.dart';
import '../pages/bookpage/BookComments.dart';
import '../pages/bookpage/MyCommenets.dart';
import '../pages/bookpage/BookNotesList.dart';
import '../pages/bookpage/AddNotes.dart';
import '../pages/bookpage/BookBrief.dart';

final routers = {
  '/search': (context) => SearchPage(),
  '/login': (context) => LoginPage(),
  '/register': (context) => Register(),
  '/register2': (context,{arguments}) => Register2(arguments: arguments,),
  '/register3': (context,{arguments}) => Register3(arguments: arguments,),
 '/register4': (context,{arguments}) => Register4(arguments: arguments,),
  '/forgot': (context) => Forgot(),
  '/setpassword': (context) => SetPassword(),
  '/tabs': (context) => Tabs(),
  '/booklist1': (context) => BookList1(),
  '/booklist2': (context) => BookList2(),
  '/booklist3': (context) => BookList3(),
  '/bookinfo': (context, {arguments}) => BookInfo(
        arguments: arguments,
      ),
  '/bookcomments': (context, {arguments}) => BookComments(arguments: arguments),
  '/mycomments': (context, {arguments}) => MyComments(arguments: arguments),
  '/booknoteslist': (context, {arguments}) =>
      BookNotesList(arguments: arguments),
  '/addnotes': (context, {arguments}) => AddNotes(arguments: arguments),
  '/updatenotes': (context, {arguments}) => UpdateNotes(arguments: arguments),
  '/bookbrief': (context, {arguments}) => BookBrief(arguments: arguments),
};
//固定写法
var onGenerateRoute = (RouteSettings settings) {
  final String name = settings.name;
  final Function pageContentBuilder = routers[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
        builder: (context) => pageContentBuilder(
          context,
          arguments: settings.arguments,
        ),
      );
      return route;
    } else {
      final Route route = MaterialPageRoute(
        builder: (context) => pageContentBuilder(context),
      );
      return route;
    }
  }
};
