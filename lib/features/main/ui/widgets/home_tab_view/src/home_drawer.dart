import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        Scaffold.of(context).closeDrawer();
      },
      child: Drawer(
        backgroundColor: theme.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ConstantSizing.columnSpacing(kToolbarHeight + 24),
              FutureBuilder(
                future: UserDataFunctions().getUserDetails(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.hasData && asyncSnapshot.data != null && asyncSnapshot.data?.data != null) {
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.altBackgroundPrimary,
                      backgroundImage: CachedNetworkImageProvider(asyncSnapshot.data!.data!.photoURL!),
                    );
                  }
                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.altBackgroundSecondary,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LottieBuilder.asset(
                        "assets/icons/animated_jsons/experimental_loading.json",
                        animate: false,
                      ),
                    ),
                  );
                },
              ),

              ConstantSizing.columnSpacingMedium,
              FutureBuilder(
                future: UserDataFunctions().getUserDetails(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.hasData && asyncSnapshot.data != null && asyncSnapshot.data?.data != null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(asyncSnapshot.data!.data!.displayName, color: theme.onBackground),
                        ConstantSizing.columnSpacingSmall,
                        CustomText(asyncSnapshot.data!.data!.email, color: theme.supportingText.withValues(alpha: 0.6)),
                      ],
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText("Unknown User", color: theme.onBackground),
                      ConstantSizing.columnSpacingSmall,
                      CustomText("Not Signed in", color: theme.onBackground.withAlpha(100)),
                    ],
                  );
                },
              ),

              ConstantSizing.columnSpacingExtraLarge,

              // ListTile(
              //   tileColor: Colors.transparent,
              //   leading: Icon(Iconsax.profile_tick, color: theme.supportingText.withValues(alpha: 0.5)),
              //   title: CustomText("Profile", color: theme.onBackground),
              // ),
              ListTile(
                tileColor: Colors.transparent,
                leading: Icon(Iconsax.setting, color: theme.supportingText.withValues(alpha: 0.5)),
                title: CustomText("Settings", color: theme.onBackground),
                onTap: () {
                  context.pushNamed(Routes.settings.name);
                },
              ),
              // ListTile(
              //   tileColor: Colors.transparent,
              //   leading: Icon(Iconsax.pen_tool, color: theme.supportingText.withValues(alpha: 0.5)),
              //   title: CustomText("Tools", color: theme.onBackground),
              //   onTap: () {
              //     // Tools like Calculate gpa, Reading Metrics etc
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
