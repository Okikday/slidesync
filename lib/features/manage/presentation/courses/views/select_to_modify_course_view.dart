import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/manage/presentation/courses/views/select_to_modify_course/select_to_modify_course_outer_section.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class SelectToModifyCourseView extends ConsumerStatefulWidget {
  const SelectToModifyCourseView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectToModifyCourseViewState();
}

class _SelectToModifyCourseViewState extends ConsumerState<SelectToModifyCourseView> {
  late final NotifierProvider<ImpliedNotifier<Map<int, bool>>, Map<int, bool>> selectedCoursesIdProvider;

  @override
  void initState() {
    super.initState();

    selectedCoursesIdProvider = NotifierProvider(() => ImpliedNotifier(<int, bool>{}), isAutoDispose: true);
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final Map<int, bool> selectedCoursesIdMap = ref.watch(selectedCoursesIdProvider);
    final bool isSelecting = selectedCoursesIdMap.isNotEmpty && selectedCoursesIdMap.containsValue(true);

    return PopScope(
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, result) {
        final selected = ref.read(selectedCoursesIdProvider);
        if (selected.isNotEmpty) {
          ref.read(selectedCoursesIdProvider.notifier).update((cb) => <int, bool>{});
          return;
        }
      },
      child: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(
          Colors.transparent,
          context.isDarkMode,
        ).copyWith(statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          appBar: AppBarContainer(child: AppBarContainerChild(context.isDarkMode, title: 'Select course to modify')),
          body: SelectToModifyCourseOuterSection(
            isSelecting: isSelecting,
            selectedCoursesIdProvider: selectedCoursesIdProvider,
            selectedCoursesIdMap: selectedCoursesIdMap,
          ),
        ),
      ),
    );
  }
}
