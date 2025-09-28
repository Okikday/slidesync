import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/features/settings/presentation/views/settings_view.dart';

final settingsRoute = GoRoute(
  name: Routes.settings.name,
  path: Routes.settings.path,
  pageBuilder: (context, state) => PageAnimation.buildCustomTransitionPage(
    state.pageKey,
    type: TransitionType.rightToLeft,
    duration: Durations.extralong1,
    reverseDuration: Durations.medium1,
    curve: CustomCurves.defaultIosSpring,
    child: const SettingsView(),
  ),
);
