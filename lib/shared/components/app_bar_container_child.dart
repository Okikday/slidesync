import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/styles/theme/app_theme_model.dart';

class AppBarContainerChild extends ConsumerWidget {
  const AppBarContainerChild(
    this.isDarkMode, {
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle,
    this.tooltipMessage,
    this.onBackButtonClicked,
    this.trailing,
    this.padding,
  });

  final bool isDarkMode;
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final String? tooltipMessage;
  final void Function()? onBackButtonClicked;
  final Widget? trailing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: tooltipMessage ?? title,
      child: Row(
        children: [
          AppBackButton(onPressed: onBackButtonClicked),
          ConstantSizing.rowSpacing(8),
          Expanded(
            child: (subtitle != null || (subtitle != null && subtitle!.isNotEmpty))
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2.5,
                    children: [
                      CustomText(
                        title,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        color: theme.onBackground,
                      ),
                      CustomText(
                        subtitle!,
                        fontSize: 12,
                        color: theme.background.lightenColor(theme.isDarkMode ? .4 : .6),
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle,
                      ),
                    ],
                  )
                : CustomText(
                    title,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                    color: theme.onBackground,
                  ),
          ),
          if (trailing == null) ConstantSizing.rowSpacingMedium,
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AppBackButton extends ConsumerWidget {
  final Color? backgroundColor;
  final void Function()? onPressed;
  const AppBackButton({super.key, this.backgroundColor, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return IconButton(
      color: theme.supportingText,
      onPressed: () {
        if (onPressed == null) {
          context.pop();
          return;
        } else {
          onPressed!();
        }
      },
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.supportingText),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(backgroundColor ?? theme.altBackgroundPrimary.withValues(alpha: 0.9)),
      ),
    );
  }
}
