import 'dart:async';

import 'package:flutter/material.dart';

/// 全局路由观察器
///
/// 用于跟踪当前顶层路由和路由可见性变化
/// 必须在 MaterialApp 中注册：
/// ```dart
/// MaterialApp(
///   navigatorObservers: [appRouteObserver],
///   ...
/// )
/// ```
///
/// 注意：这通常作为全局单例使用（见 component.dart），
/// 在正常应用场景中不需要手动 dispose，
/// 只在测试或特殊场景下需要调用 dispose() 清理资源
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  PageRoute? _currentTopRoute;

  PageRoute? get currentTopRoute => _currentTopRoute;

  final _visibilityController = StreamController<void>.broadcast();

  Stream<void> get visibilityStream => _visibilityController.stream;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _currentTopRoute = route is PageRoute ? route : null;
    _notifyVisibilityUpdated();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _currentTopRoute = previousRoute is PageRoute ? previousRoute : null;
    _notifyVisibilityUpdated();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _currentTopRoute = newRoute is PageRoute ? newRoute : null;
    _notifyVisibilityUpdated();
  }

  void _notifyVisibilityUpdated() {
    if (!_visibilityController.isClosed) {
      _visibilityController.add(null);
    }
  }

  /// 释放资源
  ///
  /// 注意：由于 AppRouteObserver 通常作为全局单例使用，
  /// 在正常应用场景中不需要调用此方法。
  ///
  /// 仅在以下场景需要调用：
  /// - 单元测试：测试结束后清理资源
  /// - 动态模块：模块卸载时清理
  /// - 特殊场景：需要重新初始化 observer 时
  ///
  /// 示例（测试中）：
  /// ```dart
  /// tearDown(() {
  ///   appRouteObserver.dispose();
  /// });
  /// ```
  void dispose() {
    _visibilityController.close();
  }
}
