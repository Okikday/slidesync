import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/actions/courses_view_actions.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/providers/library_tab_view_providers.dart';
import 'package:slidesync/features/all_tabs/tab_library/presentation/views/library_tab_view/library_tab_view_app_bar/library_tab_view_layout_button.dart';
import 'package:slidesync/features/course_navigation/presentation/providers/course_materials_providers.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/materials_search_button.dart';
import 'package:slidesync/features/manage_all/manage_collections/presentation/views/modify_collections/collections_view_search_bar.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/add_contents/add_content_fab.dart';
import 'package:slidesync/features/course_navigation/presentation/views/course_materials/materials_view.dart';
import 'package:slidesync/shared/common_widgets/app_popup_menu_button.dart';
import 'package:slidesync/shared/components/app_bar_container.dart';
import 'package:slidesync/shared/components/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class CourseMaterialsView extends ConsumerStatefulWidget {
  final CourseCollection collection;
  const CourseMaterialsView({super.key, required this.collection});

  @override
  ConsumerState<CourseMaterialsView> createState() => _CourseMaterialsViewState();
}

class _CourseMaterialsViewState extends ConsumerState<CourseMaterialsView> {
  late final ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Result.tryRunAsync(() async {
        final option =
            CourseSortOption.values[await AppHiveData.instance.getData(key: HiveDataPaths.courseMaterialsSortOption)
                    as int? ??
                CourseSortOption.none.index];
        ref
            .read(CourseMaterialsProviders.contentsFilterOption(widget.collection.collectionId).notifier)
            .update((cb) => option);
      });
    });
  }

  void scrollListener() {
    final scrollOffsetNotifier = ref.read(CourseMaterialsProviders.scrollOffsetProvider.notifier);
    scrollOffsetNotifier.update((cb) => scrollController.offset); //
    // final prevOffset = scrollOffsetNotifier.state;
    // final currOffset = scrollController.offset;
    // if (currOffset != prevOffset) {
    //   scrollOffsetNotifier.update((cb) => currOffset);
    // }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;
    // ref.watch(streamedCollection).value ??
    final CourseCollection collection = widget.collection;
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(
          child: AppBarContainerChild(
            context.isDarkMode,
            title: collection.collectionTitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialsSearchButton(),
                AppPopupMenuButton(
                  menuPadding: EdgeInsets.only(right: 16),
                  actions: [
                    ref
                        .watch(CourseMaterialsProviders.cardViewType)
                        .when(
                          data: (data) {
                            final isGrid = data == 0;
                            return PopupMenuAction(
                              title: "View",
                              iconData: isGrid ? Iconsax.grid_1 : Iconsax.arrange_square,
                              onTap: () {
                                ref.read(CourseMaterialsProviders.cardViewType.notifier).toggle();
                              },
                            );
                          },
                          error: (e, st) => PopupMenuAction(title: "View", iconData: Icons.error_rounded, onTap: () {}),
                          loading: () => PopupMenuAction(title: "View", iconData: Icons.circle_outlined, onTap: () {}),
                        ),
                    PopupMenuAction(
                      title: "Sort",
                      iconData: Iconsax.arrange_circle,
                      onTap: () {
                        UiUtils.showCustomDialog(
                          context,
                          child: AppCustomizableDialog(
                            backgroundColor: theme.background.withValues(alpha: 0.9),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 250),
                              child: Column(
                                children: [
                                  CustomText(
                                    "Sort by",
                                    color: theme.onSurface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  ConstantSizing.columnSpacingSmall,
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: CourseSortOption.values.length,
                                      itemBuilder: (context, index) {
                                        return CustomElevatedButton(
                                          pixelHeight: 44,
                                          backgroundColor: Colors.transparent,
                                          borderRadius: 0,
                                          onClick: () async {
                                            final newValue =
                                                CourseSortOption.values[index.clamp(0, CourseSortOption.values.length)];
                                            ref
                                                .read(
                                                  CourseMaterialsProviders.contentsFilterOption(
                                                    collection.collectionId,
                                                  ).notifier,
                                                )
                                                .update((cb) => newValue);
                                            await Result.tryRunAsync(() async {
                                              await AppHiveData.instance.setData(
                                                key: HiveDataPaths.courseMaterialsSortOption,
                                                value: newValue.index,
                                              );
                                            });
                                            if (context.mounted) UiUtils.hideDialog(context);
                                          },
                                          child: Row(
                                            children: [
                                              RadioGroup<int>(
                                                groupValue: ref
                                                    .watch(
                                                      CourseMaterialsProviders.contentsFilterOption(
                                                        collection.collectionId,
                                                      ),
                                                    )
                                                    .index,
                                                onChanged: (p) async {
                                                  final newValue = CourseSortOption
                                                      .values[index.clamp(0, CourseSortOption.values.length)];
                                                  ref
                                                      .read(
                                                        CourseMaterialsProviders.contentsFilterOption(
                                                          collection.collectionId,
                                                        ).notifier,
                                                      )
                                                      .update((cb) => newValue);
                                                  await Result.tryRunAsync(() async {
                                                    await AppHiveData.instance.setData(
                                                      key: HiveDataPaths.courseMaterialsSortOption,
                                                      value: newValue.index,
                                                    );
                                                  });
                                                },
                                                child: Radio(value: index,),
                                              ),
                                              Expanded(child: CustomText(CourseSortOption.values[index].label)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: AddContentFAB(
          collection: collection,
          scrollOffsetProvider: CourseMaterialsProviders.scrollOffsetProvider,
        ),

        body: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [MaterialsView(collection: collection)],
        ),
      ),
    );
  }
}
