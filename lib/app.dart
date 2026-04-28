import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/src/modify_contents/redirect_contents_screen.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/theme/theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription? _intentSub;
  final List<List<String>> _pendingSharedFileBatches = [];
  bool _isProcessingSharedFiles = false;
  String? _lastSharedSignature;
  DateTime? _lastSharedAt;

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    return true;
  }

  @override
  void didChangePlatformBrightness() async {
    _enforceImmersiveMode();
    WidgetsBinding.instance.addPostFrameCallback((_) async => notifyThemeOnBrightnessChanged(ref));
    super.didChangePlatformBrightness();
  }

  void _enforceImmersiveMode() {
    final isFocusMode = MainProvider.state.act(ref).isFocusMode.read(ref);

    if (isFocusMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enforceImmersiveMode();
    }
  }

  @override
  void didChangeMetrics() {
    _enforceImmersiveMode();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid || Platform.isIOS) {
      Result.tryRun(() {
        _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
          (value) => _handleIncomingSharedMedia(value, fromInitialIntent: false),
          onError: (err, stackTrace) {
            log('ReceiveSharingIntent stream error: $err', stackTrace: stackTrace);
          },
        );

        // Get the media sharing coming from outside the app while the app is closed.
        unawaited(
          ReceiveSharingIntent.instance.getInitialMedia().then(
            (value) => _handleIncomingSharedMedia(value, fromInitialIntent: true),
          ),
        );
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await notifyThemeOnBrightnessChanged(ref);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;

    // onFilesDropped: (filePaths) async {
    //     log("Dropped files: $filePaths");
    //     Future.delayed(const Duration(milliseconds: 500), () async {
    //       await _showSavingBottomSheet(filePaths);
    //     });
    //   },

    return MaterialApp.router(
      title: "SlideSync",
      routerConfig: AppRouter.mainRouter,
      debugShowCheckedModeBanner: false,
      theme: resolveThemeData(theme),
      // scrollBehavior: WindowsScrollBehavior(),
      // builder: (context, child) {
      //   return child ?? const SizedBox.shrink();
      // },
    );
  }

  // Future<void> _showReceivingDialog() async {
  //   if (_pendingSharedFileBatches.isNotEmpty) {
  //     await _processPendingSharedBatches();
  //   }
  // }

  Future<void> _handleIncomingSharedMedia(List<SharedMediaFile> sharedFiles, {required bool fromInitialIntent}) async {
    if (!mounted || sharedFiles.isEmpty) return;

    final paths = sharedFiles.map((e) => e.path.trim()).where((e) => e.isNotEmpty).toList(growable: false);
    if (paths.isEmpty) return;

    final signature = paths.join('|');
    final now = DateTime.now();

    // Some OEMs emit the same payload through both initial and stream callbacks.
    if (_lastSharedSignature == signature &&
        _lastSharedAt != null &&
        now.difference(_lastSharedAt!) < const Duration(seconds: 2)) {
      if (fromInitialIntent) {
        unawaited(ReceiveSharingIntent.instance.reset());
      }
      return;
    }

    _lastSharedSignature = signature;
    _lastSharedAt = now;

    _pendingSharedFileBatches.add(paths);
    log('Incoming shared files: $paths');

    if (fromInitialIntent) {
      unawaited(ReceiveSharingIntent.instance.reset());
    }

    await _processPendingSharedBatches();
  }

  Future<void> _processPendingSharedBatches() async {
    if (_isProcessingSharedFiles || !mounted) return;
    _isProcessingSharedFiles = true;

    try {
      while (mounted && _pendingSharedFileBatches.isNotEmpty) {
        final files = _pendingSharedFileBatches.removeAt(0);
        final navReady = await _waitForNavigatorContext();
        if (!mounted) return;

        if (!navReady) {
          _pendingSharedFileBatches.insert(0, files);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            unawaited(_processPendingSharedBatches());
          });
          return;
        }

        await _showSavingBottomSheet(files);
      }
    } finally {
      _isProcessingSharedFiles = false;
    }
  }

  Future<bool> _waitForNavigatorContext() async {
    if (GlobalNav.isAvailable) return true;

    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      if (GlobalNav.isAvailable) return true;
    }

    return GlobalNav.isAvailable;
  }

  Future<void> _showSavingBottomSheet(List<String> files) async {
    UiUtils.showFlushBar(context, msg: "Received contents!");
    final res = await GlobalNav.withContextAsync<bool>((context) async {
      final pushRes = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => RedirectContentsScreen.store(files: files)));
      if (pushRes is bool) return pushRes;
      return false;
    });

    if (res == true) {
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Saved contents"));
    }
  }
}





// class DummyApp extends ConsumerWidget {
//   const DummyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MaterialApp(home: Center(child: Text("This is a text"),));
//   }
// }