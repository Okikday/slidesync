import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/interop/src/receive_sharing_handler.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/features/main/pod/main_pod.dart';
import 'package:slidesync/app/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/pod/theme_pod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) => true;

  @override
  void didChangePlatformBrightness() async {
    _enforceImmersiveMode();
    super.didChangePlatformBrightness();
  }

  void _enforceImmersiveMode() {
    final isFocusMode = MainPod.me.act(ref).isFocusMode.read(ref).value;
    if (isFocusMode == true) {
      SystemChrome.setEnabledSystemUIMode(.immersive);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed || state == .paused) {
      _enforceImmersiveMode();
    }
  }

  @override
  void didChangeMetrics() => _enforceImmersiveMode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid || Platform.isIOS) {
      ReceiveSharingHandler.instance.init();
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => SystemChrome.setEnabledSystemUIMode(.edgeToEdge),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ReceiveSharingHandler.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // onFilesDropped: (filePaths) async {
    //     log("Dropped files: $filePaths");
    //     Future.delayed(const Duration(milliseconds: 500), () async {
    //       await _showSavingBottomSheet(filePaths);
    //     });
    //   },
    final themeState = ref.watch(ThemePod.me);
    return MaterialApp.router(
      title: "SlideSync",
      routerConfig: AppRouter.mainRouter,
      debugShowCheckedModeBanner: false,
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeState.themeMode,
    );
  }
}

class DummyApp extends ConsumerWidget {
  const DummyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(home: Center(child: Text("This is a text")));
  }
}



    // if (globalInitError != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     // Double-check to prevent duplicate dialogs
    //     if (globalInitError != null) {
    //       showDialog(
    //         context: context,
    //         builder: (ctx) => AlertDialog(
    //           backgroundColor: const Color(0xFF1E1E1E),
    //           title: const Text(
    //             "SlideSync Initialization Error",
    //             style: TextStyle(color: Colors.white),
    //           ),
    //           content: SingleChildScrollView(
    //             child: Text(
    //               globalInitError.toString(),
    //               style: const TextStyle(
    //                 color: Colors.orangeAccent,
    //                 fontFamily: 'monospace',
    //                 fontSize: 12,
    //               ),
    //             ),
    //           ),
    //           actions: [
    //             TextButton(
    //               onPressed: () => Navigator.of(ctx).pop(),
    //               child: const Text("Dismiss"),
    //             ),
    //           ],
    //         ),
    //       );

    //       // Nullify the variable immediately so hot-reloads
    //       // or route changes don't trigger the dialog again
    //       globalInitError = null;
    //     }
    //   });
    // }