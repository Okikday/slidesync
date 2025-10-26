import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/routes/app_router.dart';

/// Helper class for accessing root context globally
class GlobalNav {
  GlobalNav._();

  /// Execute a function with the root context
  /// Use this when you need context for dialogs, overlays, etc.
  static void withContext(void Function(BuildContext context) run) {
    final context = rootNavigatorKey.currentState?.context ?? rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      run(context);
    }
  }

  /// Execute an async function with the root context
  /// Returns null if context is unavailable
  static Future<T?> withContextAsync<T>(Future<T> Function(BuildContext context) run) async {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      return await run(context);
    }
    return null;
  }

  /// Check if context is currently available
  static bool get isAvailable {
    final context = rootNavigatorKey.currentContext;
    return context != null && context.mounted;
  }

  /// Get the overlay state directly (useful for inserting OverlayEntry)
  static OverlayState? get overlay {
    return rootNavigatorKey.currentState?.overlay ??
        Overlay.of(rootNavigatorKey.currentContext ?? rootNavigatorKey.currentState!.context);
  }

  static void popGlobal() => GlobalNav.withContext((c) => c.pop());
}
