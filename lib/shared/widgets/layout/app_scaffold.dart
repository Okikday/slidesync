import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

class AppScaffold extends ConsumerWidget {
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? appBar;
  final EdgeInsets Function(EdgeInsets apply)? appBarPadding;

  final String title;
  final String? subtitle;

  final Widget? titleWidget;
  final Widget? trailingWidget;
  final Widget? leadingWidget;

  final bool applyDefaultAppBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final bool canPop;
  final void Function(bool, dynamic)? onPopInvokedWithResult;
  final EdgeInsets? viewPadding;
  final void Function()? onBackButtonPressed;
  final Widget? drawer;
  final Widget? footer;
  final EdgeInsets? footerPadding;
  final Widget body;

  const AppScaffold({
    super.key,
    this.extendBodyBehindAppBar = false,
    this.appBarPadding,
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
    this.footer,
    this.footerPadding,
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
    final systemUiOverlayStyle = this.systemUiOverlayStyle == const SystemUiOverlayStyle()
        ? null
        : (this.systemUiOverlayStyle ??
              UiUtils.getSystemUiOverlayStyle(
                ref.scaffoldBackgroundColor,
                ref.isDarkMode,
                statusBarColor: Colors.transparent,
              ));
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: systemUiOverlayStyle == null
          ? _AppScaffoldBody(
              extendBodyBehindAppBar: extendBodyBehindAppBar,
              extendBody: extendBody,
              backgroundColor: backgroundColor,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              floatingActionButton: floatingActionButton,
              bottomNavigationBar: bottomNavigationBar,
              drawer: drawer,
              body: body,
              footer: footer,
              viewPadding: viewPadding,
              appBar: appBar,
              applyDefaultAppBar: applyDefaultAppBar,
              appBarPadding: appBarPadding,
              footerPadding: footerPadding,
              defaultAppBar: _defaultAppBar(ref),
            )
          : AnnotatedRegion(
              value: systemUiOverlayStyle,
              child: _AppScaffoldBody(
                extendBodyBehindAppBar: extendBodyBehindAppBar,
                extendBody: extendBody,
                backgroundColor: backgroundColor,
                resizeToAvoidBottomInset: resizeToAvoidBottomInset,
                floatingActionButton: floatingActionButton,
                bottomNavigationBar: bottomNavigationBar,
                drawer: drawer,
                body: body,
                footer: footer,
                viewPadding: viewPadding,
                appBar: appBar,
                applyDefaultAppBar: applyDefaultAppBar,
                appBarPadding: appBarPadding,
                footerPadding: footerPadding,
                defaultAppBar: _defaultAppBar(ref),
              ),
            ),
    );
  }
}

class _AppScaffoldBody extends StatelessWidget {
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget body;
  final Widget? footer;
  final EdgeInsets? viewPadding;
  final Widget? appBar;
  final bool applyDefaultAppBar;
  final EdgeInsets Function(EdgeInsets)? appBarPadding;
  final EdgeInsets? footerPadding;
  final Widget defaultAppBar;

  const _AppScaffoldBody({
    required this.extendBodyBehindAppBar,
    required this.extendBody,
    required this.backgroundColor,
    required this.resizeToAvoidBottomInset,
    required this.floatingActionButton,
    required this.bottomNavigationBar,
    required this.drawer,
    required this.body,
    required this.footer,
    required this.viewPadding,
    required this.appBar,
    required this.applyDefaultAppBar,
    required this.appBarPadding,
    required this.footerPadding,
    required this.defaultAppBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: (extendBodyBehindAppBar
          ? _ExtendBodyBehindAppBar(
              footer: footer,
              extendBody: extendBody,
              viewPadding: viewPadding,
              body: body,
              applyDefaultAppBar: applyDefaultAppBar,
              appBar: appBar,
              appBarPadding: appBarPadding,
              defaultAppBar: defaultAppBar,
              footerPadding: footerPadding,
            )
          : extendBody
          ? Stack(
              children: [
                _NotExtendBodyBehindAppBar(
                  body: body,
                  viewPadding: viewPadding,
                  applyDefaultAppBar: applyDefaultAppBar,
                  appBar: appBar,
                  appBarPadding: appBarPadding,
                  defaultAppBar: defaultAppBar,
                  footer: footer,
                  extendBody: extendBody,
                ),
                if (footer != null) Positioned(bottom: 0, left: 0, right: 0, child: footer!),
              ],
            )
          : _NotExtendBodyBehindAppBar(
              body: body,
              viewPadding: viewPadding,
              applyDefaultAppBar: applyDefaultAppBar,
              appBar: appBar,
              appBarPadding: appBarPadding,
              defaultAppBar: defaultAppBar,
              footer: footer,
              extendBody: extendBody,
            )),
    );
  }
}

class _ExtendBodyBehindAppBar extends StatelessWidget {
  final Widget? footer;
  final bool extendBody;
  final EdgeInsets? viewPadding;
  final Widget body;
  final bool applyDefaultAppBar;
  final Widget? appBar;
  final EdgeInsets Function(EdgeInsets)? appBarPadding;
  final Widget defaultAppBar;
  final EdgeInsets? footerPadding;

  const _ExtendBodyBehindAppBar({
    required this.footer,
    required this.extendBody,
    required this.viewPadding,
    required this.body,
    required this.applyDefaultAppBar,
    required this.appBar,
    required this.appBarPadding,
    required this.defaultAppBar,
    required this.footerPadding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.zero;

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: viewPadding ?? EdgeInsets.zero,
          child: footer != null
              ? Column(
                  children: [
                    Expanded(child: body),
                    if (!extendBody) footer!,
                  ],
                )
              : body,
        ),
        if (applyDefaultAppBar || appBar != null)
          Positioned(
            left: 0,
            right: 0,
            child: Padding(
              padding: appBarPadding != null ? appBarPadding!(defaultPadding) : defaultPadding,
              child: appBar ?? defaultAppBar,
            ),
          ),
        if (extendBody && footer != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(padding: footerPadding ?? defaultPadding, child: footer!),
          ),
      ],
    );
  }
}

class _NotExtendBodyBehindAppBar extends StatelessWidget {
  final Widget body;
  final EdgeInsets? viewPadding;
  final bool applyDefaultAppBar;
  final Widget? appBar;
  final EdgeInsets Function(EdgeInsets)? appBarPadding;
  final Widget defaultAppBar;
  final Widget? footer;
  final bool extendBody;

  const _NotExtendBodyBehindAppBar({
    required this.body,
    required this.viewPadding,
    required this.applyDefaultAppBar,
    required this.appBar,
    required this.appBarPadding,
    required this.defaultAppBar,
    required this.footer,
    required this.extendBody,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.zero;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (applyDefaultAppBar || appBar != null)
          Padding(
            padding: appBarPadding != null ? appBarPadding!(defaultPadding) : defaultPadding,
            child: appBar ?? defaultAppBar,
          ),
        Flexible(
          child: Padding(padding: viewPadding ?? defaultPadding, child: body),
        ),
        if (!extendBody && footer != null) footer!,
      ],
    );
  }
}
