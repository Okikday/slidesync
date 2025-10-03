import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_app_theme.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_color.dart';

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
    final theme = ref;
    final buttonPadding = 16.0;
    final btnDimension = 56.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        // color: context.isDarkMode ? Color.fromARGB(255, 52, 33, 79) : Color(0xFFDBF3FF),
        color: theme.background.lightenColor(theme.isDarkMode ? 0.1 : 0.9),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomElevatedButton(
            onClick: onTapTile,
            onLongClick: onLongPressTile,
            borderRadius: 12,

            contentPadding: EdgeInsets.all(buttonPadding),
            // backgroundColor: context.isDarkMode ? Color.fromARGB(255, 46, 29, 70) : Color(0xFFDBF3FF).withValues(alpha: 0.89),
            backgroundColor: theme.background.lightenColor(theme.isDarkMode ? .11 : .89),
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
                          color: ref.onBackground,
                          overflow: TextOverflow.fade,
                        ),
                        ConstantSizing.columnSpacing(4),
                        CustomText(subtitle, fontSize: 12, color: ref.supportingText),
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
