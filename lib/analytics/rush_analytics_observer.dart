import 'dart:async';

import 'package:cleanmate_rush/analytics/rush_analytics.dart';
import 'package:flutter/material.dart';

/// Logs [RouteSettings.name] as Firebase screen views on navigation.
class RushAnalyticsNavigatorObserver extends NavigatorObserver {
  RushAnalyticsNavigatorObserver(this._analytics);

  final RushAnalytics _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _maybeLogScreen(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final route = newRoute;
    if (route != null) {
      _maybeLogScreen(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final restored = previousRoute;
    if (restored != null) {
      _maybeLogScreen(restored);
    }
  }

  void _maybeLogScreen(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) {
      return;
    }
    unawaited(_analytics.logScreenView(name));
  }
}
