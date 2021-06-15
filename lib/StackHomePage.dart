import 'package:flutter/material.dart';

class StackHomePage extends StatelessWidget {
  StackHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(color: Colors.yellow, width: 300, height: 300), //黄色容器
        Positioned(
          left: 18.0,
          top: 18.0,
          child: Container(
              color: Colors.green, width: 50, height: 50), //叠加在黄色容器之上的绿色控件
        ),
        Positioned(
            left: 18.0,
            top: 70.0,
            child: Text("Stack提供了层叠布局的容器",
                style: TextStyle(fontSize: 18)) //叠加在黄色容器之上的文本
            )
      ],
    );
  }
}
