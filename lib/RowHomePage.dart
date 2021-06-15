import 'package:flutter/material.dart';

class RowHomePage extends StatelessWidget {
  RowHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Expanded(flex: 1, child: Container(color: Colors.yellow, height: 60)),
          Container(color: Colors.red, width: 100, height: 180,),
          Container(color: Colors.blue, width: 60, height: 80,),
          Expanded(flex: 1, child: Container(color: Colors.green, height: 60))
        ]
    );
  }
}

