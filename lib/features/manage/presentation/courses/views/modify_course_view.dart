import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/features/browse/presentation/views/course_details/course_details_collection_section.dart';
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
  final String courseId;
  const ModifyCourseView({super.key, required this.courseId});

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
        body: ModifyCourseViewOuterSection(courseId: widget.courseId),
      ),
    );
  }
}

class ModifyCourseViewOuterSection extends ConsumerWidget {
  final String courseId;
  const ModifyCourseViewOuterSection({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(CourseProviders.courseProvider(courseId), (p, n) {
      log("Soemthings");
    });
    return CustomScrollView(
      slivers: [
        // HEADER
        Consumer(
          builder: (context, ref, child) {
            final courseRecordN = ref.watch(
              CourseProviders.courseProvider(courseId).select(
                (s) => s.whenData(
                  (cb) => (
                    courseId: cb.courseId,
                    courseCode: cb.courseCode,
                    title: cb.courseTitle,
                    description: cb.description,
                    imageDetails: cb.imageLocationJson,
                  ),
                ),
              ),
            );
            return courseRecordN.when(
              data: (data) {
                return ModifyCourseHeader(
                  courseId: courseId,
                  courseCode: data.courseCode,
                  title: data.title,
                  description: data.description,
                  imageDetails: data.imageDetails,
                );
              },
              error: (_, _) => Icon(Icons.error),
              loading: () => const ModifyCourseHeader(
                courseId: "",
                courseCode: "",
                title: "",
                description: "description",
                imageDetails: '',
              ),
            );
          },
        ),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacingExtraLarge),

        // BODY
        Consumer(
          builder: (context, ref, child) {
            final links = ref.watch(
              CourseProviders.courseProvider(courseId).select((s) => s.whenData((cb) => cb.collections)),
            );
            return links.when(
              data: (data) {
                return CollectionsSection(courseId: courseId, collections: data.toList());
              },
              error: (_, _) => const SliverToBoxAdapter(child: Icon(Icons.error)),
              loading: () => const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LoadingShimmerListView(count: 2)),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        Consumer(
          builder: (context, ref, child) {
            final links = ref.watch(
              CourseProviders.courseProvider(courseId).select((s) => s.whenData((cb) => cb.collections)),
            );
            return links.when(
              data: (data) {
                if (data.isEmpty) const SliverToBoxAdapter();
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: CustomElevatedButton(
                      onClick: () {
                        context.pushNamed(Routes.modifyCollections.name, extra: courseId);
                      },
                      borderRadius: 48,
                      pixelHeight: 56,
                      backgroundColor: ref.primary.withAlpha(60),
                      label: "See all collections",
                      textSize: 15,
                      textColor: ref.primary,
                    ),
                  ),
                );
              },
              error: (_, _) => const SliverToBoxAdapter(),
              loading: () => const SliverToBoxAdapter(),
            );
          },
        ),

        // AFTER
      ],
    );
  }
}
