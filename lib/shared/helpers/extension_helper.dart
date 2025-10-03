import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/app.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/controllers/courses_view_controller/courses_pagination.dart';
import 'package:slidesync/shared/helpers/device_helper.dart';
import 'package:slidesync/shared/helpers/responsiveness_helper.dart';
import 'package:slidesync/shared/styles/theme/app_theme_model.dart';

extension ExtensionHelper on BuildContext {
  BuildContext get context => this;
  ThemeData get theme => Theme.of(context);
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  MediaQueryData get mediaQuery => MediaQuery.of(context);
  Size get screenSize => MediaQuery.of(this).size;
  double get deviceWidth => screenSize.width;
  double get deviceHeight => screenSize.height;
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get topPadding => padding.top;
  double get bottomPadding => padding.bottom;

  //
}

extension ResponsivenessExtension on BuildContext {
  DeviceType get deviceType => DeviceHelper.getDeviceType(this);
  double get hPadding => ResponsivenessHelper.resolveHPadding(this);
  double get defaultBtnDimension => ResponsivenessHelper.resolveSquareButtonSize(this);

  double get hPadding5 => hPadding * .5;
  double get hPadding7 => hPadding * .7;
}

extension AppProviderTheme on WidgetRef {
  AppThemeModel get theme => watch(appThemeProvider);
  bool get isDarkMode => watch(appThemeProvider.select((p) => p.isDarkTheme));

  // Core colors
  Color get primary => watch(appThemeProvider.select((p) => p.primary));
  Color get secondary => watch(appThemeProvider.select((p) => p.secondary));
  Color get surface => watch(appThemeProvider.select((p) => p.surface));
  Color get onSurface => watch(appThemeProvider.select((p) => p.onSurface));
  Color get background => watch(appThemeProvider.select((p) => p.background));
  Color get onBackground => watch(appThemeProvider.select((p) => p.onBackground));
  Color get onPrimary => watch(appThemeProvider.select((p) => p.onPrimary));
  Color get onSecondary => watch(appThemeProvider.select((p) => p.onSecondary));

  // Alt background colors
  Color get altBackgroundPrimary => watch(appThemeProvider.select((p) => p.altBackgroundPrimary));
  Color get altBackgroundSecondary => watch(appThemeProvider.select((p) => p.altBackgroundSecondary));

  // Supporting text colors
  Color get supportingText => watch(appThemeProvider.select((p) => p.supportingText));
  Color get backgroundSupportingText => watch(appThemeProvider.select((p) => p.backgroundSupportingText));

  // Remapped getters
  Color get primaryColor => watch(appThemeProvider.select((p) => p.primaryColor));
  Color get secondaryColor => watch(appThemeProvider.select((p) => p.secondaryColor));
  Color get cardColor => watch(appThemeProvider.select((p) => p.cardColor));
  Color get onCardColor => watch(appThemeProvider.select((p) => p.onCardColor));
  Color get backgroundColor => watch(appThemeProvider.select((p) => p.backgroundColor));
  Color get onBackgroundColor => watch(appThemeProvider.select((p) => p.onBackgroundColor));
  Color get scaffoldBackgroundColor => watch(appThemeProvider.select((p) => p.scaffoldBackgroundColor));
  Color get onScaffoldBackgroundColor => watch(appThemeProvider.select((p) => p.onScaffoldBackgroundColor));
  Color get surfaceColor => watch(appThemeProvider.select((p) => p.surfaceColor));
  Color get onSurfaceColor => watch(appThemeProvider.select((p) => p.onSurfaceColor));
  Color get altSurfaceColor => watch(appThemeProvider.select((p) => p.altSurfaceColor));
  Color get onAltSurfaceColor => watch(appThemeProvider.select((p) => p.onAltSurfaceColor));
  Color get onPrimaryColor => watch(appThemeProvider.select((p) => p.onPrimaryColor));
  Color get onSecondaryColor => watch(appThemeProvider.select((p) => p.onSecondaryColor));

  // Computed colors
  Color get adjustBgAndPrimaryWithLerp => watch(appThemeProvider.select((p) => p.adjustBgAndPrimaryWithLerp));
  Color get adjustBgAndPrimaryWithLerpExtra => watch(appThemeProvider.select((p) => p.adjustBgAndPrimaryWithLerpExtra));
  Color get adjustBgAndSecondaryWithLerp => watch(appThemeProvider.select((p) => p.adjustBgAndSecondaryWithLerp));
  Color get adjustBgAndSecondaryWithLerpExtra =>
      watch(appThemeProvider.select((p) => p.adjustBgAndSecondaryWithLerpExtra));

  // Gradient colors
  List<Color> get backgroundGradientColors => watch(appThemeProvider.select((p) => p.backgroundGradientColors));

  // Theme properties
  String get themeTitle => watch(appThemeProvider.select((p) => p.title));
  String? get fontFamily => watch(appThemeProvider.select((p) => p.fontFamily));
  Brightness get brightness => watch(appThemeProvider.select((p) => p.brightness));
}

extension StringExtension on String {
  Map get decodeJson => jsonDecode(this);
}

/// Others
///
extension CourseSortX on CourseSortOption {
  PlainCourseSortOption toPlain() {
    final n = name;
    final core = n.endsWith('Asc')
        ? n.substring(0, n.length - 3)
        : n.endsWith('Desc')
        ? n.substring(0, n.length - 4)
        : n;
    switch (core) {
      case 'name':
        return PlainCourseSortOption.name;
      case 'dateCreated':
        return PlainCourseSortOption.dateCreated;
      case 'dateModified':
        return PlainCourseSortOption.dateModified;
      default:
        return PlainCourseSortOption.dateModified;
    }
  }

  String get label {
    switch (this) {
      case CourseSortOption.nameAsc:
        return 'Name (Ascending)';
      case CourseSortOption.nameDesc:
        return 'Name (Descending)';
      case CourseSortOption.dateCreatedAsc:
        return 'Date Created (Ascending)';
      case CourseSortOption.dateCreatedDesc:
        return 'Date Created (Descending)';
      case CourseSortOption.dateModifiedAsc:
        return 'Date Modified (Ascending)';
      case CourseSortOption.dateModifiedDesc:
        return 'Date Modified (Descending)';
    }
  }
}
