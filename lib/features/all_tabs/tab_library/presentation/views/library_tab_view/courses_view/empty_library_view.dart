import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/routes/routes.dart';

import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

// class SimpleActionModel {
//   final String title;
//   final void Function() onTap;

//   SimpleActionModel({required this.title, required this.onTap});
// }

class EmptyLibraryView extends ConsumerWidget {
  final bool asSliver;
  const EmptyLibraryView({super.key, this.asSliver = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final child = SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: context.deviceWidth * 0.5,
            child: LottieBuilder.asset(Assets.icons.roundedPlayingFace, reverse: true),
          ),

          ConstantSizing.columnSpacingExtraLarge,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomElevatedButton(
              onClick: () {
                context.pushNamed(Routes.createCourse.name);
              },
              backgroundColor: theme.altBackgroundPrimary,
              borderRadius: 12,
              pixelHeight: 44,
              label: "Create your course",
              textSize: 15,
              textColor: theme.onBackground,
            ),
          ),

          ConstantSizing.columnSpacingMedium,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomElevatedButton(
              backgroundColor: theme.primaryColor,
              borderRadius: 12,
              pixelHeight: 44,
              label: "Explore Courses",
              textSize: 15,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    if (asSliver) {
      return SliverToBoxAdapter(child: child);
    } else {
      return child;
    }
  }
}
