import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/library/ui/library_tab_view.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

/// The "Library" page for the desktop layout.
/// This is a wrapper around the existing mobile `LibraryTabView`.
class DesktopLibraryView extends ConsumerWidget {
  const DesktopLibraryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ref.theme.background,
      // The mobile LibraryTabView is self-contained and works well here.
      body: const LibraryTabView(),
    );
  }
}
