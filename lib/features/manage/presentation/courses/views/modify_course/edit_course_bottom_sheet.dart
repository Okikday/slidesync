import 'package:flutter/material.dart';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/manage/presentation/courses/actions/edit_course_actions.dart';
import 'package:slidesync/features/manage/presentation/courses/views/create_course/input_course_code_field.dart';
import 'package:slidesync/features/manage/presentation/courses/views/create_course/input_course_title_field.dart';
import 'package:slidesync/features/manage/presentation/courses/views/modify_course/edit_course_bottom_sheet/edit_course_input_description_field.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class EditCourseBottomSheet extends ConsumerStatefulWidget {
  final bool isEditingDescription;
  final String courseId;
  const EditCourseBottomSheet({super.key, required this.courseId, this.isEditingDescription = false});

  @override
  ConsumerState createState() => _EditCourseBottomSheetState();
}

class _EditCourseBottomSheetState extends ConsumerState<EditCourseBottomSheet> {
  late final TextEditingController courseNameTextController;
  late final TextEditingController courseCodeController;
  late final TextEditingController descriptionTextController;
  late final NotifierProvider<BoolNotifier, bool> canExitProvider;
  late final FocusNode descriptionFocusNode;
  late final NotifierProvider<BoolNotifier, bool> isCourseCodeFieldVisible;

  @override
  void initState() {
    super.initState();
    canExitProvider = NotifierProvider<BoolNotifier, bool>(BoolNotifier.new, isAutoDispose: true);
    courseNameTextController = TextEditingController();
    descriptionTextController = TextEditingController();
    courseCodeController = TextEditingController();
    isCourseCodeFieldVisible = NotifierProvider<BoolNotifier, bool>(BoolNotifier.new, isAutoDispose: true);
    if (widget.isEditingDescription) {
      descriptionFocusNode = FocusNode();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => initPostFrame());
  }

  void initPostFrame() {
    final readCourse = ref.watch(CourseProviders.courseProvider(widget.courseId)).value ?? defaultCourse;
    courseNameTextController.text = readCourse.courseName;
    if (readCourse.courseCode.isNotEmpty) courseCodeController.text = readCourse.courseCode;

    if (readCourse.description.isNotEmpty) {
      descriptionTextController.text = readCourse.description;
      descriptionTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: descriptionTextController.text.length,
      );
    }
    if (widget.isEditingDescription) descriptionFocusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Course course = ref.watch(CourseProviders.courseProvider(widget.courseId)).value ?? defaultCourse;

    final double keyboardInsets = double.parse(
      (context.viewInsets.bottom / context.deviceHeight).toStringAsFixed(2),
    ).clamp(0.0, 0.25);

    return PopScope(
      canPop: ref.watch(canExitProvider),
      onPopInvokedWithResult: (_, _) => EditCourseActions.of(ref).onPopInvokedWithResult(context, canExitProvider),

      child: AnimatedSize(
        duration: Durations.extralong1,
        curve: CustomCurves.defaultIosSpring,
        child: DraggableScrollableSheet(
          maxChildSize: 1.0,
          initialChildSize: 0.65 + keyboardInsets,
          expand: false,
          snapSizes: [],
          builder: (context, scrollController) {
            return ClipRSuperellipse(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: ColoredBox(
                color: context.scaffoldBackgroundColor,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                      child: CustomScrollView(
                        slivers: [
                          PinnedHeaderSliver(
                            child: ColoredBox(
                              color: context.scaffoldBackgroundColor,
                              child: CustomText(
                                "Edit course",
                                fontSize: 18,
                                color: ref.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

                          SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6.0,
                              children: [
                                CustomText("Title", fontSize: 13, color: ref.onBackground),
                                InputCourseTitleField(
                                  courseNameController: courseNameTextController,
                                  isCourseCodeFieldVisible: isCourseCodeFieldVisible,
                                ),

                                InputCourseCodeField(
                                  courseCodeController: courseCodeController,
                                  isCourseCodeFieldVisible: isCourseCodeFieldVisible,
                                ),
                              ],
                            ),
                          ),

                          SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),

                          EditCourseInputDescriptionField(
                            descriptionTextController: descriptionTextController,
                            course: course,
                            descriptionFocusNode: widget.isEditingDescription ? descriptionFocusNode : null,
                          ),

                          SliverToBoxAdapter(child: AnimatedSpacing()),
                        ],
                      ),
                    ),

                    PositionedUpdateDetailsButton(
                      courseId: widget.courseId,
                      courseNameTextController: courseNameTextController,
                      courseCodeController: courseCodeController,
                      descriptionTextController: descriptionTextController,
                      isCourseCodeFieldVisible: isCourseCodeFieldVisible,
                      canExitProvider: canExitProvider,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedSpacing extends StatelessWidget {
  const AnimatedSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return AnimatedSize(
      duration: Durations.medium1,
      curve: CustomCurves.decelerate,
      child: ConstantSizing.columnSpacing(context.viewInsets.bottom + bottomPadding + 48),
    );
  }
}

class PositionedUpdateDetailsButton extends ConsumerWidget {
  const PositionedUpdateDetailsButton({
    super.key,
    required this.courseId,
    required this.courseNameTextController,
    required this.courseCodeController,
    required this.descriptionTextController,
    required this.isCourseCodeFieldVisible,
    required this.canExitProvider,
  });
  final String courseId;
  final TextEditingController courseNameTextController;
  final TextEditingController courseCodeController;
  final TextEditingController descriptionTextController;
  final NotifierProvider<BoolNotifier, bool> isCourseCodeFieldVisible;
  final NotifierProvider<BoolNotifier, bool> canExitProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final theme = ref;

    return AnimatedPositioned(
      duration: Durations.extralong1,
      curve: CustomCurves.defaultIosSpring,
      bottom: bottomPadding + context.viewInsets.bottom + 4.0,
      left: context.viewInsets.bottom > 20 ? null : 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomElevatedButton(
          onClick: () async {
            EditCourseActions.of(ref).onUpdateDetails(
              courseName: courseNameTextController.text,
              courseCode: courseCodeController.text,
              description: descriptionTextController.text,
              isCourseCodeFieldVisible: ref.read(isCourseCodeFieldVisible),
              canExitProvider: canExitProvider,
              modifyCourseProvider: CourseProviders.courseProvider(courseId),
            );
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          label: "Update details",
          textColor: theme.onPrimary,
          textSize: 15,
          pixelHeight: 48,
          backgroundColor: theme.primaryColor,
          borderRadius: 48,
        ),
      ),
    );
  }
}
