import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:slidesync/shared/assets/strings/icon_strings.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class EmptyCollectionsView extends ConsumerWidget {
  final void Function()? onClickAddCollection;
  const EmptyCollectionsView({super.key, this.onClickAddCollection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400,
        
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstantSizing.columnSpacing(20),
              SizedBox.square(
                dimension: context.deviceWidth * 0.5,
                child: LottieBuilder.asset(IconStrings.instance.roundedPlayingFace, reverse: true),
              ),

              CustomText("Oops, can't find any collections", color: Colors.blueGrey),

              ConstantSizing.columnSpacingHuge,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomElevatedButton(
                  onClick: () {
                    if (onClickAddCollection != null) onClickAddCollection!();
                  },
                  backgroundColor: ref.theme.primaryColor,
                  borderRadius: 12,
                  pixelHeight: 44,
                  label: "Add a new collection",
                  textSize: 15,
                  textColor: ref.theme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
