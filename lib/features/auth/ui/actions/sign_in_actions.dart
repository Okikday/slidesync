import 'dart:developer';
import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/auth/logic/services/user_auth/firebase_google_auth.dart';
import 'package:slidesync/features/auth/ui/screens/sign_in_view.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class SignInActions {
  Future<void> signInWithGoogle(BuildContext context) async {
    if (Platform.isWindows) {
      context.goNamed(Routes.home.name);
      return;
    }
    UiUtils.showCustomDialog(
      context,
      canPop: false,
      blurSigma: Offset(2, 2),
      transitionType: TransitionType.fade,
      child: const SigningInDialog(),
    );
    final auth = FirebaseGoogleAuth();
    final result = await auth.signInWithGoogle();

    Future.microtask(() => AppHiveData.instance.setData(key: HiveDataPathKey.hasOnboarded.name, value: true));

    if (result.isSuccess) {
      GlobalNav.withContext((c) => context.mounted ? context.pop() : c.pop());
      GlobalNav.withContext((context) async {
        context.goNamed(Routes.home.name);
        await 300.inMs.delay();
        // ignore: use_build_context_synchronously
        UiUtils.showFlushBar(context, msg: "Successfully signed in!", vibe: FlushbarVibe.success);
      });
    } else {
      GlobalNav.withContext((c) {
        context.mounted ? context.pop() : c.pop();
        UiUtils.showFlushBar(c, msg: result.message ?? "An error occured while signing in!", vibe: FlushbarVibe.error);
      });

      log("Error signing in... ${result.message}");
    }
  }
}
