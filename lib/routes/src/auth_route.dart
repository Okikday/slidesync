import 'package:go_router/go_router.dart';
import 'package:slidesync/features/auth/ui/screens/sign_in_view.dart';
import 'package:slidesync/routes/routes.dart';

final authRoute = GoRoute(
  name: Routes.auth.name,
  path: Routes.auth.path,
  builder: (context, state) => const SignInView(),
);
