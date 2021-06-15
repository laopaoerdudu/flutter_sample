import 'package:flutter/material.dart';

class RowAlignHomePage extends StatelessWidget {
  RowAlignHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
// 我们设置了主轴大小为 MainAxisSize.min 之后，Row 的宽度变得和其子 Widget 一样大，因此再设置主轴的对齐方式也就不起作用了。
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// 设置容器的宽度由子控件自适应决定，类似 Android 中的 wrap_content
      mainAxisSize: MainAxisSize.min,
//让容器宽度与所有子Widget的宽度一致
      children: <Widget>[
        Container(
          color: Colors.yellow,
          width: 60,
          height: 80,
        ),
        Container(
          color: Colors.red,
          width: 100,
          height: 180,
        ),
        Container(
          color: Colors.black,
          width: 60,
          height: 80,
        ),
        Container(
          color: Colors.green,
          width: 60,
          height: 80,
        ),
      ],
    );
  }
}
