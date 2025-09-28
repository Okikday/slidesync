import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/app_router.dart';
import 'package:slidesync/core/routes/routes.dart';
import 'package:slidesync/features/auth/presentation/onboarding_views/onboarding_1.dart';
import 'package:slidesync/features/auth/presentation/welcome_view/welcome_view.dart';

final onboardingRoute = GoRoute(
  name: Routes.welcome.name,
  path: Routes.welcome.path,
  builder: (context, state) => const WelcomeView(),
  routes: [
    GoRoute(
      name: Routes.onboarding1.name,
      path: Routes.onboarding1.subPath,
      pageBuilder: (context, state) => defaultTransition(state.pageKey, child: Onboarding1()),
    ),
  ],
);
