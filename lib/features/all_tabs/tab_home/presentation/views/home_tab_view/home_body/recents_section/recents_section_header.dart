import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/all_tabs/tab_home/presentation/providers/home_tab_view_providers.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class RecentsSectionHeader extends ConsumerWidget {
  final void Function() onClickSeeAll;
  const RecentsSectionHeader({
    super.key,
    required this.onClickSeeAll
  });

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.theme;
    final asyncRecentsValue = ref.watch(HomeTabViewProviders.recentProgressTrackProvider);
    return asyncRecentsValue.when(
      data: (data) {
        if (data.isEmpty) return const SliverToBoxAdapter();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ConstantSizing.spaceMedium, vertical: 0),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                "Recents",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.onBackground,
              ),
            ),
      
            CustomTextButton(
              label: "See all",
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textColor: theme.supportingText.withValues(alpha: 0.9),
              textSize: 14,
              pixelHeight: 32,
              onClick: onClickSeeAll,
            ),
          ],
        ),
      ),
    );
      },
      error: (e, st) => const SliverToBoxAdapter(),
      loading:
          () => SliverToBoxAdapter(
            child: Center(child: CustomText("Checking recents...", fontSize: 16, fontWeight: FontWeight.bold)),
          ),
    );
    
  }
}