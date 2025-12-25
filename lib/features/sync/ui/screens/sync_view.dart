import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/features/sync/providers/sync_state.dart';
import 'package:slidesync/features/sync/ui/screens/downloads_tab_view.dart';
import 'package:slidesync/features/sync/ui/screens/uploads_tab_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

class SyncView extends ConsumerStatefulWidget {
  const SyncView({super.key});

  @override
  ConsumerState<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends ConsumerState<SyncView> with SingleTickerProviderStateMixin {
  late final tabController = TabController(vsync: this, length: 2);

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return Scaffold(
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          context.isDarkMode,
          title: "Sync",
          trailing: BuildButton(
            onTap: () {},
            iconData: Iconsax.activity_copy,
            backgroundColor: theme.altBackgroundSecondary,
            iconColor: theme.secondary,
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ColoredBox(
                color: theme.adjustBgAndPrimaryWithLerp,
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(color: theme.altBackgroundPrimary, borderRadius: BorderRadius.circular(100)),
                  tabAlignment: TabAlignment.fill,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(text: "Downloads"),
                    Tab(text: "Uploads"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(controller: tabController, children: [DownloadsTabView(), UploadsTabView()]),
          ),
        ],
      ),
    );
  }
}
