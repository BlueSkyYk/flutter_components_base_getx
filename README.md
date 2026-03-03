# flutter_components_base_getx

基于 GetX 的 Flutter 通用组件库，提供完整的页面生命周期管理和常用基础组件。

[![pub package](https://img.shields.io/pub/v/flutter_components_base_getx.svg)](https://pub.dev/packages/flutter_components_base_getx)

## ✨ 特性

- 🔄 **完整的生命周期管理** - 自动处理页面的显示/隐藏，考虑应用前后台状态
- 🎯 **BasePage + BaseController** - 简化页面开发，自动管理 Controller
- 📱 **路由感知** - 通过 `AppRouteObserver` 追踪页面状态
- 🚀 **列表项生命周期** - `BaseItemController` 用于列表项的精细化管理
- 💾 **状态保持** - `KeepAliveWrapper` 轻松保持页面状态
- 🎨 **响应式数据模型** - 封装好的 `ListenableDataModel` 系列
- 🛡️ **手势返回控制** - 简单控制页面的返回行为

## 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_components_base_getx: ^1.0.7
  get: ^4.7.3
```

然后运行：

```bash
flutter pub get
```

## 🚀 快速开始

### 1. 配置 MaterialApp

在 MaterialApp 中添加 `appRouteObserver`（必须！）：

```dart
import 'package:flutter_components_base_getx/component.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorObservers: [appRouteObserver],  // ⬅️ 重要：必须添加
      home: HomePage(),
    );
  }
}
```

### 2. 创建页面

```dart
import 'package:flutter_components_base_getx/base/base_controller.dart';
import 'package:flutter_components_base_getx/base/base_page.dart';

// Controller
class HomeController extends BaseController {
  final counter = 0.obs;

  @override
  void onPageInit() {
    super.onPageInit();
    print('页面初始化（只调用一次）');
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print('页面显示（可能多次，考虑前后台切换）');
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print('页面隐藏');
  }

  void increment() => counter++;
}

// Page
class HomePage extends BasePage<HomeController> {
  HomePage({super.key}) : super(controller: HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Obx(() => Text('${controller.counter.value}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 📚 核心组件

### BasePage + BaseController

页面的基础组件，自动处理生命周期。

**生命周期钩子**：
- `onPageInit()` - 页面初始化（只调用一次）
- `onPageShow()` - 页面可见时（可多次调用，考虑前后台）
- `onPageHide()` - 页面不可见时
- `onPageDispose()` - 页面销毁时

**可见性判断**：只有当应用在前台且页面在顶层时，才认为页面可见。

### BaseService

用于创建全局服务，集成 ListenerMixin。

```dart
class UserService extends BaseService {
  final _userName = Rx<String>('');

  ListenableDataModel<String> get userNameModel =>
      ListenableDataModel(_userName);

  @override
  void onInit() {
    super.onInit();
    // 使用 ListenerMixin 监听数据变化
    listen(_userName, (value) {
      print('用户名变化: $value');
    });
  }
}
```

### BaseItemController

用于列表项的生命周期管理。

```dart
class ListItemController extends BaseItemController {
  @override
  void onPageShow() {
    super.onPageShow();
    print('列表项可见');
    // 启动动画、加载数据等
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print('列表项不可见');
    // 停止动画、释放资源等
  }
}

// 使用：需要手动调用 updateItemShowStatus
controller.updateItemShowStatus(isVisible);
```

### KeepAliveWrapper

保持 Widget 状态不被销毁，适用于 TabBarView、PageView 等场景。

```dart
TabBarView(
  children: [
    KeepAliveWrapper(
      child: TabPage1(),
    ),
    KeepAliveWrapper(
      child: TabPage2(),
    ),
  ],
)
```

### AppRouteObserver

全局路由观察器，追踪当前顶层路由。

```dart
// 获取当前顶层路由
final topRoute = appRouteObserver.currentTopRoute;

// 监听路由可见性变化
appRouteObserver.visibilityStream.listen((_) {
  print('路由可见性变化');
});
```

### ListenerMixin

简化响应式监听，自动管理 Worker 生命周期。

```dart
class MyController extends BaseController {
  final data = Rx<String>('');

  @override
  void onInit() {
    super.onInit();

    // 使用 listen，自动清理
    listen(data, (value) {
      print('数据变化: $value');
    });

    // 监听多个数据
    listenAll([data1, data2], (value) {
      print('任一数据变化');
    });
  }

  // onClose 时会自动 dispose 所有 Worker
}
```

## 🎯 高级功能

### 控制手势返回

```dart
class MyController extends BaseController {
  void enableBackGesture(bool enable) {
    updateCanPop(enable);
  }
}

// 在页面中使用
controller.updateCanPop(false);  // 禁用手势返回
controller.updateCanPop(true);   // 启用手势返回
```

### 处理返回结果

```dart
class MyController extends BaseController {
  @override
  void onPopInvokedWithResult(bool didPop, dynamic result) {
    super.onPopInvokedWithResult(didPop, result);
    if (result != null) {
      print('收到返回结果: $result');
    }
  }
}

// 返回时携带结果
Get.back(result: 'some data');
```

### Controller 管理

```dart
// 默认：页面销毁时不删除 Controller
BasePage(controller: MyController());

// 页面销毁时自动删除 Controller
BasePage(
  controller: MyController(),
  disposeDeleteController: true,
);

// 使用 tag 管理多个实例
BasePage(
  controller: MyController(),
  tag: 'instance1',
);
```

### TickerProvider

BaseController 自动提供 TickerProvider，可用于动画：

```dart
class MyController extends BaseController {
  late AnimationController animController;

  @override
  void onPageInit() {
    super.onPageInit();
    animController = AnimationController(
      vsync: tickerProvider!,  // 自动提供
      duration: Duration(seconds: 1),
    );
  }
}
```

## 📖 完整示例

查看 [example](./example) 目录获取完整的可运行示例：

- **home_page.dart** - 基础生命周期管理
- **detail_page.dart** - 手势返回控制和结果传递
- **list_page.dart** - BaseItemController 使用
- **tab_page.dart** - KeepAliveWrapper 状态保持
- **user_service.dart** - BaseService 和 ListenableDataModel

运行示例：

```bash
cd example
flutter pub get
flutter run
```

## ⚠️ 注意事项

### 必须配置 AppRouteObserver

```dart
MaterialApp(
  navigatorObservers: [appRouteObserver],  // 必须添加！
  // ...
)
```

否则生命周期钩子不会被调用。

### 生命周期调用时机

- `onPageInit()` - State.initState() 时
- `onPageShow()` - 页面可见且应用在前台
- `onPageHide()` - 页面不可见或应用进入后台
- `onPageDispose()` - State.dispose() 时

### BaseItemController 需要手动调用

```dart
// 在 VisibilityDetector 或类似组件中
controller.updateItemShowStatus(isVisible);
```

## 🐛 常见问题

查看 [FAQ.md](./FAQ.md) 了解常见问题和解决方案。

### Q: 生命周期钩子没有被调用？

A: 确保在 MaterialApp 中添加了 `navigatorObservers: [appRouteObserver]`。

### Q: 如何控制手势返回？

A: 使用 `controller.updateCanPop(false)` 禁用，`updateCanPop(true)` 启用。

### Q: BaseItemController 什么时候用？

A: 用于列表项、GridView 的 item 等需要独立生命周期管理的场景。

### Q: KeepAliveWrapper 和 BaseItemController 的区别？

A: KeepAliveWrapper 保持 Widget 不被销毁，BaseItemController 管理 item 的显示/隐藏状态。

## 🔗 相关资源

- [pub.dev](https://pub.dev/packages/flutter_components_base_getx)
- [GitHub](https://github.com/BlueSkyYk/flutter_components_base_getx)
- [GetX 文档](https://pub.dev/packages/get)
- [问题反馈](https://github.com/BlueSkyYk/flutter_components_base_getx/issues)

## 📝 更新日志

查看 [CHANGELOG.md](./CHANGELOG.md) 了解版本历史和更新内容。

## 📄 许可证

MIT License - 详见 [LICENSE](./LICENSE) 文件

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**如果这个库对您有帮助，请给个 Star ⭐️**
