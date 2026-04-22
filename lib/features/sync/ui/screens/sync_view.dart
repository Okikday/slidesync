import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/ui/widgets/sync_view/downloads_tab_view.dart';
import 'package:slidesync/features/sync/ui/widgets/sync_view/uploads_tab_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';

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
      body: TopPadding(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: theme.onBackground.withValues(alpha: 0.15),
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: ColoredBox(
                    color: Colors.transparent,
                    child: TabBar(
                      controller: tabController,
                      indicator: BoxDecoration(
                        color: theme.altBackgroundPrimary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      tabAlignment: TabAlignment.fill,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Downloads'),
                        Tab(text: 'Uploads'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(controller: tabController, children: [DownloadsTabView(), UploadsTabView()]),
            ),
          ],
        ),
      ),
    );
  }
}
