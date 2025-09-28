import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/styles/theme/app_theme_model.dart';

import 'shared/styles/theme/themes.dart';

final NotifierProvider<AppThemeProvider, AppThemeModel> appThemeProvider = NotifierProvider(AppThemeProvider.new);

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Future<void> _loadThemeFromHive() async {
    await Result.tryRunAsync(() async {
      final String? hiveTheme = (await AppHiveData.instance.getData(key: HiveDataPathKey.appTheme.name)) as String?;
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
  void initState() {
    super.initState();

    // if (RootIsolateToken.instance != null) {
    //   compute(FileUtils.deleteEmptyCoursesDirsInIsolate, {'rootIsolateToken': RootIsolateToken.instance});
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _loadThemeFromHive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;

    return MaterialApp.router(
      title: "SlideSync",
      routerConfig: RouteManager.mainRouter,
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