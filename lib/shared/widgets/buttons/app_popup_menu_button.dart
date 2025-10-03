import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/shared/helpers/extensions/src/extension_on_app_theme.dart';

class PopupMenuAction {
  final String title;
  final IconData iconData;
  final Widget? icon;
  final VoidCallback onTap;
  final bool enabled;

  const PopupMenuAction({
    required this.title,
    required this.iconData,
    this.icon,
    required this.onTap,
    this.enabled = true,
  });
}

class AppPopupMenuButton extends ConsumerWidget {
  final List<PopupMenuAction> actions;
  final String? tooltip;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? menuPadding;
  final Clip? clipBehavior;
  final PopupMenuPosition? position;
  final Offset? offset;
  final bool enabled;
  final double? iconSize;
  final BoxConstraints? constraints;
  final Color? surfaceTintColor;
  final double? elevation;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final PopupMenuCanceled? onCanceled;
  final bool? enableFeedback;
  final Widget? child;
  final double? splashRadius;
  final EdgeInsetsGeometry? padding;
  final ButtonStyle? buttonStyle;

  const AppPopupMenuButton({
    super.key,
    required this.actions,
    this.tooltip = "Show options",
    this.icon,
    this.iconColor,
    this.menuPadding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.position,
    this.offset,
    this.enabled = true,
    this.iconSize,
    this.constraints,
    this.surfaceTintColor,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.onCanceled,
    this.enableFeedback,
    this.child,
    this.splashRadius,
    this.padding,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return PopupMenuTheme(
      data: PopupMenuThemeData(
        color: theme.background.withValues(alpha: 0.98),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
        shadowColor: theme.supportingText.withAlpha(20),
      ),
      child: PopupMenuButton<int>(
        tooltip: tooltip,
        style: buttonStyle,
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        menuPadding: menuPadding ?? EdgeInsets.zero,
        icon: child ?? Icon(icon ?? Iconsax.more_copy, color: iconColor ?? theme.supportingText, size: iconSize),
        enabled: enabled,
        position: position ?? PopupMenuPosition.under,
        offset: offset ?? Offset.zero,
        constraints: constraints,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shadowColor: shadowColor,
        shape: shape,
        onCanceled: onCanceled,
        enableFeedback: enableFeedback,
        splashRadius: splashRadius,
        padding: padding ?? EdgeInsets.all(8),
        onSelected: (value) {
          if (value < actions.length && actions[value].enabled) {
            actions[value].onTap();
          }
        },
        itemBuilder: (context) {
          return List<PopupMenuItem<int>>.generate(actions.length, (index) {
            final action = actions[index];
            return PopupMenuItem(
              value: index,
              enabled: action.enabled,
              child: PopupMenuItemChild(
                title: action.title,
                icon: action.icon,
                iconData: action.iconData,
                enabled: action.enabled,
              ),
            );
          });
        },
      ),
    );
  }
}

class PopupMenuItemChild extends ConsumerWidget {
  final IconData iconData;
  final Widget? icon;
  final String title;
  final bool enabled;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;

  const PopupMenuItemChild({
    super.key,
    required this.title,
    this.icon,
    required this.iconData,
    this.enabled = true,
    this.iconColor,
    this.textColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final effectiveIconColor = enabled
        ? (iconColor ?? theme.supportingText)
        : (iconColor ?? theme.supportingText).withValues(alpha: 0.38);
    final effectiveTextColor = enabled
        ? (textColor ?? theme.onBackground)
        : (textColor ?? theme.onBackground).withValues(alpha: 0.38);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        icon ?? Icon(iconData, color: effectiveIconColor, size: iconSize),
        CustomText(title, color: effectiveTextColor),
        ConstantSizing.rowSpacingSmall,
      ],
    );
  }
}

// Usage example:
/*
AppPopupMenuButton(
  actions: [
    PopupMenuAction(
      title: "Edit",
      iconData: Iconsax.edit,
      onTap: () => print("Edit tapped"),
    ),
    PopupMenuAction(
      title: "Delete",
      iconData: Iconsax.trash,
      onTap: () => print("Delete tapped"),
      enabled: false, // Disabled item
    ),
    PopupMenuAction(
      title: "Share",
      iconData: Iconsax.share,
      onTap: () => print("Share tapped"),
    ),
  ],
  tooltip: "More options",
  icon: Iconsax.menu,
  iconColor: Colors.blue,
  elevation: 8,
)
*/
