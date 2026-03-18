import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';
import 'package:slidesync/shared/widgets/layout/app_text.dart';

class AppTextFormField extends ConsumerWidget {
  final Widget? title;
  final String? titleText;
  final TextStyle? titleStyle;
  final Widget? footer;
  final double? height;
  final void Function(PointerDownEvent)? onTapOutside;
  final TextInputType? keyboardType;
  final bool readOnly;
  final String obscuringCharacter;
  final bool obscureText;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final Widget Function(BuildContext, String)? errorBuilder;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final String? hintText;
  final String? errorText;
  final Color? borderColor;
  final EdgeInsets? contentPadding;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final bool autocorrect;
  final AutovalidateMode? autovalidateMode;
  final bool? selectAllOnFocus;
  final Widget? error;
  final TextStyle? errorStyle;
  final Color? fillColor;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  const AppTextFormField({
    super.key,
    this.titleText,
    this.height,
    this.onTapOutside,
    this.keyboardType,
    this.readOnly = false,
    this.obscuringCharacter = '*',
    this.obscureText = false,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.errorBuilder,
    this.errorStyle,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.borderColor,
    this.contentPadding,
    this.prefix,
    this.prefixIcon,
    this.suffix,
    this.titleStyle,
    this.enabled = true,
    this.controller,
    this.textInputAction,
    this.title,
    this.footer,
    this.autofillHints,
    this.autofocus = false,
    this.autocorrect = true,
    this.autovalidateMode,
    this.selectAllOnFocus,
    this.error,
    this.fillColor,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.theme;
    return titleText == null && title == null && footer == null
        ? SizedBox(height: height, width: double.infinity, child: _buildTextFormField(theme))
        : SizedBox(
            height: height,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                title ??
                    SizedBox(
                      width: double.infinity,
                      child: AppText(
                        titleText ?? '',
                        style: titleStyle ?? TextStyle(color: theme.primary, fontSize: 14),
                      ),
                    ),
                _buildTextFormField(theme),
                footer ?? const SizedBox.shrink(),
              ],
            ),
          );
  }

  TextFormField _buildTextFormField(AppTheme theme) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      onTapOutside: onTapOutside,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: validator,
      errorBuilder: errorBuilder,
      inputFormatters: inputFormatters,
      initialValue: initialValue,
      onChanged: onChanged,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      style: TextStyle(color: theme.primary, fontSize: 14),
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
      selectAllOnFocus: selectAllOnFocus,
      decoration: InputDecoration(
        fillColor: fillColor ?? Colors.white,
        hintText: hintText,
        errorText: errorText,
        error: error,
        hintStyle: TextStyle(color: theme.supportingText, fontSize: 14),
        errorStyle: errorStyle ?? TextStyle(color: theme.supportingText, fontSize: 11),
        contentPadding: contentPadding ?? const EdgeInsets.all(12),
        prefix: prefix,
        prefixIcon: prefixIcon,
        suffixIcon: suffix,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? theme.outline, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? theme.outline, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primary, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.errorColor, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.outline.withAlpha(40), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),

        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.errorColor.withAlpha(100), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cursorRadius: const Radius.circular(2),
      cursorColor: theme.primary,
      contextMenuBuilder: (context, editableTextState) =>
          _DefaultContextMenuBuilder(editableTextState: editableTextState),
    );
  }
}

/// The default context menu builder for [AppTextFormField]. This is used to ensure that the context menu is consistent across all platforms, and to provide a fallback for platforms that do
class _DefaultContextMenuBuilder extends ConsumerWidget {
  final EditableTextState editableTextState;
  const _DefaultContextMenuBuilder({required this.editableTextState});

  static String getButtonLabel(BuildContext context, ContextMenuButtonItem buttonItem) {
    if (buttonItem.label != null) {
      return buttonItem.label!;
    }

    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoTextSelectionToolbarButton.getButtonLabel(context, buttonItem);
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        assert(debugCheckHasMaterialLocalizations(context));
        final MaterialLocalizations localizations = MaterialLocalizations.of(context);
        return switch (buttonItem.type) {
          ContextMenuButtonType.cut => localizations.cutButtonLabel,
          ContextMenuButtonType.copy => localizations.copyButtonLabel,
          ContextMenuButtonType.paste => localizations.pasteButtonLabel,
          ContextMenuButtonType.selectAll => localizations.selectAllButtonLabel,
          ContextMenuButtonType.delete => localizations.deleteButtonTooltip.toUpperCase(),
          ContextMenuButtonType.lookUp => localizations.lookUpButtonLabel,
          ContextMenuButtonType.searchWeb => localizations.searchWebButtonLabel,
          ContextMenuButtonType.share => localizations.shareButtonLabel,
          ContextMenuButtonType.liveTextInput => localizations.scanTextButtonLabel,
          ContextMenuButtonType.custom => '',
        };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchors = editableTextState.contextMenuAnchors;
    final buttonItems = editableTextState.contextMenuButtonItems;
    return TextSelectionToolbar(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor == null ? anchors.primaryAnchor : anchors.secondaryAnchor!,
      toolbarBuilder: (context, child) => _TextSelectionToolbarContainer(primaryColor: ref.primary, child: child),
      children: [
        for (int i = 0; i < buttonItems.length; i++)
          TextSelectionToolbarTextButton(
            padding: TextSelectionToolbarTextButton.getPadding(i, buttonItems.length),
            onPressed: buttonItems[i].onPressed,
            alignment: AlignmentDirectional.centerStart,
            child: AppText(getButtonLabel(context, buttonItems[i]), fontWeight: FontWeight.w500),
          ),
      ],
    );
  }
}

class _TextSelectionToolbarContainer extends StatelessWidget {
  const _TextSelectionToolbarContainer({required this.primaryColor, required this.child});
  final Color primaryColor;
  final Widget child;

  Color _getColor(ColorScheme colorScheme) {
    final bool isDefaultSurface = switch (colorScheme.brightness) {
      Brightness.light => identical(ThemeData().colorScheme.surface, colorScheme.surface),
      Brightness.dark => identical(ThemeData.dark().colorScheme.surface, colorScheme.surface),
    };
    if (!isDefaultSurface) {
      return colorScheme.surface;
    }
    // return switch (colorScheme.brightness) {
    //   Brightness.light => AppColors.green50,
    //   Brightness.dark => A[],
    // };
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      // This value was eyeballed to match the native text selection menu on
      // a Pixel 6 emulator running Android API level 34.
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: _getColor(theme.colorScheme),
      elevation: 1.0,
      type: MaterialType.card,
      child: child,
    ).animate().scaleXY(duration: 400.inMs, curve: CustomCurves.defaultIosSpring, begin: 0.9).slideY(begin: -0.05);
  }
}
