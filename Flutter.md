
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








