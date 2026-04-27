import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/core/base/mixins/is_scrolled_notifier_mixin.dart';
import 'package:slidesync/features/browse/providers/module_contents_provider.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/mod_contents_options.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/module_contents_app_bar.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/add_contents/add_content_fab.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/contents_view.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

const scrollThreshold = 100.0;

class ModuleContentsView extends ConsumerStatefulWidget {
  final Module collection;
  final bool isFullScreen;
  const ModuleContentsView({super.key, required this.collection, required this.isFullScreen});

  @override
  ConsumerState<ModuleContentsView> createState() => _ModuleContentsViewState();
}

class _ModuleContentsViewState extends ConsumerState<ModuleContentsView> with IsScrolledNotifierMixin {
  @override
  Widget build(BuildContext context) {
    final state = ModuleContentsProvider.state(widget.collection.id);
    ref.listen(state, (p, n) => n);

    return AppScaffold(
      title: "Contents View",
      systemUiOverlayStyle: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          context.isDarkMode,
          title: widget.collection.title,
          trailing: ModuleContentsAppBar(collection: widget.collection, isFullScreen: widget.isFullScreen),
        ),
      ),
      extendBodyBehindAppBar: true,

      floatingActionButton: ValueListenableBuilder(
        valueListenable: isScrolledNotifier,
        builder: (context, isScrolled, child) {
          return AddContentFAB(
            collection: widget.collection,
            isScrolled: isScrolled,
            scrollController: scrollController,
          );
        },
      ),

      body: RefreshIndicator(
        onRefresh: () async => state.act(ref).contentsPagination.act(ref).pagingController.refresh(),
        child: SmoothCustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: TopPadding(withHeight: 72)),
            ModContentsOptions(collection: widget.collection),
            ContentsView(collection: widget.collection, isFullScreen: widget.isFullScreen),
            SliverToBoxAdapter(child: BottomPadding(withHeight: 64)),
          ],
        ),
      ),
    );
  }
}
