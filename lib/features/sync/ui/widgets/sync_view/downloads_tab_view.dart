import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/ui/components/sync_card.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class DownloadsTabView extends ConsumerStatefulWidget {
  const DownloadsTabView({super.key});

  @override
  ConsumerState<DownloadsTabView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends ConsumerState<DownloadsTabView> {
  @override
  Widget build(BuildContext context) {
    return SmoothCustomScrollView(
      slivers: [
        SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TransferCard(
                data: downloadData,
                onTap: () => print('Card tapped'),
                onPause: () => print('Pause download'),
                onResume: () => print('Resume download'),
                onCancel: () => print('Cancel download'),
                onRetry: () => print('Retry download'),
                onDelete: () => print('Delete from list'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
