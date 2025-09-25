import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/styles/colors.dart';

class ModifyingListTile extends ConsumerWidget {
  final Widget leading;
  final Widget? trailing;
  final String title;
  final String subtitle;
  final void Function()? onTapTile;
  final void Function()? onTapLeading;
  final void Function()? onLongPressTile;

  const ModifyingListTile({
    super.key,
    required this.leading,
    required this.trailing,
    required this.title,
    required this.subtitle,
    this.onTapTile,
    this.onTapLeading,
    this.onLongPressTile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonPadding = context.hPadding5;
    final btnDimension = context.defaultBtnDimension;
    final theme = ref.theme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        // color: context.isDarkMode ? Color.fromARGB(255, 52, 33, 79) : Color(0xFFDBF3FF),
        color: theme.bgLightenColor(),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomElevatedButton(
            onClick: onTapTile,
            onLongClick: onLongPressTile,
            borderRadius: 12,

            contentPadding: EdgeInsets.all(buttonPadding),
            // backgroundColor: context.isDarkMode ? Color.fromARGB(255, 46, 29, 70) : Color(0xFFDBF3FF).withValues(alpha: 0.89),
            backgroundColor: theme.bgLightenColor(.89, .11),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 120),
              child: Row(
                spacing: ConstantSizing.spaceMedium,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: theme.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox.square(dimension: btnDimension, child: leading),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          title,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: ref.theme.onBackground,
                          overflow: TextOverflow.fade,
                        ),
                        ConstantSizing.columnSpacing(4),
                        CustomText(subtitle, fontSize: 12, color: ref.theme.supportingText),
                      ],
                    ),
                  ),

                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
