// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/core/utils/ui_utils.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';
// import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

// class AppScaffold extends ConsumerWidget {
//   final bool extendBodyBehindAppBar;
//   final bool extendBody;
//   final Color? backgroundColor;
//   final Color? appBarBackgroundColor;
//   final bool? resizeToAvoidBottomInset;
//   final Widget? appBar;
//   final EdgeInsets Function(EdgeInsets apply)? appBarPadding;

//   final String title;
//   final String? subtitle;

//   final Widget? titleWidget;
//   final Widget? trailingWidget;
//   final Widget? leadingWidget;

//   /// Won't work if [appBar] is provided
//   final bool applyDefaultAppBar;
//   final Widget? floatingActionButton;
//   final Widget? bottomNavigationBar;
//   final SystemUiOverlayStyle? systemUiOverlayStyle;
//   final bool canPop;
//   final void Function(bool, dynamic)? onPopInvokedWithResult;
//   final EdgeInsets? viewPadding;
//   final void Function()? onBackButtonPressed;
//   final Widget body;

//   const AppScaffold({
//     super.key,
//     this.extendBodyBehindAppBar = false,
//     this.appBarPadding,
//     this.extendBody = false,
//     this.backgroundColor,
//     this.resizeToAvoidBottomInset,
//     this.appBar,
//     this.applyDefaultAppBar = true,
//     this.floatingActionButton,
//     this.bottomNavigationBar,
//     this.systemUiOverlayStyle,
//     this.canPop = true,
//     this.onPopInvokedWithResult,
//     this.viewPadding,
//     required this.title,
//     this.subtitle,
//     this.titleWidget,
//     this.trailingWidget,
//     this.leadingWidget,
//     required this.body,
//     this.onBackButtonPressed,
//     this.appBarBackgroundColor,
//   });

//   Widget get _defaultAppBar => AppBarContainer(
//     child: AppBarContainerChild(title: title, subtitle: subtitle, onBackButtonClicked: onBackButtonPressed),
//   );

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final defaultPadding = context.padding.copyWith(left: 20, right: 20);
//     return PopScope(
//       canPop: canPop,
//       onPopInvokedWithResult: onPopInvokedWithResult,
//       child: AnnotatedRegion(
//         // value: systemUiOverlayStyle ?? UiUtils.systemUiOverlayStyle(theme),
//         value:
//             systemUiOverlayStyle ??
//             UiUtils.getSystemUiOverlayStyle(
//               ref.scaffoldBackgroundColor,
//               ref.isDarkMode,
//               statusBarColor: Colors.transparent,
//             ),
//         child: Scaffold(
//           extendBodyBehindAppBar: extendBodyBehindAppBar,
//           extendBody: extendBody,
//           backgroundColor: backgroundColor,
//           resizeToAvoidBottomInset: resizeToAvoidBottomInset,
//           floatingActionButton: floatingActionButton,
//           bottomNavigationBar: bottomNavigationBar,
//           body: applyDefaultAppBar || appBar != null
//               ? (extendBodyBehindAppBar
//                     ? Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Padding(padding: viewPadding ?? defaultPadding.copyWith(bottom: 24), child: body),
//                           Positioned(
//                             top: 24,
//                             left: 0,
//                             right: 0,
//                             child: Padding(
//                               padding: appBarPadding != null
//                                   ? appBarPadding!(defaultPadding.copyWith(top: 24))
//                                   : defaultPadding.copyWith(top: 24),
//                               child: appBar ?? _defaultAppBar,
//                             ),
//                           ),
//                         ],
//                       )
//                     : Column(
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Padding(
//                             padding: appBarPadding != null
//                                 ? appBarPadding!(defaultPadding.copyWith(top: defaultPadding.top + 24, bottom: 24))
//                                 : defaultPadding.copyWith(top: defaultPadding.top + 24, bottom: 24),
//                             child: appBar ?? _defaultAppBar,
//                           ),
//                           Flexible(
//                             child: Padding(padding: viewPadding ?? defaultPadding.copyWith(top: 0), child: body),
//                           ),
//                         ],
//                       ))
//               : body,
//         ),
//       ),
//     );
//   }
// }
