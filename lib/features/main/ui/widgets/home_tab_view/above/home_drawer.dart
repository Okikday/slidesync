import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/auth/ui/actions/sign_in_actions.dart';
import 'package:slidesync/app/routes/routes.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).custom;
    final data = UserDataFunctions.me.getUserDetails().data;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          Scaffold.of(context).closeDrawer(),
      child: Drawer(
        backgroundColor: theme.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ConstantSizing.columnSpacing(kToolbarHeight + 24),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Row(
                  children: [
                    ProfileAvatar(photoURL: data?.photoURL ?? ""),

                    ConstantSizing.rowSpacingMedium,
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          data?.displayName ?? "Guest User",
                          color: theme.onBackground,
                          overflow: TextOverflow.ellipsis,
                        ),
                        ConstantSizing.columnSpacingSmall,
                        data?.email != null
                            ? CustomText(
                                data!.email,
                                color: theme.supportingText.withValues(
                                  alpha: 0.6,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : CustomElevatedButton(
                                label: "Sign in",
                                backgroundColor: theme.primary,
                                textColor: theme.onPrimary,
                                pixelWidth: 80,
                                pixelHeight: 32,
                                borderRadius: 16,
                                onClick: () async {
                                  await SignInActions().signInWithGoogle(
                                    context,
                                  );
                                  if (context.mounted) {
                                    Scaffold.of(context).closeDrawer();
                                  }
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  ConstantSizing.columnSpacing(48),

                  // ListTile(
                  //   tileColor: Colors.transparent,
                  //   leading: Icon(Iconsax.profile_tick, color: theme.supportingText.withValues(alpha: 0.5)),
                  //   title: CustomText("Profile", color: theme.onBackground),
                  // ),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    tileColor: Colors.transparent,
                    leading: Icon(
                      HugeIconsSolid.settings01,
                      color: theme.supportingText.withValues(alpha: 0.5),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String photoURL;
  const ProfileAvatar({super.key, required this.photoURL});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).custom;

    return Builder(
      builder: (context) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.onSecondaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.supportingText.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: theme.altBackgroundPrimary,
            backgroundImage: CachedNetworkImageProvider(photoURL),
          ),
        );
      },
    );
  }
}
