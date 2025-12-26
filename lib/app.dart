import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/main/providers/main_provider.dart';
import 'package:slidesync/features/browse/collection/ui/widgets/modify_contents/move_to_collection_bottom_sheet.dart';
import 'package:slidesync/features/settings/providers/settings_provider.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/theme/theme.dart';

final NotifierProvider<AppThemeProvider, AppTheme> appThemeProvider = NotifierProvider(AppThemeProvider.new);

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription? _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  Future<void> _loadThemeFromHive() async {
    await Result.tryRunAsync(() async {
      final String? hiveTheme = (await AppHiveData.instance.getData<String>(key: HiveDataPathKey.appTheme.name));
      if (hiveTheme == null) {
        // ref.read(appThemeProvider.notifier).update(Brightness.dark, defaultUnifiedThemeModels[0]);
        return;
      }
      final UnifiedThemeModel unifiedTheme = UnifiedThemeModel.fromJson(hiveTheme);

      if (mounted) {
        final currentBrightness = MediaQuery.platformBrightnessOf(context);
        ref.read(appThemeProvider.notifier).update(currentBrightness, unifiedTheme);
      }
    });
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    return true;
  }

  @override
  void didChangePlatformBrightness() async {
    _enforceImmersiveMode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAdaptiveBrightness = (await ref.readSettings).useSystemBrightness;
      if (isAdaptiveBrightness) {
        _loadThemeFromHive();
      }
    });
    super.didChangePlatformBrightness();
  }

  void _enforceImmersiveMode() {
    final isFocusMode = ref.read(MainProvider.isFocusModeProvider);
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
        _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
          Result.tryRun(() {
            _sharedFiles.clear();
            _sharedFiles.addAll(value);
            log(_sharedFiles.map((f) => f.toMap()).toString());
            Future.delayed(const Duration(milliseconds: 500), () {
              _showReceivingDialog().then((_) async {
                ReceiveSharingIntent.instance.reset();
              });
            });
          });
          log(_sharedFiles.map((f) => f.toMap()).toString());
        }, onError: (err) {});

        // Get the media sharing coming from outside the app while the app is closed.
        ReceiveSharingIntent.instance.getInitialMedia().then((value) {
          Result.tryRun(() {
            _sharedFiles.clear();
            _sharedFiles.addAll(value);
            log(_sharedFiles.map((f) => f.toMap()).toString());
            Future.delayed(const Duration(milliseconds: 500), () {
              _showReceivingDialog().then((_) async {
                ReceiveSharingIntent.instance.reset();
              });
            });
          });
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _loadThemeFromHive();
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

  Future<void> _showReceivingDialog() async {
    if (_sharedFiles.isNotEmpty) {
      _showSavingBottomSheet(_sharedFiles.map((e) => e.path).toList());
      _sharedFiles.clear();
    }
  }

  Future<void> _showSavingBottomSheet(List<String> files) async {
    UiUtils.showFlushBar(context, msg: "Received contents!");
    GlobalNav.withContextAsync<bool>((context) async {
      final pushRes = await Navigator.of(context).push(
        PageAnimation.pageRouteBuilder(
          MoveOrStoreContentBottomSheet.store(files: files),
          type: TransitionType.rightToLeftWithFade,
        ),
      );
      if (pushRes is bool) return pushRes;
      return false;
    }).then((res) {
      if (res == true) GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Saved contents"));
    });
  }
}





// class DummyApp extends ConsumerWidget {
//   const DummyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MaterialApp(home: Center(child: Text("This is a text"),));
//   }
// }