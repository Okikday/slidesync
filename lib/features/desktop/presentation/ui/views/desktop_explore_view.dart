import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/explore/ui/explore_tab_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

/// The "Explore" page for the desktop layout.
/// This is a wrapper around the existing mobile `ExploreTabView`.
class DesktopExploreView extends ConsumerWidget {
  const DesktopExploreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ref.theme.background,
      // The mobile ExploreTabView is simple and can be reused directly.
      body: const ExploreTabView(),
    );
  }
}
