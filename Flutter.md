
#### Background

在计算机系统中，图像的显示需要 CPU、GPU 和显示器一起配合完成：
CPU 负责图像数据计算，GPU 负责图像数据渲染，而显示器则负责最终图像显示。
CPU 把计算好的、需要显示的内容交给 GPU，
由 GPU 完成渲染后放入帧缓冲区，随后视频控制器根据垂直同步信号（VSync）以每秒 60 次的速度，
从帧缓冲区读取帧数据交由显示器完成图像显示。

而 Flutter 作为跨平台开发框架也采用了这种底层方案。下面有一张更为详尽的示意图来解释 Flutter 的绘制原理。
(render.png)

Flutter 关注如何尽可能快地在两个硬件时钟的 VSync 信号之间计算并合成视图数据，
然后通过 Skia 交给 GPU 渲染：UI 线程使用 Dart 来构建视图结构数据，
这些数据会在 GPU 线程进行图层合成，
随后交给 Skia（Skia 是一款用 C++ 开发的、性能彪悍的 2D 图像绘制引擎） 引擎加工成 GPU 数据，而这些数据会通过 OpenGL 最终提供给 GPU 渲染，
因此可以在最大程度上保证一款应用在不同平台、不同设备上的体验一致性。

---

Flutter 是构建 Google 物联网操作系统 Fuchsia 的 SDK，主打跨平台、高保真、高性能。

Dart 同时支持即时编译 JIT 和事前编译 AOT。
在开发期使用 JIT，开发周期异常短，调试方式颠覆常规（支持有状态的热重载）；
而发布期使用 AOT，本地代码的执行更高效，代码性能和用户体验也更卓越。

进行 App 开发时，我们往往会关注的一个问题是：

>如何结构化地组织视图数据(Widget)，提供给渲染引擎(Skia)，最终完成界面显示。

Widget 它只是一份轻量级的数据结构。

Element 它承载了视图构建的上下文数据，是连接结构化的配置信息到完成最终渲染的桥梁。

RenderObject 是主要负责实现视图渲染的对象，布局和绘制在这里完成。

>Widget 是 Flutter 世界里对视图的一种结构化描述，里面存储的是有关视图渲染的配置信息；
>Element 则是 Widget 的一个实例化对象，将 Widget 树的变化做了抽象，能够做到只将真正需要修改的部分同步到真实的 Render Object 树中，
>最大程度地优化了从结构化的配置信息到完成最终渲染的过程；
>而 RenderObject，则负责实现视图的最终呈现，通过布局、绘制完成界面的展示。

```
abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin implements HitTestTarget {
  ...
  void layout(Constraints constraints, { bool parentUsesSize = false }) {...}
  
  void paint(PaintingContext context, Offset offset) { }
}
```

StatelessWidget 和 StatefulWidget 只是用来组装控件的容器。

Widget 是不可变的，更新则意味着销毁 + 重建（build）。StatelessWidget 是静态的，一旦创建则无需更新；
而对于 StatefulWidget 来说，在 State 类中调用 setState 方法更新数据，会触发视图的销毁和重建，也将间接地触发其每个子 Widget 的销毁和重建。

因此，避免无谓的 StatefulWidget 使用，是提高 Flutter 应用渲染性能最简单也是最直接的手段。

---

#### 生命周期

**创建**

```
构造方法 -> initState -> didChangeDependencies -> build，随后完成页面渲染。
```

**更新**

1，setState

>当状态数据发生变化时

2，didChangeDependencies

>系统语言 Locale 或应用主题改变时，系统会通知 State 执行 didChangeDependencies 回调

3，didUpdateWidget

>当 Widget 的配置发生变化时，比如，父 Widget 触发重建（即父 Widget 的状态发生变化时），热重载时，系统会调用这个函数。

**销毁**

1，deactivate

>组件被移除，组件不可见

2，dispose

>组件就要被销毁了，所以我们可以在这里进行最终的资源释放、移除监听、清理环境，等等。

在 Flutter 中，我们可以利用 WidgetsBindingObserver ，通过重写生命周期回调方法，来监听 App 的生命周期并做相应的处理。

```
abstract class WidgetsBindingObserver {
  //页面pop
  Future<bool> didPopRoute() => Future<bool>.value(false);
  //页面push
  Future<bool> didPushRoute(String route) => Future<bool>.value(false);
  //系统窗口相关改变回调，如旋转
  void didChangeMetrics() { }
  //文本缩放系数变化
  void didChangeTextScaleFactor() { }
  //系统亮度变化
  void didChangePlatformBrightness() { }
  //本地化语言变化
  void didChangeLocales(List<Locale> locale) { }
  //App生命周期变化
  void didChangeAppLifecycleState(AppLifecycleState state) { }
  //内存警告回调
  void didHaveMemoryPressure() { }
  //Accessibility相关特性回调
  void didChangeAccessibilityFeatures() {}
}
```

```

class _MyHomePageState extends State<MyHomePage>  with WidgetsBindingObserver{
//这里你可以再回顾下，第7篇文章“函数、类与运算符：Dart是如何处理信息的？”中关于Mixin的内容
...
  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);//注册监听器
  }
  @override
  @mustCallSuper
  void dispose(){
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);//移除监听器
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("$state");
    if (state == AppLifecycleState.resumed) {
      //do sth
      //1.从前台退居后台，打印的是inactive->paused，但你忘了它之前的状态是resumed；
      //2.从后台进入前台，打印的是inactive->resumed，但你忘了它之前的状态是paused
    }
  }
}
```

#### Widget

- Text

```
// 在一段字符串中支持多种混合展示样式。
TextStyle blackStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.black); //黑色样式

TextStyle redStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red); //红色样式

Text.rich(
    TextSpan(
        children: <TextSpan>[
          TextSpan(text:'文本是视图系统中常见的控件，它用来显示一段特定样式的字符串，类似', style: redStyle), //第1个片段，红色样式 
          TextSpan(text:'Android', style: blackStyle), //第1个片段，黑色样式 
          TextSpan(text:'中的', style:redStyle), //第1个片段，红色样式 
          TextSpan(text:'TextView', style: blackStyle) //第1个片段，黑色样式 
        ]),
  textAlign: TextAlign.center,
);
```

- Image

```
// 加载本地资源图片，如 
Image.asset(‘images/logo.png’)；

// 加载本地（File 文件）图片，如 
Image.file(new File(’/storage/xxx/xxx/test.jpg’))；

// 加载网络图片，如 
Image.network('http://xxx/xxx/test.gif') 
```

- FadeInImage

>在加载网络图片的时候，为了提升用户的等待体验，我们往往会加入占位图、加载动画等元素，

```
FadeInImage.assetNetwork(
  placeholder: 'assets/loading.gif', //gif占位
  image: 'https://xxx/xxx/xxx.jpg',
  fit: BoxFit.cover, //图片拉伸模式
  width: 200,
  height: 200,
)
```

- CachedNetworkImage

>支持缓存到文件系统

```
CachedNetworkImage(
        imageUrl: "http://xxx/xxx/jpg",
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
     )
```

#### ListView

```
// 如果提前设置好 itemExtent，ListView 则可以提前计算好每一个列表项元素的相对位置，以及自身的视图高度，省去了无谓的计算。
ListView.builder(
    itemCount: 100, //元素个数
    itemExtent: 50.0, //列表项高度
    itemBuilder: (BuildContext context, int index) => ListTile(title: Text("title $index"), subtitle: Text("body $index"))
);

// 使用 ListView.separated 设置分割线。
ListView.separated(
    itemCount: 100,
    separatorBuilder: (BuildContext context, int index) => index %2 ==0? Divider(color: Colors.green) : Divider(color: Colors.red),//index为偶数，创建绿色分割线；index为奇数，则创建红色分割线
    itemBuilder: (BuildContext context, int index) => ListTile(title: Text("title $index"), subtitle: Text("body $index"))//创建子Widget
)
```

**Flutter 是如何解决多 ListView 嵌套时，页面滑动效果不一致的问题的呢？**

>在 Flutter 中有一个专门的控件 CustomScrollView，用来处理多个需要自定义滚动效果的 Widget。
>在 CustomScrollView 中，这些彼此独立的、可滚动的 Widget 被统称为 Sliver。
>比如，ListView 的 Sliver 实现为 SliverList，AppBar 的 Sliver 实现为 SliverAppBar。
>这些 Sliver 不再维护各自的滚动状态，而是交由 CustomScrollView 统一管理，最终实现滑动效果的一致性。

```
CustomScrollView(
  slivers: <Widget>[
    SliverAppBar(//SliverAppBar作为头图控件
      title: Text('CustomScrollView Demo'),//标题
      floating: true,//设置悬浮样式
      flexibleSpace: Image.network("https://xx.jpg",fit:BoxFit.cover),//设置悬浮头图背景
      expandedHeight: 300,//头图控件高度
    ),
    SliverList(//SliverList作为列表控件
      delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(title: Text('Item #$index')),//列表项创建方法
        childCount: 100,//列表元素个数
      ),
    ),
  ]);
```

**在某些情况下，我们希望获取列表是否已经滑到底（顶）了？如何快速回到列表顶部？列表滚动是否已经开始，或者是否已经停下来了？**

ListView 的组件控制器则是 ScrollControler，我们可以通过它来获取视图的滚动信息，更新视图的滚动位置。

```
class MyAPPState extends State<MyApp> {
  ScrollController _controller;//ListView控制器
  bool isToTop = false;//标示目前是否需要启用"Top"按钮
  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {//为控制器注册滚动监听方法
      if(_controller.offset > 1000) {//如果ListView已经向下滚动了1000，则启用Top按钮
        setState(() {isToTop = true;});
      } else if(_controller.offset < 300) {//如果ListView向下滚动距离不足300，则禁用Top按钮
        setState(() {isToTop = false;});
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        ...
        //顶部Top按钮，根据isToTop变量判断是否需要注册滚动到顶部的方法
        RaisedButton(onPressed: (isToTop ? () {
                  if(isToTop) {
                    _controller.animateTo(.0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.ease
                    );//做一个滚动到顶部的动画
                  }
                }:null),child: Text("Top"),)
        ...
        ListView.builder(
                controller: _controller,//初始化传入控制器
                itemCount: 100,//列表元素总数
                itemBuilder: (context, index) => ListTile(title: Text("Index : $index")),//列表项构造方法
               )      
        ...   
    );

  @override
  void dispose() {
    _controller.dispose(); //销毁控制器
    super.dispose();
  }
}
```

**为了监听滚动类型的事件，我们需要将 NotificationListener(是一个 Widget) 添加为 ListView 的父容器，从而捕获 ListView 中的滚动回调**

```
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'ScrollController Demo',
    home: Scaffold(
      appBar: AppBar(title: Text('ScrollController Demo')),
      body: NotificationListener<ScrollNotification>(//添加NotificationListener作为父容器
        onNotification: (scrollNotification) {//注册通知回调
          if (scrollNotification is ScrollStartNotification) {//滚动开始
            print('Scroll Start');
          } else if (scrollNotification is ScrollUpdateNotification) {//滚动位置更新
            print('Scroll Update');
          } else if (scrollNotification is ScrollEndNotification) {//滚动结束
            print('Scroll End');
          }
        },
        child: ListView.builder(
          itemCount: 30,//列表元素个数
          itemBuilder: (context, index) => ListTile(title: Text("Index : $index")),//列表项创建方法
        ),
      )
    )
  );
}
```

#### 单子 Widget 布局：Container、Padding 与 Center

**Flutter 的 Container 仅能包含一个子 Widget**

```
Container(
  child: Text('Container（容器）在UI框架中是一个很常见的概念，Flutter也不例外。'),
  padding: EdgeInsets.all(18.0), // 内边距
  margin: EdgeInsets.all(44.0), // 外边距
  width: 180.0,
  height: 240,
  alignment: Alignment.center, // 子Widget居中对齐
  decoration: BoxDecoration( //Container样式
    color: Colors.red, // 背景色
    borderRadius: BorderRadius.circular(10.0), // 圆角边框
  ),
)


Padding(
  padding: EdgeInsets.all(44.0),
  child: Text('Container（容器）在UI框架中是一个很常见的概念，Flutter也不例外。'),
);


Scaffold(
  body: Center(child: Text("Hello")) // This trailing comma makes auto-formatting nicer for build methods.
);
```

#### 多子 Widget 布局：Row、Column 与 Expanded

>单纯使用 Row 和 Column 控件，在子 Widget 的尺寸较小时，无法将容器填满，视觉样式比较难看。
>对于这样的场景，我们可以通过 Expanded(类似于 Android 的百分比) 控件，来制定分配规则填满容器的剩余空间。

我们可以根据主轴与纵轴，设置子 Widget 在这两个方向上的对齐规则 mainAxisAlignment 与 crossAxisAlignment。
比如，主轴方向 start 表示靠左对齐、center 表示横向居中对齐、end 表示靠右对齐、spaceEvenly 表示按固定间距对齐；
而纵轴方向 start 则表示靠上对齐、center 表示纵向居中对齐、end 表示靠下对齐。（这说的都是 Row 方式的排列）

#### 层叠 Widget 布局：Stack 与 Positioned

Stack 提供了层叠布局的容器，而 Positioned 则提供了设置子 Widget 位置的能力。

>Positioned 控件只能在 Stack 中使用，在其他容器中使用会报错。

#### Flutter 由 ThemeData 来统一管理主题的配置信息。

#### 依赖管理

Flutter 并没有像 Android 那样预先定义资源的目录结构，所以我们可以把资源存放在项目中的任意目录下，
只需要使用根目录下的 pubspec.yaml 文件，对这些资源的所在位置进行显式声明就可以了。

在 Flutter 中，资源采用先声明后使用的机制，在 pubspec.yaml 显式地声明资源路径后，才可以使用

pubspec.yaml 是包的配置文件，包含了包的元数据（比如，包的名称和版本）、
运行环境（也就是 Dart SDK 与 Fluter SDK 版本）、外部依赖、内部配置（比如，资源管理）。

```
flutter:
  assets:
    - assets/background.jpg   #挨个指定资源路径
    - assets/loading.gif  #挨个指定资源路径
    - assets/result.json  #挨个指定资源路径
    - assets/icons/    #子目录批量指定
    - assets/ #根目录也是可以批量指定的

// 字体
fonts:
  - family: RobotoCondensed  #字体名字
    fonts:
      - asset: assets/fonts/RobotoCondensed-Regular.ttf #普通字体
      - asset: assets/fonts/RobotoCondensed-Italic.ttf 
        style: italic  #斜体
      - asset: assets/fonts/RobotoCondensed-Bold.ttf 
        weight: 700  #粗体
```

由于 Flutter 启动时依赖原生系统运行环境，因此我们还需要去原生工程中，设置相应的 App 启动图标和启动图。

与 Android 中的 JCenter/Maven、Dart 提供了官方的包仓库 Pub。通过 Pub，我们可以很方便地查找到有用的第三方包。

Dart 提供包管理工具 Pub 的真正目的是，让你能够找到真正好用的、经过线上大量验证的库。

我们可以访问 https://pub.dev/ 来获取可用的第三方包

```
dependencies:
  package1:
    path: ../package1/  #路径依赖
  date_format:
    git:
      url: https://github.com/xxx/package2.git #git依赖
```

对于依赖的指定，可以以区间的方式确定版本兼容范围，
也可以指定本地路径、Git、Pub 这三种不同的数据源，
包管理工具会找出同时满足每个依赖包版本约束的包版本，然后依次下载，
并通过.packages 文件建立下载缓存与包名的映射，
最后统一将当前状态下，实际安装的各个包的具体来源和版本号记录至 pubspec.lock 文件。

在完成了所有依赖包的下载后，Pub 会在应用的根目录下创建.packages 文件，将依赖的包名与系统缓存中的包文件路径进行映射，方便后续维护。

**pubspec.yaml、.packages 与 pubspec.lock 这三个文件，在包管理中的具体作用是什么？**

- pubspec.yaml 是声明依赖哪些包的配置文件

- .packages 是表示包在本地目录缓存的地址

- pubspec.lock 是把依赖锁死的文件

只有 pubspec.yaml 需要自己编写 其它两个文件会自动生成。

** .packages 与 pubspec.lock 是否需要做代码版本管理呢？为什么？**

- pubspec.lock 需要做版本管理，因为 lock 文件把版本锁定，统一工程环境

- .packages不需要版本管理，因为跟本地环境有关，无法做到统一

#### Summary

Flutter与原生在不同的布局行为上定义了常见的基本容器，不过对待特殊的布局样式，原生可以通过设置基本容器的属性搞定，
而Flutter则会选择在外层再包装一层布局样式，通过组合搞定。





























