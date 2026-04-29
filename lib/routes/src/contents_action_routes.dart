import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/modify_contents/redirect_contents_screen.dart';
import 'package:slidesync/routes/routes.dart';

Widget _fallbackContentActionScreen(String message) {
  return Scaffold(body: Center(child: Text(message)));
}

final contentActionsRoutes = [
  GoRoute(
    name: Routes.moveContents.name,
    path: Routes.moveContents.path,
    builder: (context, state) {
      final contents = Result.from(() => state.extra as List<ModuleContent>, fallback: null);
      if (contents == null) return _fallbackContentActionScreen('Unable to start move action');
      return RedirectContentsScreen.move(contents: contents);
    },
  ),
  GoRoute(
    name: Routes.copyContents.name,
    path: Routes.copyContents.path,
    builder: (context, state) {
      final contents = Result.from(() => state.extra as List<ModuleContent>, fallback: null);
      if (contents == null) return _fallbackContentActionScreen('Unable to start copy action');
      return RedirectContentsScreen.copy(contents: contents);
    },
  ),
  GoRoute(
    name: Routes.storeContents.name,
    path: Routes.storeContents.path,
    builder: (context, state) {
      final filePaths = Result.from(() => state.extra as List<String>, fallback: null);
      if (filePaths == null) return _fallbackContentActionScreen('Unable to start store action');
      return RedirectContentsScreen.store(files: filePaths);
    },
  ),
];
