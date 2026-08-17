import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'package:slidesync/routes/routes.dart';

typedef OverrideBuilder<In> =
    List<Override> Function(
      BuildContext _,
      GoRouterState state, [
      In? extra,
      String? id,
    ]);

class AutoRoute<In> {
  final bool isShell;
  final Routes<In, Object?>? route;

  final OverrideBuilder<In>? overrider;

  // Standard go_router properties
  final List<AutoRoute> routes;

  /// A manual page builder. Supplying this completely bypasses
  /// [_internalBuilder], meaning [idProvider] and [extraProvider] will NOT
  /// be applied — you are responsible for any ProviderScope wiring yourself.
  final GoRouterPageBuilder? pageBuilder;

  /// A manual widget builder. Supplying this completely bypasses the
  /// automatic provider-injection logic in [_internalBuilder] (it is
  /// invoked only to immediately delegate to this builder), meaning
  /// [idProvider] and [extraProvider] will NOT be applied.
  final GoRouterWidgetBuilder? builder;

  final ShellRoutePageBuilder? sPageBuilder;
  final ShellRouteBuilder? sBuilder;

  final bool caseSensitive;
  final FutureOr<String?> Function(BuildContext, GoRouterState)? redirect;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
  final GlobalKey<NavigatorState>? navigatorKey;
  final bool notifyRootObserver;
  final List<NavigatorObserver>? observers;
  final FutureOr<bool> Function(BuildContext, GoRouterState)? onExit;
  final String? restorationScopeId;

  const AutoRoute._(
    this.isShell,
    this.route, {
    this.overrider,
    this.routes = const [],
    this.builder,
    this.pageBuilder,
    this.sBuilder,
    this.sPageBuilder,
    this.caseSensitive = true,
    this.redirect,
    this.navigatorKey,
    this.parentNavigatorKey,
    this.notifyRootObserver = true,
    this.observers,
    this.onExit,
    this.restorationScopeId,
  });

  factory AutoRoute.shell({
    required List<AutoRoute> routes,
    ShellRoutePageBuilder? pageBuilder,
    ShellRouteBuilder? builder,
    OverrideBuilder? overrider,
    FutureOr<String?> Function(BuildContext, GoRouterState)? redirect,
    GlobalKey<NavigatorState>? navigatorKey,
    bool notifyRootObserver = true,
    List<NavigatorObserver>? observers,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    String? restorationScopeId,
  }) {
    assert(
      builder != null || pageBuilder != null,
      "Either pageBuilder or builder must be assigned",
    );
    return AutoRoute._(
      true,
      null,
      routes: routes,
      redirect: redirect,
      navigatorKey: navigatorKey,
      sPageBuilder: pageBuilder,
      sBuilder: builder,
      parentNavigatorKey: parentNavigatorKey,
      notifyRootObserver: notifyRootObserver,
      observers: observers,
      restorationScopeId: restorationScopeId,
      overrider: overrider,
    );
  }

  factory AutoRoute.route(
    Routes<In, Object?> route, {
    OverrideBuilder? overrider,
    List<AutoRoute> children = const [],
    GoRouterPageBuilder? pageBuilder,
    GoRouterWidgetBuilder? builder,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    FutureOr<String?> Function(BuildContext, GoRouterState)? redirect,
    bool caseSensitive = true,
    FutureOr<bool> Function(BuildContext, GoRouterState)? onExit,
  }) {
    assert(
      builder != null || pageBuilder != null,
      "You must provide a builder, or a pageBuilder",
    );
    return AutoRoute<In>._(
      false,
      route,
      routes: children,
      parentNavigatorKey: parentNavigatorKey,
      redirect: redirect,
      caseSensitive: caseSensitive,
      builder: builder,
      pageBuilder: pageBuilder,
      onExit: onExit,
      overrider: overrider,
    );
  }

  // ===========================================================================
  // Automated ProviderScope Injection
  // ===========================================================================
  ///
  /// IMPORTANT: This is the only path that applies [idProvider] and
  /// [extraProvider]. If a manual [builder] is set, this method just
  /// delegates to it immediately (step 1) without touching providers. If a
  /// manual [pageBuilder] is set, this method is never invoked at all (see
  /// [build], where `builder` is forced to `null` whenever [pageBuilder] is
  /// present). In both cases, supplying [idProvider]/[extraProvider]
  /// alongside [builder]/[pageBuilder] is asserted against in
  /// [AutoRoute.route] precisely because it would otherwise silently do
  /// nothing.
  Widget _internalBuilder(BuildContext context, GoRouterState state) {
    final overrides = overrider?.call(
      context,
      state,
      state.extra as In?,
      state.uri.queryParameters['id'],
    );
    if (overrides != null && overrides.isNotEmpty) {
      return ProviderScope(
        overrides: overrides,
        child: builder!(context, state),
      );
    }
    return builder!(context, state);
  }

  RouteBase _build([bool? isChild]) {
    if (isShell) {
      return ShellRoute(
        routes: routes.map((e) => e._build(false)).toList(),
        redirect: redirect,
        navigatorKey: navigatorKey,
        pageBuilder: sPageBuilder,
        builder: sBuilder,
        parentNavigatorKey: parentNavigatorKey,
        // notifyRootObserver: notifyRootObserver,
        observers: observers,
        restorationScopeId: restorationScopeId,
      );
    } else {
      return GoRoute(
        path: (isChild ?? false) ? route!.subPath : route!.path,
        name: route!.name,
        routes: routes.map((e) => e._build(true)).toList(),
        parentNavigatorKey: parentNavigatorKey,
        redirect: redirect,
        caseSensitive: caseSensitive,
        // pageBuilder, when present, takes priority over the automatic
        // ProviderScope-injecting builder — see the doc comments on
        // [pageBuilder] and [_internalBuilder] above.
        builder: _internalBuilder,
        pageBuilder: pageBuilder,
        onExit: onExit,
      );
    }
  }

  RouteBase build() => _build();
}
