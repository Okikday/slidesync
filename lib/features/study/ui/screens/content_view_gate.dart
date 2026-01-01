// import 'dart:developer';

// import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/data/models/course_content/course_content.dart';
// import 'package:slidesync/data/models/file_details.dart';
// import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';
// import 'package:slidesync/shared/helpers/formatter.dart';
// import 'package:slidesync/shared/helpers/widget_helper.dart';

// import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

// class ContentViewGate extends ConsumerStatefulWidget {
//   final CourseContent content;
//   const ContentViewGate({super.key, required this.content});

//   @override
//   ConsumerState<ContentViewGate> createState() => _ContentViewGateState();
// }

// class _ContentViewGateState extends ConsumerState<ContentViewGate> {
//   // bool isPushed = false;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       // if (isPushed) return;
//       log("Redirecting to viewer");
//       await ContentViewGateActions.redirectToViewer(ref, widget.content);
//       // setState(() {
//       //   isPushed = true;
//       // });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final content = widget.content;
//     final theme = ref;
//     return Material(
//       type: MaterialType.transparency,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned.fill(
//             child: ColoredBox(
//               color: Colors.black.withAlpha(140),
//               child: GestureDetector(
//                 // child: OrganicBackgroundEffect(),
//                 onTap: () {
//                   // context.pop();
//                 },
//               ),
//             ),
//             // child: BackdropFilter(

//             //   filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
//             //   child:
//             // ),
//           ),

//           // Positioned(
//           //   bottom: 0,
//           //   child: SizedBox(
//           //     width: context.deviceWidth,
//           //     height: context.deviceHeight / 2,
//           //     child: Opacity(opacity: 0.2, child: CustomWaveWidget(progress: 0.9, backgroundColor: Colors.transparent)),
//           //   ),
//           // ),
//           Positioned(
//             bottom: context.bottomPadding + 40,
//             child: CustomText(
//               "Preparing material...Just a moment",
//               color: theme.primaryColor,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ).animate().slideY(begin: 1, end: 0, duration: Duration(seconds: 1)),
//           ),

//           Positioned(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
//                   clipBehavior: Clip.antiAlias,
//                   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                   decoration: BoxDecoration(
//                     color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.fromBorderSide(BorderSide(color: theme.altBackgroundSecondary.withAlpha(100))),
//                   ),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: SizedBox.expand(
//                           child: BuildImagePathWidget(
//                             fileDetails: FileDetails(filePath: content.previewPath),
//                             fit: BoxFit.cover,
//                             fallbackWidget: Icon(
//                               WidgetHelper.resolveIconData(content.courseContentType, false),
//                               size: 36,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           LinearProgressIndicator(
//                             value: 0.4,
//                             color: theme.primaryColor.withAlpha(60),
//                             backgroundColor: theme.background
//                                 .lightenColor(theme.isDarkMode ? 0.15 : 0.85)
//                                 .withAlpha(200),
//                           ),

//                           Container(
//                             width: double.infinity,
//                             color: theme.background.lightenColor(theme.isDarkMode ? 0.15 : 0.85).withAlpha(200),
//                             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Flexible(
//                                   child: CustomText(
//                                     content.title,
//                                     color: theme.onBackground,
//                                     fontWeight: FontWeight.w600,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 CustomText(
//                                   Formatter.formatEnumName(content.courseContentType.name),
//                                   fontSize: 11,
//                                   color: theme.supportingText,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ).animate().scaleXY(begin: 1.05, end: 1, curve: Curves.fastOutSlowIn),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
