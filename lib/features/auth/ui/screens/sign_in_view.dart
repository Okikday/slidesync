import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/features/ask_ai/ui/widgets/shimmery_gradient_background.dart';
import 'package:slidesync/features/auth/ui/actions/sign_in_actions.dart';

import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/core/assets/assets.gen.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
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
      child: AppScaffold(
        title: "",
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
              right: 0,
              child: SafeArea(
                child: TextButton(
                  onPressed: () {
                    Future.microtask(
                      () => AppHiveData.instance.setData(key: HiveDataPathKey.hasOnboarded.name, value: true),
                    );
                    context.goNamed(Routes.home.name);
                  },
                  child: CustomText("Skip", color: theme.onBackground, fontWeight: FontWeight.w700),
                ),
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
                      await SignInActions().signInWithGoogle(context);
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

class SigningInDialog extends ConsumerStatefulWidget {
  const SigningInDialog({super.key});

  @override
  ConsumerState<SigningInDialog> createState() => _SigningInDialogState();
}

class _SigningInDialogState extends ConsumerState<SigningInDialog> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: ShimmeryGradientBackground()),
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
    );
  }
}
