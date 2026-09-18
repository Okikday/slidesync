import 'package:go_router/go_router.dart';
import 'package:slidesync/app/routes/routes.dart';
import 'package:slidesync/app/src/ui/splash_view.dart';
import 'package:slidesync/core/interop/src/receive_sharing_handler.dart';
import 'package:slidesync/core/storage/hive_data/hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';

final splashRoute = GoRoute(
  path: Routes.splash.path,
  builder: (context, state) => const SplashView(),
  redirect: (context, state) async {
    final isUserSignedIn = UserDataFunctions.me.isUserSignedIn();
    final hasOnboarded =
        await KVStore.me.getData(key: HiveDataKey.hasOnboarded.name) as bool?;
    String? destination;
    if (hasOnboarded == null && !isUserSignedIn) {
      destination = Routes.welcome.path;
    } else if (hasOnboarded == true || isUserSignedIn) {
      destination = Routes.home.path;
    } else {
      destination = Routes.auth.path;
    }

    if (destination == Routes.home.path) {
      ReceiveSharingHandler.instance.markAppReady();
    }
    return destination;
  },
);
