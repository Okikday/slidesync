import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class InputCourseTitleField extends ConsumerWidget {
  const InputCourseTitleField({
    super.key,
    required this.courseNameController,
    required this.isCourseCodeFieldVisible,
    this.viewScrollController,
  });
  final NotifierProvider<BoolNotifier, bool> isCourseCodeFieldVisible;
  final TextEditingController courseNameController;
  final ScrollController? viewScrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return CustomTextfield(
      controller: courseNameController,
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
      pixelWidth: context.deviceWidth,
      pixelHeight: 60,
      inputContentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      hint: "Enter course title",
      inputTextStyle: TextStyle(fontSize: 16, color: theme.onBackground),
      onTapOutside: () {},
      autoDispose: false,
      suffixIcon: CustomElevatedButton(
        pixelWidth: 50,
        pixelHeight: 50,
        borderRadius: 12,
        overlayColor: theme.primaryColor.withAlpha(40),
        onClick: () async {
          final bool isCourseCodeVisible = ref.read(isCourseCodeFieldVisible);
          if (isCourseCodeVisible) FocusScope.of(context).unfocus();
          ref.read(isCourseCodeFieldVisible.notifier).update((cb) => !isCourseCodeVisible);
          if (FocusScope.of(context).hasFocus && viewScrollController != null) {
            viewScrollController?.animateTo(
              viewScrollController!.position.maxScrollExtent + 150,
              duration: Durations.extralong1,
              curve: CustomCurves.decelerate,
            );
          }
        },
        backgroundColor: Colors.transparent,
        child: Tooltip(
          message: "Add Optional Course code",
          triggerMode: TooltipTriggerMode.longPress,
          child: Icon(
            ref.watch(isCourseCodeFieldVisible) ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            size: 30,
            color: theme.supportingText,
          ),
        ),
      ),
      alwaysShowSuffixIcon: true,
    );
  }
}
