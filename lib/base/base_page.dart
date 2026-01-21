import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../component.dart';
import 'base_controller.dart';

abstract class BasePage<Controller extends BaseController>
    extends StatefulWidget {
  BasePage({
    super.key,
    required Controller controller,
    this.tag,
    this.disposeDeleteController = false,
    this.forceDeleteController = true,
  }) : _controller = Get.isRegistered<Controller>(tag: tag)
           ? Get.find<Controller>(tag: tag)
           : Get.put(controller, tag: tag);

  final String? tag;
  final bool disposeDeleteController;
  final bool forceDeleteController;

  late final Controller _controller;

  Controller get controller => _controller;

  void initPage() {}

  void dispose() {}

  Widget build(BuildContext context);

  @override
  State<BasePage> createState() => _BasePageState<Controller>();
}

class _BasePageState<Controller extends BaseController> extends State<BasePage>
    with WidgetsBindingObserver, RouteAware, TickerProviderStateMixin {
  PageRoute? _route;
  bool _isVisible = false;
  bool _isAppInForeground = true;

  late final StreamSubscription _visibilitySub;

  bool get isTopPage =>
      _route != null && appRouteObserver.currentTopRoute == _route;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _visibilitySub = appRouteObserver.visibilityStream.listen((_) {
      _updateVisibility();
    });
    super.initState();
    widget.controller.setTickerProvider(this);
    widget.initPage();
    widget.controller.pageInit();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.canGesturePop,
      builder: (context, value, child) {
        return PopScope<dynamic>(
          canPop: value,
          onPopInvokedWithResult: widget.controller.popInvokedWithResult,
          child: widget.build(context),
        );
      },
    );
  }

  @override
  void dispose() {
    _visibilitySub.cancel();
    _isVisible = false;
    _updateVisibility();
    WidgetsBinding.instance.removeObserver(this);
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    widget.controller.removeTickerProvider();
    widget.controller.pageDispose();
    if (widget.disposeDeleteController) {
      Get.delete<Controller>(
        tag: widget.tag,
        force: widget.forceDeleteController,
      );
    }
    widget.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPop() {
    // Logger().i("didPop - $_route");
    _updateVisibility();
  }

  @override
  void didPush() {
    // Logger().i("didPush - $_route");
    _updateVisibility();
  }

  @override
  void didPushNext() {
    // Logger().i("didPushNext - $_route");
    _updateVisibility();
  }

  @override
  void didPopNext() {
    // Logger().i("didPopNext - $_route");
    _updateVisibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Logger().i("didChangeAppLifecycleState: $state");
    if (!isTopPage) return;
    switch (state) {
      case AppLifecycleState.resumed: // 应用回到前台
        _isAppInForeground = true;
        break;
      case AppLifecycleState.paused: // 应用进入后台
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive: // 下拉通知栏、多任务、锁屏
        _isAppInForeground = false;
        break;
      case AppLifecycleState.detached: // App 即将销毁
        break;
    }
    _updateVisibility();
  }

  void _updateVisibility() {
    final nowVisible = _isAppInForeground && (_route?.isCurrent ?? false);
    if (_isVisible == nowVisible) return;
    _isVisible = nowVisible;
    if (_isVisible) {
      widget.controller.pageShow();
    } else {
      widget.controller.pageHide();
    }
  }
}
