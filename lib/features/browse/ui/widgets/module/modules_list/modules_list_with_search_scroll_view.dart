import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/ui/screens/course_view.dart';
import 'package:slidesync/features/browse/ui/widgets/module/modules_list/src/collections_search_bar.dart';
import 'package:slidesync/features/settings/providers/settings_provider.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/ui/widgets/module/module_card.dart';
import 'package:slidesync/features/browse/ui/widgets/course/shared/create_collection_bottom_sheet.dart';
import 'package:slidesync/features/browse/ui/widgets/module/no_collection_view.dart';
import 'package:slidesync/shared/global/providers/collections_providers.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class ModulesListWithSearchScrollView extends ConsumerStatefulWidget {
  const ModulesListWithSearchScrollView({
    super.key,
    required this.courseId,
    required this.topPadding,
    required this.isPinned,
    required this.showMoreOptionsButton,
    this.controller,
    this.onTapModuleCard,
  });
  final String courseId;
  final double? topPadding;
  final bool isPinned;
  final bool showMoreOptionsButton;
  final ScrollController? controller;
  final void Function(Module module)? onTapModuleCard;
  @override
  ConsumerState<ModulesListWithSearchScrollView> createState() => ModulesListWithSearchScrollViewState();
}

class ModulesListWithSearchScrollViewState extends ConsumerState<ModulesListWithSearchScrollView> {
  final textSearchNotifier = ValueNotifier<String>('');

  @override
  void dispose() {
    textSearchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmoothCustomScrollView(
      controller: widget.controller,
      slivers: [
        if (widget.topPadding != null) SliverToBoxAdapter(child: TopPadding(withHeight: widget.topPadding)),

        widget.isPinned ? PinnedHeaderSliver(child: _buildSearchBar()) : SliverFloatingHeader(child: _buildSearchBar()),

        ModulesListView(
          courseId: widget.courseId,
          textSearchNotifier: textSearchNotifier,
          onTapModuleCard: widget.onTapModuleCard,
        ),

        const SliverToBoxAdapter(child: BottomPadding(withHeight: ConstantSizing.spaceMedium)),
      ],
    );
  }

  Widget _buildSearchBar() => CollectionsViewSearchBar(
    courseId: widget.courseId,
    onChanged: (text) => textSearchNotifier.value = text,

    onTap: () {
      if (!DeviceUtils.isDesktop()) {
        PrimaryScrollController.of(
          context,
        ).animateTo((courseDetailsAppBarHeight + 8), duration: Durations.medium4, curve: CustomCurves.defaultIosSpring);
      }
    },
    showTrailing: widget.showMoreOptionsButton,
  );
}

class ModulesListView extends ConsumerWidget {
  const ModulesListView({
    super.key,
    required this.courseId,
    required this.textSearchNotifier,
    required this.onTapModuleCard,
  });
  final String courseId;
  final ValueNotifier<String> textSearchNotifier;
  final void Function(Module module)? onTapModuleCard;

  List<Module> filterModules(List<Module> modules, String search) => search.trim().isEmpty
      ? modules
      : modules.where((e) => e.title.toLowerCase().contains(search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchCollectionsAsync = ref.watch(CollectionsProviders.watchCollectionsInCourseProvider(courseId));
    return watchCollectionsAsync.when(
      data: (collections) {
        if (collections.isEmpty) {
          return NoCollectionView(
            showAddButton: true,
            onClickAddCollection: () async {
              if (context.mounted) {
                CustomDialog.show(
                  context,
                  canPop: true,
                  barrierColor: Colors.black.withAlpha(150),
                  child: CreateCollectionBottomSheet(courseId: courseId),
                );
              }
            },
          );
        }

        return ValueListenableBuilder(
          valueListenable: textSearchNotifier,
          builder: (context, value, child) {
            final filteredModules = filterModules(collections, value);
            final isSearching = value.trim().isNotEmpty;

            final animThreshold = 0.4 / filteredModules.length;

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: filteredModules.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final animEffect = <Effect>[
                    const FadeEffect(end: 1, begin: 0),
                    SlideEffect(
                      begin: Offset(0, animThreshold * index),
                      end: Offset.zero,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: Durations.extralong2,
                    ),
                  ];
                  return Animate(
                    effects: isSearching ? null : animEffect,
                    child: ModuleCard(module: filteredModules[index], onTap: () => onTap(ref, filteredModules[index])),
                  );
                },
              ),
            );
          },
        );
      },
      error: (error, st) => _buildErrorSliver(),
      loading: () => const ModulesSliverListLoadingShimmer(),
    );
  }

  void onTap(WidgetRef ref, Module module) async {
    if (onTapModuleCard != null) {
      onTapModuleCard!(module);
    } else {
      final isFullScreen = DeviceUtils.isDesktop() ? (await ref.readSettings).showMaterialsInFullScreen : false;
      Result.tryRun(
        () => ref.context.pushNamed("${Routes.moduleContentsView.name}${isFullScreen ? "full" : ''}", extra: module),
      );
    }
  }

  Widget _buildErrorSliver() => SliverToBoxAdapter(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotatedBox(quarterTurns: 2, child: Icon(HugeIconsSolid.informationCircle, size: 48)),
        CustomText("Error loading course!"),
      ],
    ),
  );
}

class ModulesSliverListLoadingShimmer extends ConsumerWidget {
  final int count;
  const ModulesSliverListLoadingShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: count,
          shrinkWrap: true,
          itemBuilder: (context, index) => Skeletonizer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ModuleCard(module: Module.empty(), onTap: () {}),
            ),
          ),
        ),
      ),
    );
  }
}
