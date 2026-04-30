import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/interop/src/receive_sharing_handler.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  ReceiveSharingHandler? _sharingHandler;
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
      _sharingHandler = ReceiveSharingHandler()..init();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await notifyThemeOnBrightnessChanged(ref);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sharingHandler?.dispose();
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
    );
  }
}





// class DummyApp extends ConsumerWidget {
//   const DummyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MaterialApp(home: Center(child: Text("This is a text"),));
//   }
// }