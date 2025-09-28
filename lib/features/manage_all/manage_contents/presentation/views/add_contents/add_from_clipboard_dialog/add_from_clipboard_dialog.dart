import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/actions/add_contents_actions.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/providers/add_contents_bs_provider.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/add_contents/add_from_clipboard_dialog/sub/build_add_from_clipboard_dialog.dart';

class AddFromClipboardOverlay extends ConsumerStatefulWidget {
  final AppClipboardData clipboardData;
  const AddFromClipboardOverlay({super.key, required this.clipboardData});

  @override
  ConsumerState<AddFromClipboardOverlay> createState() => _AddFromClipboardOverlayState();
}

class _AddFromClipboardOverlayState extends ConsumerState<AddFromClipboardOverlay> {
  @override
  void initState() {
    super.initState();
  }

  void _closeOverlay([bool inPostFrameCallback = true]) {
    void close() {
      final isVisible = ref.read(AddContentsBsProvider.addFromClipboardOverlayEntry);
      if (isVisible == null) return;
      isVisible.remove();
      ref.read(AddContentsBsProvider.addFromClipboardOverlayEntry.notifier).update((cb) => null);
      log("Successfully closed AddFromClipboardOverlay");
    }

    if (inPostFrameCallback) {
      WidgetsBinding.instance.addPostFrameCallback((_) => close());
    } else {
      close();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BuildAddFromClipboardDialog(clipboardData: widget.clipboardData, closeOverlay: _closeOverlay);
  }
}
