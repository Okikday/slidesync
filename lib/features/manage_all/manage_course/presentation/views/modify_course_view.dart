
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/global_providers/data_providers/course_providers.dart';
import 'package:slidesync/core/routes/app_route_navigator.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/actions/modify_course_actions.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/actions/modify_course_view_actions.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/providers/modify_course_providers.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/modify_course/collections_section.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/modify_course/edit_course_bottom_sheet.dart';
import 'package:slidesync/features/manage_all/manage_course/presentation/views/modify_course/modify_course_header.dart';
import 'package:slidesync/shared/components/app_bar_container.dart';
import 'package:slidesync/shared/components/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final modifyCourseNotifier = ref.read(CourseProviders.courseProvider.notifier);

      if ((await ref.read(CourseProviders.courseProvider.future)) != widget.course) {
        modifyCourseNotifier.updateByDate(widget.course);
      }
    });

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
        body: ModifyCourseViewOuterSection(),
      ),
    );
  }
}

class ModifyCourseViewOuterSection extends ConsumerWidget {
  const ModifyCourseViewOuterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Course course = ref.watch(CourseProviders.courseProvider).value ?? defaultCourse;
    final ModifyCourseActions modifyCourseActions = ModifyCourseActions();
    return CustomScrollView(
      slivers: [
        // HEADER
        ModifyCourseHeader(
          title: course.courseName,
          description: course.description.trim(),
          courseCode: course.courseCode.trim(),
          courseFileDetails: course.imageLocationJson,
          onClickEditCourse: () async {
            await showModalBottomSheet(
              context: context,
              enableDrag: false,
              showDragHandle: false,
              isScrollControlled: true,
              builder: (context) => EditCourseBottomSheet(),
            );
          },
          onClickDelete: () {
            if (rootNavigatorKey.currentContext != null && rootNavigatorKey.currentContext!.mounted) {
                      ModifyCourseViewActions().showDeleteCourseDialog(rootNavigatorKey.currentContext!, course);
                    }
          },
          onClickAddDescription: () => modifyCourseActions.onClickAddDescription(context, currDescription: course.description),

          onClickImage: () async {
            if (!course.imageLocationJson.fileDetails.containsFilePath) {
              modifyCourseActions.pickImageActionRoute(context, courseDbId: course.id);
              return;
            }

            modifyCourseActions.onClickCourseImage(ref, course: course);
          },

          onLongPressImage: () async {
            if (!course.imageLocationJson.fileDetails.containsFilePath) {
              modifyCourseActions.pickImageActionRoute(context, courseDbId: course.id);
              return;
            }

            modifyCourseActions.previewImageActionRoute(context, courseImagePath: course.imageLocationJson);
          },
        ),

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
                  if (context.mounted) AppRouteNavigator.to(context).modifyCollectionsRoute(course);
                }
              });
              return;
            }
            AppRouteNavigator.to(context).modifyCollectionsRoute(course);
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
                  AppRouteNavigator.to(context).modifyCollectionsRoute(course);
                },
                borderRadius: 48,
                pixelHeight: 56,
                backgroundColor: context.theme.colorScheme.primary.withAlpha(60),
                label: "See all collections",
                textSize: 15,
                textColor: context.theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
