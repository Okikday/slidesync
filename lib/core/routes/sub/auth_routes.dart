import 'package:go_router/go_router.dart';
import 'package:slidesync/core/routes/routes_strings.dart';
import 'package:slidesync/features/auth/domain/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/auth/presentation/welcome_view/welcome_view.dart';

final class AuthRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
      path: RoutesStrings.authView,
      builder: (context, state) {
        return WelcomeView();
      },
      redirect: (context, state) async {
        final result = await UserDataFunctions().isUserSignedIn();
        if (result == false) {
          return RoutesStrings.authView;
        } else {
          return RoutesStrings.homeView;
        }
      },
    ),
  ];
}
