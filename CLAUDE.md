# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于 GetX 的 Flutter 包，提供了一套通用的基础组件和生命周期管理系统。

- **包名**: flutter_components_base_getx
- **核心依赖**: GetX (^4.7.3)
- **用途**: 为 Flutter 应用提供页面生命周期管理、响应式数据模型和路由观察功能

## 常用命令

```bash
# 安装依赖
flutter pub get

# 代码分析
flutter analyze

# 运行测试
flutter test

# 运行示例
cd example && flutter run

# 发布前检查
flutter pub publish --dry-run
```

## 核心架构

### 生命周期管理系统

本包的核心是一套完整的页面生命周期管理机制，整合了 GetX、Flutter 路由系统和应用前后台状态：

#### BasePage + BaseController 模式

- `BasePage` 是所有页面的基类，自动处理 controller 注册、生命周期事件和路由监听
- `BaseController` 扩展 GetxController，提供页面生命周期钩子：
  - `onPageInit()` - 页面初始化（仅一次）
  - `onPageShow()` - 页面可见时（可多次，考虑前后台切换）
  - `onPageHide()` - 页面不可见时
  - `onPageDispose()` - 页面销毁时

#### 可见性判断逻辑

页面只有在 **应用在前台** 且 **路由处于顶层（isCurrent）** 时才认为是可见的。

`BasePage` 通过 `RouteAware` 和 `WidgetsBindingObserver` 监听路由变化和应用生命周期，所有事件通过 `AppRouteObserver` 协调。

### 关键组件

#### AppRouteObserver

- 全局单例（`appRouteObserver`），定义在 `lib/component.dart`
- 跟踪当前顶层路由（`currentTopRoute`）
- 提供路由可见性变化流（`visibilityStream`）
- **必须在 MaterialApp 中使用**：`navigatorObservers: [appRouteObserver]`

#### ListenerMixin

- 提供 `listen()` 和 `listenAll()` 方法简化响应式监听
- 自动管理 Worker 的生命周期，在 controller dispose 时自动清理

#### BaseItemController

- 用于列表项的 controller（如 ListView 中的 item）
- 通过 `updateItemShowStatus()` 手动控制可见性
- 只有当 item 显示且页面可见时才触发 pageShow/pageHide

#### 响应式数据模型

`lib/base/base_service.dart` 提供了四种响应式数据包装类：
- `ListenableDataModel<T>` - 单个数据
- `ListenableListDataModel<T>` - 列表数据
- `ListenableMapDataModel<K, V>` - Map 数据
- `ListenableSetDataModel<T>` - Set 数据

每个模型都提供：
- `data` 属性 - 访问实际数据
- `listener` 属性 - 获取 RxInterface 用于监听变化

#### KeepAliveWrapper

- 用于在 TabBarView 或 PageView 中保持页面状态
- 简单包装 `AutomaticKeepAliveClientMixin`

## 使用模式

### 创建页面

```dart
class MyController extends BaseController {
  @override
  void onPageShow() {
    super.onPageShow();
    // 页面显示时的逻辑（如刷新数据）
  }
}

class MyPage extends BasePage<MyController> {
  MyPage({super.key}) : super(controller: MyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(/* ... */);
  }
}
```

### Controller 生命周期

- `BasePage` 构造函数会自动使用 `Get.put()` 注册 controller
- 如果 controller 已注册（通过 tag），则使用 `Get.find()` 获取现有实例
- 默认情况下，页面 dispose 时不会删除 controller（`disposeDeleteController: false`）
- 如需自动删除，设置 `disposeDeleteController: true`

### 手势返回控制

- `BaseController` 提供 `canGesturePop` ValueNotifier 控制页面是否可返回
- 使用 `updateCanPop(bool)` 动态更改（如表单编辑中防止误返回）

## 重要实现细节

### Widget 缓存策略

`BasePage` 的 `build` 方法使用成员变量 + ValueListenableBuilder child 参数实现 Widget 缓存：

```dart
Widget? _content;

@override
Widget build(BuildContext context) {
  return ValueListenableBuilder(
    valueListenable: widget.controller.canGesturePop,
    child: _content ??= widget.build(context),  // 只构建一次
    builder: (context, value, child) {
      return PopScope(
        canPop: value,
        child: child!,  // 使用预构建的 child
      );
    },
  );
}
```

**原理**：
- `_content` 成员变量生命周期与 State 一致
- 即使 State.build() 被多次调用（页面导航时），widget.build() 只执行一次
- 性能优化：避免页面导航时的不必要重建

### dispose 资源清理

使用嵌套 try-finally 确保关键资源被清理：

```dart
@override
void dispose() {
  try {
    _visibilitySub.cancel();
    _isVisible = false;
    _updateVisibility();
  } finally {
    try {
      WidgetsBinding.instance.removeObserver(this);
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      widget.controller.removeTickerProvider();
      widget.controller.pageDispose();
      if (widget.disposeDeleteController) {
        Get.delete<Controller>(tag: widget.tag, force: widget.forceDeleteController);
      }
      widget.dispose();
    } finally {
      super.dispose();  // 保证执行
    }
  }
}
```

### RouteAware 订阅管理

避免重复订阅：

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final route = ModalRoute.of(context);
  if (route is PageRoute && _route != route) {  // 检查是否真的变化
    if (_route != null) {
      appRouteObserver.unsubscribe(this);  // 先取消旧订阅
    }
    _route = route;
    appRouteObserver.subscribe(this, route);
  }
}
```

## 注意事项

### 必要配置

- **必须**在 MaterialApp 中添加 `navigatorObservers: [appRouteObserver]` 才能使生命周期正常工作
- `BaseController.tickerProvider` 由 BasePage 自动设置和清理，可用于 AnimationController
- `ListenerMixin.listen()` 创建的 Worker 会在 controller onClose 时自动 dispose
- BaseItemController 需要手动调用 `updateItemShowStatus()` 来同步可见性状态

### 常见陷阱

1. **忘记添加 navigatorObservers**：生命周期钩子不会被调用
2. **错误的 Controller 管理**：注意 `disposeDeleteController` 的使用
3. **BaseItemController 的手动调用**：必须手动调用 `updateItemShowStatus()`
4. **TickerProvider 使用时机**：只能在 pageInit 之后使用

## 最近修复（v1.0.8）

### 内存泄漏
- 在 `base_controller.dart` 的 `onClose()` 中添加 `canGesturePop.dispose()`
- 在 `app_route_observer.dart` 添加 `dispose()` 方法

### 性能优化
- 修复 Widget 缓存策略，避免页面导航时重复构建
- 防止 RouteAware 重复订阅

### 资源清理
- 使用 try-finally 保护 dispose 流程
- 确保所有资源正确清理

## 示例代码

查看 `example/` 目录获取完整的使用示例：
- **home_page.dart**: 基础生命周期和导航
- **detail_page.dart**: 手势返回控制和结果传递
- **list_page.dart**: BaseItemController 使用
- **tab_page.dart**: KeepAliveWrapper 使用
- **user_service.dart**: BaseService 和 ListenableDataModel 使用

## 开发建议

1. 创建新页面时，优先继承 `BasePage<YourController>`
2. 在 Controller 中使用 `listen()` 而不是手动创建 Worker
3. 需要动画时，使用 `controller.tickerProvider`
4. 列表项需要生命周期时，使用 `BaseItemController`
5. Tab/PageView 需要保持状态时，使用 `KeepAliveWrapper`
