import 'components/app_route_observer.dart';

/// 全局路由观察器单例
///
/// 用于所有 BasePage 的生命周期管理
/// 必须在 MaterialApp 中注册：
/// ```dart
/// MaterialApp(
///   navigatorObservers: [appRouteObserver],
///   ...
/// )
/// ```
///
/// 注意：这是全局单例，在应用的整个生命周期中存在，
/// 通常不需要手动 dispose。只在测试或特殊场景下才需要
/// 调用 appRouteObserver.dispose() 来清理资源
final AppRouteObserver appRouteObserver = AppRouteObserver();
