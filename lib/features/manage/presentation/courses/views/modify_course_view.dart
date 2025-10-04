import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/features/manage/presentation/collections/views/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/manage/presentation/courses/views/modify_course/collections_section.dart';
import 'package:slidesync/features/manage/presentation/courses/views/modify_course/modify_course_header.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

/// VIEW
class ModifyCourseView extends ConsumerStatefulWidget {
  final Course course;
  const ModifyCourseView({super.key, required this.course});

  @override
  ConsumerState createState() => _ModifyCourseState();
}

class _ModifyCourseState extends ConsumerState<ModifyCourseView> with TickerProviderStateMixin {
  late final ValueNotifier<bool> canPopNotifier;

  @override
  void initState() {
    super.initState();

    canPopNotifier = ValueNotifier(true);
  }

  @override
  void dispose() {
    canPopNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(
          child: AppBarContainerChild(
            context.isDarkMode,
            title: 'Modify course',
            // onBackButtonClicked: () async {
            //   context.pop();
            // },
          ),
        ),
        body: ModifyCourseViewOuterSection(courseId: widget.course.courseId),
      ),
    );
  }
}

class ModifyCourseViewOuterSection extends ConsumerWidget {
  final String courseId;
  const ModifyCourseViewOuterSection({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Course course = ref.watch(CourseProviders.courseProvider(courseId)).value ?? defaultCourse;
    ref.listen(CourseProviders.courseProvider(courseId), (p, n) {
      log("Soemthings");
    });
    return CustomScrollView(
      slivers: [
        // HEADER
        ModifyCourseHeader(courseId: courseId),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacingExtraLarge),

        // BODY
        CollectionsSection(
          courseDbId: course.id,
          collections: course.collections.toList(),
          onClickNewCollection: () {
            if (course.collections.isEmpty) {
              CustomDialog.show(
                context,
                canPop: true,
                barrierColor: Colors.black.withAlpha(150),
                child: CreateCollectionBottomSheet(courseDbId: course.id),
              ).then((value) {
                if (course.collections.isNotEmpty) {
                  if (context.mounted) context.pushNamed(Routes.modifyCollections.name, extra: course.courseId);
                }
              });
              return;
            }
            context.pushNamed(Routes.modifyCollections.name, extra: course.courseId);
          },
        ),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        // AFTER
        if (course.collections.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: CustomElevatedButton(
                onClick: () {
                  context.pushNamed(Routes.modifyCollections.name, extra: course.courseId);
                },
                borderRadius: 48,
                pixelHeight: 56,
                backgroundColor: ref.primary.withAlpha(60),
                label: "See all collections",
                textSize: 15,
                textColor: ref.primary,
              ),
            ),
          ),
      ],
    );
  }
}
