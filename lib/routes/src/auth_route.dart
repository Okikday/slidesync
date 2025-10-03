import 'package:go_router/go_router.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/auth/presentation/auth_views/sign_in_view.dart';

final authRoute = GoRoute(name: Routes.auth.name, path: Routes.auth.path, builder: (context, state) => SignInView());
