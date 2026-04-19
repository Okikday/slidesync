import 'package:go_router/go_router.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/auth/ui/screens/onboarding_1.dart';
import 'package:slidesync/features/auth/ui/screens/welcome_view.dart';
import 'package:slidesync/routes/transition.dart';

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
