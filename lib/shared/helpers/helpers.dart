import 'package:flutter/widgets.dart';
import 'package:slidesync/routes/app_router.dart';

/// To be safer, use for just one purpose only or view rather
void useRootStateContext(void Function(BuildContext context) run) {
  final currContext = rootNavigatorKey.currentState?.context;
  if (currContext != null && currContext.mounted) run(currContext);
}

/// To be safer, use for just one purpose only or view rather
Future<T?> asyncUseRootStateContext<T>(Future<T> Function(BuildContext context) run) async {
  final currContext = rootNavigatorKey.currentState?.context;
  if (currContext != null && currContext.mounted) return await run(currContext);
  return null;
}
