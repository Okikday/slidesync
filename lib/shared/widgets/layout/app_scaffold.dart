import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';

class AppScaffold extends ConsumerWidget {
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? appBar;
  // final EdgeInsets Function(EdgeInsets apply)? appBarPadding;

  final String title;
  final String? subtitle;

  final Widget? titleWidget;
  final Widget? trailingWidget;
  final Widget? leadingWidget;

  /// Won't work if [appBar] is provided
  final bool applyDefaultAppBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final bool canPop;
  final void Function(bool, dynamic)? onPopInvokedWithResult;
  final EdgeInsets? viewPadding;
  final void Function()? onBackButtonPressed;
  final Widget? drawer;
  final Widget body;

  const AppScaffold({
    super.key,
    this.extendBodyBehindAppBar = false,
    // this.appBarPadding,
    this.extendBody = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.appBar,
    this.applyDefaultAppBar = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.systemUiOverlayStyle,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.viewPadding,
    required this.title,
    this.subtitle,
    this.titleWidget,
    this.trailingWidget,
    this.leadingWidget,
    required this.body,
    this.onBackButtonPressed,
    this.appBarBackgroundColor,
    this.drawer,
  });

  Widget _defaultAppBar(WidgetRef ref) => AppBarContainer(
    child: AppBarContainerChild(
      ref.isDarkMode,
      title: title,
      subtitle: subtitle,
      onBackButtonClicked: onBackButtonPressed,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: AnnotatedRegion(
        // value: systemUiOverlayStyle ?? UiUtils.systemUiOverlayStyle(theme),
        value:
            systemUiOverlayStyle ??
            UiUtils.getSystemUiOverlayStyle(
              ref.scaffoldBackgroundColor,
              ref.isDarkMode,
              statusBarColor: Colors.transparent,
            ),
        child: Scaffold(
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          extendBody: extendBody,
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          body: applyDefaultAppBar || appBar != null
              ? (extendBodyBehindAppBar
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(padding: viewPadding ?? EdgeInsets.zero, child: body),
                          appBar ?? _defaultAppBar(ref),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          appBar ?? _defaultAppBar(ref),
                          Flexible(
                            child: Padding(padding: viewPadding ?? EdgeInsets.zero, child: body),
                          ),
                        ],
                      ))
              : body,
        ),
      ),
    );
  }
}
