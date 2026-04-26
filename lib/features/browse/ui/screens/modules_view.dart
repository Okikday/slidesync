import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/base/mixins/is_scrolled_notifier_mixin.dart';
import 'package:slidesync/features/browse/ui/widgets/module/modules_list/modules_list_with_search_sliver.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/global/providers/course_providers.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/add_collection_action_button.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

import '../../../../core/utils/ui_utils.dart';

class ModulesView extends ConsumerStatefulWidget {
  final String courseId;

  const ModulesView({super.key, required this.courseId});

  @override
  ConsumerState createState() => _ModulesViewState();
}

class _ModulesViewState extends ConsumerState<ModulesView> with IsScrolledNotifierMixin {
  @override
  double get scrollThreshold => 20;

  @override
  Widget build(BuildContext context) {
    final courseProvider = CourseProviders.courseProvider(widget.courseId);

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      child: AppScaffold(
        title: "Collections view",
        extendBodyBehindAppBar: true,
        appBar: AppBarContainer(
          child: AbsorberWatch(
            listenable: courseProvider.select((c) => c.whenData((cb) => (cb.courseName, cb.courseCode))),
            builder: (context, courseSelectAsync, ref, child) {
              return courseSelectAsync.when(
                data: (data) =>
                    AppBarContainerChild(context.isDarkMode, title: data.$1, tooltipMessage: "${data.$1}(${data.$2})"),
                error: (_, _) => Icon(Icons.error),
                loading: () =>
                    AppBarContainerChild(context.isDarkMode, title: "...", tooltipMessage: "Loading course..."),
              );
            },
          ),
        ),

        floatingActionButton: ValueListenableBuilder(
          valueListenable: isScrolledNotifier,
          builder: (context, isScrolled, child) {
            return AddCollectionActionButton(
              courseId: widget.courseId,
              isScrolled: isScrolled,
              onClickUp: () =>
                  scrollController.animateTo(0.0, duration: Durations.medium1, curve: CustomCurves.defaultIosSpring),
            );
          },
        ),

        body: ModulesListWithSearchScrollViwe(
          courseId: widget.courseId,
          topPadding: 60,
          isPinned: false,
          showMoreOptionsButton: false,
          controller: scrollController,
        ),
      ),
    );
  }
}
