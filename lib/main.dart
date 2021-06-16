import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/theme.dart';

import 'data/DataTransferHomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: defaultTargetPlatform == TargetPlatform.iOS ? kIOSTheme : kAndroidTheme,
        home: DataTransferHomePage(title: 'Data sharing sample')
    );
  }
}




















