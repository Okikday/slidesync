// import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:slidesync/features/course_mgmt/data/models/course_model/course_model.dart';
// import 'package:slidesync/features/course_mgmt/presentation/viewmodels/notifiers/modify_course/modify_course_model_notifier.dart';
// import 'package:slidesync/shared/styles/app_ui_context.dart';

// class AddCourseDescriptionDialog extends ConsumerStatefulWidget {
  
//   final String title;
//   final NotifierProvider<ModifyCourseNotifier, Course> courseProvider;

//   const AddCourseDescriptionDialog({super.key,  required this.title, required this.courseProvider});

//   @override
//   ConsumerState<AddCourseDescriptionDialog> createState() => _AddCourseDescriptionDialogState();
// }

// class _AddCourseDescriptionDialogState extends ConsumerState<AddCourseDescriptionDialog> {
//   late final TextEditingController textEditingController;

//   @override
//   initState() {
//     super.initState();
//     textEditingController = TextEditingController();
//   }

//   @override
//   Widget build(BuildContext context) {
    

//     return Align(
//       alignment: Alignment.center,
//       child: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
//               // height: context.deviceWidth > context.deviceHeight ? context.deviceHeight * 0.75 : context.deviceWidth * 0.75,
//               width:
//                   context.deviceWidth > context.deviceHeight
//                       ? context.deviceHeight * 0.85
//                       : context.deviceWidth * 0.9,
//               padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: CustomText(widget.title, fontWeight: FontWeight.bold, fontSize: 15, textAlign: TextAlign.center),
//                   ),
//                   ConstantSizing.columnSpacingMedium,
//                   Divider(color: context.isDarkMode ? Colors.lightBlue.withAlpha(40) : Colors.grey.withAlpha(40)),
//                   ConstantSizing.columnSpacingMedium,
//                   CustomTextfield(
//                     backgroundColor: Colors.grey.withAlpha(40),
//                     cursorColor: CustomText("").effectiveStyle(context).color ?? Colors.white,
//                     selectionHandleColor: ref.theme.primaryColor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide(
//                         color: context.isDarkMode ? context.theme.secondary.withAlpha(80) : ref.theme.primaryColor.withAlpha(20),
//                       ),
//                     ),
//                     pixelWidth: context.deviceWidth,
//                     constraints: BoxConstraints(minHeight: 60, maxHeight: 200),
//                     maxLines: 8,
//                     inputContentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     hint: "Enter description",
//                     controller: textEditingController,
//                     inputTextStyle: CustomText("", fontSize: 16).effectiveStyle(context),
//                   ),
//                   ConstantSizing.columnSpacingLarge,
//                   CustomElevatedButton(
//                     label: "Add description",
//                     textColor: Colors.white,
//                     textSize: 14,
//                     pixelHeight: 48,
//                     backgroundColor: ref.theme.primaryColor,
//                     onClick: () {
//                       final String text = textEditingController.text;
//                       if (text.isEmpty || text.length < 4 || text.length > 1024) return;
//                       final Course currentCourse = ref.watch(widget.courseProvider);
//                       ref.read(widget.courseProvider.notifier).update(currentCourse.copyWith(description: text));
//                       CustomDialog.hide(context);
//                     },
//                   ),
//                 ],
//               ),
//             ).animate().moveY(begin: -48, end: 0, curve: CustomCurves.defaultIosSpring, duration: Durations.extralong3).fadeIn(),

//             Positioned(
//               top: 0,
//               right: 0,
//               child: CustomElevatedButton(
//                 shape: CircleBorder(),
//                 onClick: () {
//                   CustomDialog.hide(context);
//                 },
//                 backgroundColor: Colors.transparent,
//                 child: Icon(Iconsax.close_circle, size: 30),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
