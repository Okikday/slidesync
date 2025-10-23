import 'package:another_flushbar/flushbar.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

export 'package:another_flushbar/flushbar.dart';

enum FlushbarVibe { none, error, success, warning }

class UiUtils {
  /// For getting repititive SystemOverlayStyle
  static SystemUiOverlayStyle getSystemUiOverlayStyle(
    Color scaffoldBackgroundColor,
    bool isDarkMode, {
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Color? systemNavigatorBarColor,
    Brightness? systemNavigatorBarIconBrightness,
  }) {
    return SystemUiOverlayStyle(
      systemNavigationBarColor: systemNavigatorBarColor ?? scaffoldBackgroundColor,
      statusBarColor: statusBarColor ?? scaffoldBackgroundColor,
      statusBarIconBrightness: statusBarIconBrightness ?? (isDarkMode ? Brightness.light : Brightness.dark),
      systemNavigationBarIconBrightness:
          systemNavigatorBarIconBrightness ?? (isDarkMode ? Brightness.light : Brightness.dark),
    );
  }

  /// For showing Custom Loading Dialog in tuned format
  static void showLoadingDialog(
    BuildContext context, {
    String message = "Just a moment...",
    bool canPop = true,
    Color? backgroundColor,
    Color? barrierColor,
    Offset? blurSigma,
  }) async {
    final normalColor = context.theme.colorScheme.onSurface;
    final bgColor = context.scaffoldBackgroundColor.withValues(alpha: 0.9);
    await CustomDialog.showLoadingDialog(
      context,
      canPop: canPop,
      msg: message,
      msgTextColor: normalColor,
      progressIndicatorColor: context.theme.colorScheme.primary,
      backgroundColor: backgroundColor ?? bgColor,
      barrierColor: barrierColor ?? Colors.black.withAlpha(140),
      transitionDuration: Durations.medium2,
      blurSigma: blurSigma,
    );
  }

  static void hideDialog(BuildContext context) => CustomDialog.hide(context);

  /// For showing CustomDialog in tuned format
  static Future<void> showCustomDialog(
    BuildContext context, {
    required Widget child,
    bool canPop = true,
    Duration transitionDuration = Durations.medium2,
    Duration reverseTransitionDuration = Durations.short2,
    TransitionType transitionType = TransitionType.cupertinoDialog,
    Curve? curve,
    Color? barrierColor,
    Offset? blurSigma,
  }) async {
    await CustomDialog.show(
      context,
      canPop: canPop,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionType: transitionType,
      curve: curve ?? CustomCurves.defaultIosSpring,
      barrierColor: barrierColor ?? Colors.black.withAlpha(140),
      blurSigma: blurSigma,
      child: child,
    );
  }

  /// For showing flushbar in tuned format
  static Future<dynamic> showFlushBar(
    BuildContext context, {
    required String msg,
    Color? messageColor,
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 1500),
    FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM,
    FlushbarVibe vibe = FlushbarVibe.none,
    EdgeInsets? margin,
    double barBlur = 4.0,
  }) async {
    final List<Color> colors = _resolveFlushbarVibe(context, vibe);

    await Flushbar(
      message: msg,
      icon: Icon(_resolveIconData(vibe), color: colors[0]),
      messageColor: messageColor ?? colors[0],
      duration: duration,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      flushbarPosition: flushbarPosition,
      backgroundColor: backgroundColor ?? colors[1],
      borderRadius: BorderRadius.circular(ConstantSizing.borderRadiusCircle),
      borderColor: colors[0].withValues(alpha: 0.2),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin:
          margin ??
          (flushbarPosition == FlushbarPosition.TOP
              ? EdgeInsets.only(left: 24, right: 24, bottom: context.bottomPadding + 12)
              : EdgeInsets.only(left: 24, right: 24, top: context.topPadding + 8.0)),
      barBlur: barBlur,
    ).show(context);
  }

  ///
}

IconData _resolveIconData(FlushbarVibe vibe) {
  switch (vibe) {
    case FlushbarVibe.none:
      return Iconsax.info_circle;
    case FlushbarVibe.success:
      return Iconsax.tick_circle;
    case FlushbarVibe.error:
      return Icons.error_rounded;
    case FlushbarVibe.warning:
      return Iconsax.info_circle;
  }
}

List<Color> _resolveFlushbarVibe(BuildContext context, FlushbarVibe vibe) {
  // Premium colors with good contrast and subtle backgrounds
  const errorColor = Color(0xFFB00020); // Deep red
  final errorBgColor = errorColor.withValues(alpha: 0.15);

  const successColor = Color(0xFF2E7D32); // Rich green
  final successBgColor = successColor.withValues(alpha: 0.15);

  const warningColor = Color(0xFFF9A825); // Warm gold
  final warningBgColor = warningColor.withValues(alpha: 0.15);

  // final normalColor = context.isDarkMode ? Colors.white : Colors.black87;
  // final normalBgColor =
  //     context.isDarkMode
  //         ? const Color(0xFF1E1E2C).withValues(alpha: 0.85) // Darker, muted blue-gray
  //         : const Color(0xFFF5F5F7).withValues(alpha: 0.85); // Soft off-white

  final normalColor = context.theme.colorScheme.onSurface;
  final normalBgColor = context.theme.colorScheme.surface;

  switch (vibe) {
    case FlushbarVibe.none:
      return [normalColor, normalBgColor];
    case FlushbarVibe.error:
      return [errorColor, errorBgColor];
    case FlushbarVibe.success:
      return [successColor, successBgColor];
    case FlushbarVibe.warning:
      return [warningColor, warningBgColor];
  }
}
