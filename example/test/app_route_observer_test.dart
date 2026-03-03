import 'package:flutter/material.dart';
import 'package:flutter_components_base_getx/components/app_route_observer.dart';
import 'package:flutter_test/flutter_test.dart';

/// AppRouteObserver 测试
/// 展示何时需要调用 dispose()
void main() {
  group('AppRouteObserver', () {
    late AppRouteObserver observer;

    setUp(() {
      // 为每个测试创建独立的 observer 实例
      observer = AppRouteObserver();
    });

    tearDown(() {
      // 测试结束后清理资源
      // 这是需要调用 dispose() 的场景之一
      observer.dispose();
    });

    test('应该跟踪当前顶层路由', () {
      expect(observer.currentTopRoute, isNull);

      // 模拟路由 push
      final route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => Container(),
      );

      observer.didPush(route, null);
      expect(observer.currentTopRoute, equals(route));
    });

    test('应该在路由变化时发送通知', () async {
      int notificationCount = 0;

      // 订阅可见性变化流
      final subscription = observer.visibilityStream.listen((_) {
        notificationCount++;
      });

      // 模拟路由变化
      final route1 = PageRouteBuilder(
        pageBuilder: (_, __, ___) => Container(),
      );
      final route2 = PageRouteBuilder(
        pageBuilder: (_, __, ___) => Container(),
      );

      observer.didPush(route1, null);
      observer.didPush(route2, route1);
      observer.didPop(route2, route1);

      // 等待流事件处理
      await Future.delayed(const Duration(milliseconds: 10));

      expect(notificationCount, equals(3));

      // 清理订阅
      await subscription.cancel();
    });

    test('dispose 后应该关闭 stream', () async {
      bool streamClosed = false;

      // 订阅流，监听完成事件
      final subscription = observer.visibilityStream.listen(
        (_) {},
        onDone: () {
          streamClosed = true;
        },
      );

      // 调用 dispose
      observer.dispose();

      // 等待事件处理
      await Future.delayed(const Duration(milliseconds: 10));

      expect(streamClosed, isTrue);

      await subscription.cancel();
    });

    test('dispose 后尝试发送通知不应该崩溃', () {
      observer.dispose();

      // 这不应该崩溃
      final route = PageRouteBuilder(
        pageBuilder: (_, __, ___) => Container(),
      );

      expect(
        () => observer.didPush(route, null),
        returnsNormally,
      );
    });
  });

  group('全局单例场景', () {
    test('说明：全局 appRouteObserver 不需要 dispose', () {
      // 在实际应用中，全局的 appRouteObserver 是这样使用的：
      //
      // final AppRouteObserver appRouteObserver = AppRouteObserver();
      //
      // MaterialApp(
      //   navigatorObservers: [appRouteObserver],
      //   ...
      // )
      //
      // 这种情况下，observer 的生命周期与应用相同，
      // 不需要手动调用 dispose()，应用关闭时会自动清理

      expect(true, isTrue); // 占位测试
    });

    test('说明：只在以下场景需要 dispose', () {
      // 1. 单元测试：每个测试用例独立的 observer（如本文件的其他测试）
      // 2. 集成测试：测试结束后清理
      // 3. 动态模块：模块卸载时需要清理
      // 4. 热重载/热重启：某些场景下可能需要重置状态

      expect(true, isTrue); // 占位测试
    });
  });
}
