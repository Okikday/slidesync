import 'package:another_flushbar/flushbar.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/sub/course_collection.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/actions/edit_collection_actions.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/actions/modify_collection_actions.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class EditCollectionTitleBottomSheet extends ConsumerStatefulWidget {
  final CourseCollection collection;
  const EditCollectionTitleBottomSheet({super.key, required this.collection});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditCollectionTitleBottomSheetState();
}

class _EditCollectionTitleBottomSheetState extends ConsumerState<EditCollectionTitleBottomSheet> {
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
    final collection = widget.collection;
    final theme = ref;

    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTap: () => context.pop())),
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
                  child: CustomText(
                    "Rename Collection",
                    fontSize: 13,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ConstantSizing.columnSpacingSmall,
                CustomTextfield(
                  autoDispose: false,
                  hint: "Edit Collection name",
                  defaultText: collection.collectionTitle,
                  focusNode: focusNode,
                  selectionHandleColor: theme.primaryColor,
                  // onTapOutside: () {},
                  onSubmitted: (text) async {
                    final collectionTitle = collection.collectionTitle;
                    final isValid = await EditCollectionActions().validateCollectionTitle(
                      context,
                      text: text,
                      collectionTitle: collectionTitle,
                    );
                    if (isValid != null) return;
                    // Create new collection
                    final outcome = await modifyCollectionActions.renameCollectionAction(
                      collection.copyWith(collectionTitle: text),
                    );
                    // Handle outcome
                    if (outcome == null) {
                      if (context.mounted) {
                        context.pop();
                      } else {
                        rootNavigatorKey.currentContext?.pop();
                      }
                      if (context.mounted) {
                        await UiUtils.showFlushBar(
                          context,
                          msg: "Renamed ${collectionTitle} to $text!",
                          vibe: FlushbarVibe.success,
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
