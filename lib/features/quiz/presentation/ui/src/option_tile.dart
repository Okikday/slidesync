import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class OptionTile extends ConsumerWidget {
  final String optionLetter;
  final String optionText;
  final bool isSelected;
  final bool isCorrect;
  final bool showCorrectness;
  final bool isMultiple;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.optionLetter,
    required this.optionText,
    required this.isSelected,
    required this.isCorrect,
    required this.showCorrectness,
    required this.isMultiple,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    Color borderColor = theme.onSurface.withValues(alpha: 0.2);
    Color backgroundColor = theme.surface;
    Color textColor = theme.onSurface;

    if (showCorrectness) {
      if (isCorrect) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
      }
    } else if (isSelected) {
      borderColor = theme.primary;
      backgroundColor = theme.primary.withValues(alpha: 0.1);
    }

    return InkWell(
      onTap: showCorrectness ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: isMultiple ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isMultiple ? BorderRadius.circular(6) : null,
                border: Border.all(color: borderColor, width: 2),
                color: isSelected ? borderColor : Colors.transparent,
              ),
              child: Center(
                child: isSelected
                    ? Icon(
                        isMultiple ? Icons.check : Icons.circle,
                        size: 16,
                        color: showCorrectness ? (isCorrect ? Colors.white : Colors.white) : theme.onPrimary,
                      )
                    : Text(
                        optionLetter,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MarkdownWidget(
                data: optionText,
                config: MarkdownConfig(
                  configs: [
                    PConfig(
                      textStyle: TextStyle(color: textColor, fontSize: 14, fontFamily: theme.fontFamily),
                    ),
                  ],
                ),
              ),
            ),
            if (showCorrectness && isCorrect) Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (showCorrectness && isSelected && !isCorrect) Icon(Icons.cancel, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}
