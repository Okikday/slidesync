import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/global_notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class InputCourseCodeField extends ConsumerWidget {
  final NotifierProvider<BoolNotifier, bool> isCourseCodeFieldVisible;
  final TextEditingController courseCodeController;
  const InputCourseCodeField({super.key, required this.courseCodeController, required this.isCourseCodeFieldVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return AnimatedSize(
      duration: Durations.extralong4,
      curve: CustomCurves.bouncySpring,
      child: SizedBox(
        height: ref.watch(isCourseCodeFieldVisible) ? 76 : 0,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CustomTextfield(
                controller: courseCodeController,
                backgroundColor: theme.surface.withValues(alpha: 0.8),
                cursorColor: theme.primaryColor,
                selectionHandleColor: theme.primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: theme.altBackgroundPrimary.withAlpha(150)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                autoDispose: false,
                onTapOutside: () {},
                constraints: BoxConstraints(maxWidth: 200),
                pixelHeight: 60,
                inputContentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                hint: "Optional course code",
                inputTextStyle: TextStyle(fontSize: 16, color: theme.onBackground),
              ),
            ),

            Positioned(
              left: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Container(
                    width: (context.deviceWidth - 48 - 200).clamp(80, context.deviceWidth),
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
