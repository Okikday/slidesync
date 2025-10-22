import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_body.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

/// The "Home" page for the desktop layout.
/// It reuses the `HomeBody` widget from the mobile UI.
class DesktopHomeView extends ConsumerWidget {
  const DesktopHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use a Scaffold to provide a consistent background color and structure.
    return Scaffold(
      backgroundColor: ref.theme.background,
      // HomeBody contains the dashboard and recents sections.
      body: const HomeBody(),
    );
  }
}
