import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';

class MoreSection extends ConsumerWidget {
  const MoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = ref;
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 12),
        children: [
          MoreSectionOption(title: "Timetable", iconData: Iconsax.heart_copy),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: MoreSectionOption(title: "Tasks", iconData: Iconsax.menu_copy),
          ),
        ],
      ),
    );
  }
}

class MoreSectionOption extends ConsumerWidget {
  final String title;
  final IconData iconData;
  const MoreSectionOption({super.key, required this.title, required this.iconData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ScaleClickWrapper(
      borderRadius: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(36),
          border: Border.fromBorderSide(BorderSide(color: theme.backgroundSupportingText.withAlpha(10))),
          image: DecorationImage(
            image: Assets.images.zigzagWavy.asImageProvider,
            fit: BoxFit.cover,
            opacity: 0.01,
            colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 8.0,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.background,
                child: Icon(iconData, color: theme.supportingText),
              ),
              CustomText(title, color: theme.supportingText, fontSize: 13, fontWeight: FontWeight.bold),
            ],
          ),
        ),
      ),
    );
  }
}
