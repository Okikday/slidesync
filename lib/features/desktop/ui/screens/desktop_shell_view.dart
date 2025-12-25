import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/ui/screens/home_tab_view.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_drawer.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/library_floating_action_button.dart';
import 'package:slidesync/features/main/ui/screens/library_tab_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class DesktopShellView extends ConsumerWidget {
  final Widget child;

  const DesktopShellView({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentPath = GoRouterState.of(context).uri.path;
    // final isDetailRoute = _isDetailRoute(currentPath);
    final theme = ref;

    return PopScope(
      canPop: false,
      child: Scaffold(
        drawer: const HomeDrawer(),
        body: Row(
          children: [
            // Home Tab Panel (300-400px)
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
                  ),
                  child: const HomeTabView(),
                ),
              ),
            ),

            Expanded(
              child: Container(
                constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: theme.onBackground.withValues(alpha: 0.1), width: 1)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const LibraryTabView(),
                    Positioned(bottom: 12, right: 12, child: const LibraryFloatingActionButton(isDesktop: true)),
                  ],
                ),
              ),
            ),

            // Rightmost Panel (Dynamic content)
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  // bool _isDetailRoute(String path) {
  //   // Always show the child from the shell route
  //   // The child will be the _EmptyStatePlaceholder for /home and /library routes
  //   return true;
  // }
}
