import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/presentation/controlllers/src/course_details_controller/course_details_controller.dart';
import 'package:slidesync/features/manage/presentation/collections/actions/modify_collection_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class CreateCollectionBottomSheet extends ConsumerStatefulWidget {
  final String courseId;
  final String title;
  const CreateCollectionBottomSheet({super.key, required this.courseId, this.title = "New Collection"});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateCollectionBottomSheetState();
}

class _CreateCollectionBottomSheetState extends ConsumerState<CreateCollectionBottomSheet> {
  late final FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => focusNode.requestFocus());
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModifyCollectionActions modifyCollectionActions = ModifyCollectionActions();
    final theme = ref;

    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTap: () => CustomDialog.hide(context))),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: context.bottomPadding + context.viewInsets.bottom),
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 4.0),
            color: context.scaffoldBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: CustomText(widget.title, fontSize: 13, color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
                ConstantSizing.columnSpacingSmall,
                CustomTextfield(
                  autoDispose: false,
                  hint: "Enter a Collection name",
                  focusNode: focusNode,
                  selectionHandleColor: theme.primaryColor,
                  onTapOutside: () {},
                  onSubmitted: (text) async {
                    // Create new collection
                    final outcome = await modifyCollectionActions.onCreateNewCollection(
                      context,
                      text: text.trim(),
                      courseId: widget.courseId,
                    );

                    // Handle outcome
                    if (outcome == null) {
                      if (context.mounted) CustomDialog.hide(context);
                      if (context.mounted) {
                        await UiUtils.showFlushBar(
                          context,
                          msg: "Added $text to Collections!",
                          vibe: FlushbarVibe.success,
                        );
                      }
                    } else if (outcome.isEmpty) {
                      final String message;
                      if (text.isEmpty) {
                        message = "Try typing into the Field!";
                      } else if (text.length < 2) {
                        message = "Text input is too short!";
                      } else {
                        message = "Invalid input!";
                      }
                      if (context.mounted) {
                        await UiUtils.showFlushBar(
                          context,
                          msg: message,
                          flushbarPosition: FlushbarPosition.TOP,
                          vibe: FlushbarVibe.warning,
                        );
                      }
                    } else {
                      if (context.mounted) {
                        await UiUtils.showFlushBar(
                          context,
                          msg: outcome,
                          flushbarPosition: FlushbarPosition.TOP,
                          vibe: FlushbarVibe.warning,
                        );
                      }
                    }
                  },
                  inputContentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  inputTextStyle: TextStyle(fontSize: 15, color: theme.onBackground),
                  cursorColor: theme.primaryColor,
                  backgroundColor: Colors.transparent,
                  border: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
                  // alwaysShowSuffixIcon: true,
                  // suffixIcon: Padding(
                  //   padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                  //   child: CustomElevatedButton(
                  //     onClick: () {},
                  //     backgroundColor: theme.primaryColor,
                  //     contentPadding: EdgeInsets.all(2.0),
                  //     shape: CircleBorder(),
                  //     child: Icon(Iconsax.add_circle, size: 20, color: context.isDarkMode ? Colors.white : Colors.white),
                  //   ),
                  // ),
                ),
                ConstantSizing.columnSpacing(4.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
