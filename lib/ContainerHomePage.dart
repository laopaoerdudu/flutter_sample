import 'package:flutter/material.dart';

class ContainerHomePage extends StatelessWidget {
  ContainerHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('Container（容器）在UI框架中是一个很常见的概念，Flutter也不例外。')),
      padding: EdgeInsets.all(18.0),
      margin: EdgeInsets.all(44.0),
      width: 180.0,
      height: 240,
      decoration: BoxDecoration(  // Container样式
        color: Colors.red, // 背景色
        borderRadius: BorderRadius.circular(10.0), // 圆角边框
      ),
    );
  }
}
