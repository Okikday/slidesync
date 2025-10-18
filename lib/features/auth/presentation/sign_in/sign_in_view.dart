import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/auth/domain/services/user_auth/firebase_google_auth.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class SignInView extends ConsumerWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color primaryPurple = Color(0xFF7D19FF);
    final theme = ref;
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(theme.background, context.isDarkMode),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                Assets.images.signInViewBg,
                fit: BoxFit.cover,
                color: primaryPurple.withValues(alpha: 0.5),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 24,
              right: 24,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.onPrimary.withValues(alpha: 0.5)),
                    child: Image.asset(
                      "assets/logo/ic_foreground.png",
                      width: 64,
                      color: theme.primary,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  ConstantSizing.columnSpacing(kToolbarHeight),

                  CustomText(
                    "Sign in to SlideSync to Simplify your learning journey",
                    color: theme.onBackground,
                    textAlign: TextAlign.center,
                    fontStyle: FontStyle.italic,
                  ),
                  ConstantSizing.columnSpacing(kToolbarHeight),
                  CustomElevatedButton(
                    label: "Sign in",
                    textSize: 18,
                    pixelHeight: 60,
                    borderRadius: 100,
                    backgroundColor: primaryPurple,
                    textColor: theme.onPrimary,
                    onClick: () async {
                      if (Platform.isWindows) {
                        context.goNamed(Routes.home.name);
                        return;
                      }
                      UiUtils.showCustomDialog(
                        context,
                        canPop: false,
                        blurSigma: Offset(2, 2),
                        transitionType: TransitionType.fade,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: OrganicBackgroundEffect(
                                gradientColors: [theme.primaryColor, Color(0xFF008080)],
                                gradientOpacity: 0.1,
                              ),
                            ),
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                spacing: 12,
                                children: [
                                  LoadingLogo(color: theme.primary, size: 120, rotate: false),
                                  CustomText(
                                    "Signing you in...Just a moment",
                                    color: theme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                      final auth = FirebaseGoogleAuth();
                      final result = await auth.signInWithGoogle();
                      // if (context.mounted) {
                      //   context.pop();
                      // }

                      if (result.isSuccess && context.mounted) {
                        context.goNamed(Routes.home.name);
                        UiUtils.showFlushBar(context, msg: "Successfully signed in!");
                      } else {
                        if (context.mounted) {
                          context.pop();
                        } else {
                          GlobalNav.withContext((c) => c.pop());
                        }
                        if (context.mounted) UiUtils.showFlushBar(context, msg: "An error occured while signing in!");
                        log("Error signing in... ${result.message}");
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
