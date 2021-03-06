import 'package:flutter/material.dart';

// iOS浅色主题
final ThemeData kIOSTheme = ThemeData(
    brightness: Brightness.light,//亮色主题
    accentColor: Colors.white,//(按钮)Widget前景色为白色
    primaryColor: Colors.blue,//主题色为蓝色
    iconTheme:IconThemeData(color: Colors.grey),//icon主题为灰色
    textTheme: TextTheme(body1: TextStyle(color: Colors.black))//文本主题为黑色
);
// Android深色主题
final ThemeData kAndroidTheme = ThemeData(
    brightness: Brightness.dark,//深色主题
    accentColor: Colors.black,//(按钮)Widget前景色为黑色
    primaryColor: Colors.cyan,//主题色Wie青色
    iconTheme:IconThemeData(color: Colors.blue),//icon主题色为蓝色
    textTheme: TextTheme(body1: TextStyle(color: Colors.red))//文本主题色为红色
);