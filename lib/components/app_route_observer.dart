import 'dart:async';

import 'package:flutter/material.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  PageRoute? _currentTopRoute;

  PageRoute? get currentTopRoute => _currentTopRoute;

  final _visibilityController = StreamController<void>.broadcast();

  Stream<void> get visibilityStream => _visibilityController.stream;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _currentTopRoute = route is PageRoute ? route : null;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _currentTopRoute = previousRoute is PageRoute ? previousRoute : null;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _currentTopRoute = newRoute is PageRoute ? newRoute : null;
    _notifyVisibilityUpdated();
  }

  void _notifyVisibilityUpdated() {
    _visibilityController.add(null);
  }
}
