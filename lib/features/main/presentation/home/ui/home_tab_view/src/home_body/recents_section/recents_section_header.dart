import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/main/presentation/home/logic/home_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class RecentsSectionHeader extends ConsumerWidget {
  const RecentsSectionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final asyncMostRecent = ref.watch(
      HomeProvider.recentContentsTrackProvider(1).select((s) => s.whenData((v) => v.isEmpty ? null : v.last)),
    );
    return asyncMostRecent.when(
      data: (data) {
        if (data == null) return const SliverToBoxAdapter();
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ConstantSizing.spaceMedium, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  child: CustomText("Recents", fontSize: 16, fontWeight: FontWeight.bold, color: theme.onBackground),
                ),

                CustomTextButton(
                  label: "See all",
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textColor: theme.backgroundSupportingText,
                  textSize: 14,
                  pixelHeight: 32,
                  onClick: () {
                    context.pushNamed(Routes.recentsView.name);
                  },
                ),
              ],
            ),
          ),
        );
      },
      error: (e, st) => const SliverToBoxAdapter(),
      loading: () => SliverToBoxAdapter(
        child: Center(child: CustomText("Checking recents...", fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
