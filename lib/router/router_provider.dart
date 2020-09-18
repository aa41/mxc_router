import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract class RouterInterceptor {
  Route<dynamic> interceptor(RouteSettings settings);
}

abstract class IRouterProvider {
  Set<RouterInterceptor> _routerInterceptors = LinkedHashSet();

  Future<T> pushName<T>(BuildContext context, String routeName,
      {Object arguments});

  Future<T> pushNamedAndRemoveUntil<T>(
      BuildContext context, String newRouteName, RoutePredicate predicate,
      {Object arguments});

  Future<T> pushReplacementNamed<T>(BuildContext context, String routeName,
      {Object arguments});

  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
    BuildContext context,
    String routeName, {
    TO result,
    Object arguments,
  });

  void _addInterceptor(RouterInterceptor interceptor) {
    _routerInterceptors.add(interceptor);
  }

  Future<T> argumentsAsync<T>(BuildContext context);

  T arguments<T>(BuildContext context);

  Route<dynamic> injectGenerateRoute(RouteSettings settings) {
    for (RouterInterceptor interceptor in _routerInterceptors) {
      if (interceptor != null) {
        var route = interceptor.interceptor(settings);
        if (route != null) return route;
      }
    }
    return null;
  }

  Widget buildNotFoundWidget(RouteSettings settings);

  Route<dynamic> buildCustomRoute(
      String url, dynamic arguments, WidgetBuilder builder);

  Object injectInputArguments<T>(T arguments);

  T injectOutputArguments<T>(Object args);
}

class MXCRouter {
  static MXCRouter _instance = MXCRouter();

  static MXCRouter get instance => _instance;

  IRouterProvider _provider;

  RouteFactory _routeFactory;

  void registerRouterProvider(IRouterProvider provider) {
    this._provider = provider;
  }

  void registerRouterFactory(RouteFactory factory) {
    this._routeFactory = factory;
  }

  void addInterceptor(RouterInterceptor interceptor) {
    _provider._addInterceptor(interceptor);
  }

  RouteFactory get routeFactory => _routeFactory;

  IRouterProvider get provider {
    _provider ??= _DefaultRouterProvider();
    return _provider;
  }
}

class _DefaultRouterProvider extends IRouterProvider {
  @override
  Route buildCustomRoute(String url, dynamic arguments, WidgetBuilder builder) {
    return MaterialPageRoute(
        builder: builder,
        settings: RouteSettings(name: url, arguments: arguments));
  }

  @override
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
      BuildContext context, String routeName,
      {TO result, Object arguments}) {
    return Navigator.popAndPushNamed<T, TO>(context, routeName,
        result: result, arguments: arguments);
  }

  @override
  Future<T> pushName<T>(BuildContext context, String routeName,
      {Object arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  @override
  Future<T> pushNamedAndRemoveUntil<T>(
      BuildContext context, String newRouteName, predicate,
      {Object arguments}) {
    return Navigator.pushNamedAndRemoveUntil(context, newRouteName, predicate,
        arguments: arguments);
  }

  @override
  Future<T> pushReplacementNamed<T>(BuildContext context, String routeName,
      {Object arguments}) {
    return Navigator.pushReplacementNamed(context, routeName,
        arguments: arguments);
  }

  @override
  T arguments<T>(BuildContext context) {
    return ModalRoute?.of(context)?.settings?.arguments;
  }

  @override
  Future<T> argumentsAsync<T>(BuildContext context) async {
    if (ModalRoute?.of(context)?.settings?.arguments == null) {
      await SchedulerBinding.instance.endOfFrame;
      return ModalRoute?.of(context)?.settings?.arguments;
    }
    return ModalRoute?.of(context)?.settings?.arguments;
  }

  @override
  Widget buildNotFoundWidget(RouteSettings settings) {
    return ErrorWidget('not found ${settings.name}');
  }

  @override
  Object injectInputArguments<T>(T arguments) {
    return arguments;
  }

  @override
  T injectOutputArguments<T>(Object args) {
    return args;
  }
}

extension MXCContext on BuildContext {
  IRouterProvider get routerProvider => MXCRouter.instance.provider;
}
