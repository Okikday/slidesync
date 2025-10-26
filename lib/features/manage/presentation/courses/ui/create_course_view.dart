import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:slidesync/features/share/import/desktop_course_folder_import_manager.dart';
import 'package:slidesync/features/share/import/saf_course_folder_import_manager.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/create_course/add_image_avatar.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/create_course/create_course_button.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/create_course/input_course_code_field.dart';
import 'package:slidesync/features/manage/presentation/courses/ui/create_course/input_course_title_field.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CreateCourseView extends ConsumerStatefulWidget {
  const CreateCourseView({super.key});

  @override
  ConsumerState createState() => _CreateCourseViewState();
}

class _CreateCourseViewState extends ConsumerState<CreateCourseView> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(Colors.transparent, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(child: AppBarContainerChild(context.isDarkMode, title: "Create Course")),

        body: CreateCourseOuterSection(),
      ),
    );
  }
}

class CreateCourseOuterSection extends ConsumerStatefulWidget {
  const CreateCourseOuterSection({super.key});

  @override
  ConsumerState<CreateCourseOuterSection> createState() => _CreateCourseOuterSectionState();
}

class _CreateCourseOuterSectionState extends ConsumerState<CreateCourseOuterSection> {
  late final NotifierProvider<BoolNotifier, bool> isCourseCodeFieldVisible;
  late final TextEditingController courseNameController;
  late final TextEditingController courseCodeController;
  late final NotifierProvider<ImpliedNotifierN<String>, String?> courseImagePathProvider;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    isCourseCodeFieldVisible = NotifierProvider<BoolNotifier, bool>(BoolNotifier.new, isAutoDispose: true);
    courseImagePathProvider = NotifierProvider(ImpliedNotifierN.new, isAutoDispose: true);
    courseNameController = TextEditingController();
    courseCodeController = TextEditingController();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    courseNameController.dispose();
    courseCodeController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.deviceHeight,
      width: context.deviceWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    ConstantSizing.columnSpacingMedium,

                    AddImageAvatar(courseImagePathProvider: courseImagePathProvider),

                    ConstantSizing.columnSpacing(56),

                    InputCourseTitleField(
                      courseNameController: courseNameController,
                      isCourseCodeFieldVisible: isCourseCodeFieldVisible,
                      viewScrollController: scrollController,
                    ),

                    ConstantSizing.columnSpacingLarge,

                    InputCourseCodeField(
                      courseCodeController: courseCodeController,
                      isCourseCodeFieldVisible: isCourseCodeFieldVisible,
                    ),

                    ValueListenableBuilder(
                      valueListenable: courseNameController,
                      builder: (context, value, child) {
                        if (value.text.isNotEmpty) return const SizedBox();
                        return CustomElevatedButton(
                          backgroundColor: ref.secondary.withAlpha(50),
                          textColor: ref.secondary,
                          borderRadius: 40,
                          pixelHeight: 50,
                          label: "Import Folder",
                          onClick: () {
                            if (Platform.isAndroid) {
                              CourseFolderImportManager.showFolderImportScreen(context);
                            } else {
                              CourseFolderImportManagerWindows.showFolderImportScreen(context);
                            }
                          },
                        );
                      },
                    ),

                    ConstantSizing.columnSpacing(72),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: CreateCourseButton(
                courseNameController: courseNameController,
                courseCodeController: courseCodeController,
                isCourseCodeFieldVisible: isCourseCodeFieldVisible,
                courseImagePathProvider: courseImagePathProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
