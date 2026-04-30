import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/modify_contents/redirect_contents_screen.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class ReceiveSharingHandler {
  StreamSubscription? _intentSub;
  bool _isProcessing = false;
  String? _lastSignature;
  DateTime? _lastAt;

  final List<_SharedBatch> _queue = [];

  void init() {
    Result.tryRun(() {
      // Stream: fires during app lifetime, nav is always ready by then
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (value) => _onShared(value, fromInitialIntent: false),
        onError: (err, st) => log('ReceiveSharingIntent stream error: $err', stackTrace: st),
      );

      // Initial: wait for first frame before processing
      ReceiveSharingIntent.instance.getInitialMedia().then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onShared(value, fromInitialIntent: true);
        });
      });
    });
  }

  void dispose() {
    _intentSub?.cancel();
    _intentSub = null;
  }

  void _onShared(List<SharedMediaFile> sharedFiles, {required bool fromInitialIntent}) {
    if (sharedFiles.isEmpty) return;

    final filePaths = <String>[];
    final linkUrls = <String>[];

    for (final f in sharedFiles) {
      final raw = f.path.trim();
      if (raw.isEmpty) continue;

      switch (f.type) {
        case SharedMediaType.url:
          if (_isValidHttpUrl(raw)) linkUrls.add(raw);
        case SharedMediaType.text:
          // Cross-check: only treat as link if it's a valid http/https URL
          if (_isValidHttpUrl(raw)) linkUrls.add(raw);
        case SharedMediaType.image:
        case SharedMediaType.video:
        case SharedMediaType.file:
          filePaths.add(raw);
      }
    }

    if (filePaths.isEmpty && linkUrls.isEmpty) {
      if (fromInitialIntent) ReceiveSharingIntent.instance.reset();
      return;
    }

    final signature = [...filePaths, ...linkUrls].join('|');
    final now = DateTime.now();

    // Deduplicate duplicate OEM double-fires
    if (_lastSignature == signature && _lastAt != null && now.difference(_lastAt!) < const Duration(seconds: 2)) {
      if (fromInitialIntent) ReceiveSharingIntent.instance.reset();
      return;
    }

    _lastSignature = signature;
    _lastAt = now;

    _queue.add(_SharedBatch(filePaths: filePaths, linkUrls: linkUrls));
    log('Incoming shared — files: $filePaths | links: $linkUrls');

    if (fromInitialIntent) ReceiveSharingIntent.instance.reset();

    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      while (_queue.isNotEmpty) {
        await _showRedirect(_queue.removeAt(0));
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _showRedirect(_SharedBatch batch) async {
    GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Received contents!"));

    final res = await GlobalNav.withContextAsync<bool>((context) async {
      final pushRes = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RedirectContentsScreen.store(files: batch.filePaths, linkUrls: batch.linkUrls),
        ),
      );
      return pushRes is bool ? pushRes : false;
    });

    if (res == true) {
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Saved contents"));
    }
  }

  static bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }
}

class _SharedBatch {
  final List<String> filePaths;
  final List<String> linkUrls;

  const _SharedBatch({required this.filePaths, required this.linkUrls});
}
