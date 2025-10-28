import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:slidesync/core/assets/assets.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class EmptyCollectionsView extends ConsumerWidget {
  final void Function()? onClickAddCollection;
  final bool showAddButton;
  const EmptyCollectionsView({super.key, this.onClickAddCollection, this.showAddButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Center(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            ConstantSizing.columnSpacing(40),
            SizedBox.square(
              dimension: context.deviceWidth * 0.5,
              child: LottieBuilder.asset(Assets.icons.roundedPlayingFace, reverse: true),
            ),

            Center(child: CustomText("Oops, can't find any collections", color: Colors.blueGrey)),

            if (showAddButton) ...[
              ConstantSizing.columnSpacingHuge,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomElevatedButton(
                  onClick: () {
                    if (onClickAddCollection != null) onClickAddCollection!();
                  },
                  backgroundColor: ref.primaryColor,
                  borderRadius: 12,
                  pixelHeight: 44,
                  label: "Add a new collection",
                  textSize: 15,
                  textColor: ref.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
