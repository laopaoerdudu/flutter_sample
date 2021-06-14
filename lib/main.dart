import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ListView sample'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            body: TabBarView(
              children: [
                ParallelWidget(),
                ScrollNotificationWidget(),
                ScrollControllerWidget()
              ],
            ),
            bottomNavigationBar: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.home),
                  text: "视差",
                ),
                Tab(
                  icon: Icon(Icons.rss_feed),
                  text: "Notification",
                ),
                Tab(
                  icon: Icon(Icons.perm_identity),
                  text: "Controller",
                )
              ],
              unselectedLabelColor: Colors.blueGrey,
              labelColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.red,
            )));
  }
}

class ParallelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        title: Text('SliverAppBar widget'),
        floating: true,
        flexibleSpace: Image.network(
            "https://media-cdn.tripadvisor.com/media/photo-s/13/98/8f/c2/great-wall-hiking-tours.jpg",
            fit: BoxFit.cover),
        expandedHeight: 280,
      ),
      SliverList(
          delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item #$index')),
              childCount: 100))
    ]);
  }
}

class ScrollNotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Scroll Notification Sample",
      home: Scaffold(
          appBar: AppBar(title: Text('ScrollController Demo')),
          body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  print('Scroll Start');
                } else if (scrollNotification is ScrollUpdateNotification) {
                  print('Scroll Update');
                } else if (scrollNotification is ScrollEndNotification) {
                  print('Scroll End');
                }
                throw UnimplementedError();
              },
              child: ListView.builder(
                itemCount: 30, // 列表元素个数
                itemBuilder: (context, index) =>
                    ListTile(title: Text("Index : $index")), // 列表项创建方法
              ))),
    );
  }
}

class ScrollControllerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScrollControllerState();
  }
}

class _ScrollControllerState extends State<ScrollControllerWidget> {
  bool isToTop = false;
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {
      // 为控制器注册滚动监听方法
      if (_controller.offset > 1000) {
        // 如果 ListView 已经向下滚动了 1000，则启用 Top 按钮
        setState(() {
          isToTop = true;
        });
      } else if (_controller.offset < 300) {
        // 如果 ListView 向下滚动距离不足 300，则禁用 Top 按钮
        setState(() {
          isToTop = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scroll Controller Widget")),
      body: Column(children: <Widget>[
        Container(
            height: 40.0,
            child: ElevatedButton(
                onPressed: (isToTop
                    ? () {
                        if (isToTop) {
                          _controller.animateTo(.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.ease); // 做一个滚动到顶部的动画
                        }
                      }
                    : null),
                child: Text("Top"))),
        Expanded(
          child: ListView.builder(
            controller: _controller, // 初始化传入控制器
            itemCount: 100, // 列表元素总数
            itemBuilder: (context, index) =>
                ListTile(title: Text("Index : $index")), // 列表项构造方法
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 销毁控制器
    super.dispose();
  }
}
