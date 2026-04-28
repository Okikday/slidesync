import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/content_card.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';

class PreviewLinkTypeDialog extends ConsumerWidget {
  const PreviewLinkTypeDialog({super.key, required this.content});

  final ModuleContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return AppCustomizableDialog(
      size: Size(400, 500),
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, right: 16, bottom: 12),
        child: CustomText(content.title, fontSize: 16, fontWeight: FontWeight.bold, color: theme.onBackground),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: theme.onBackground.withAlpha(10), height: 0),

          ConstantSizing.columnSpacingMedium,

          _buildHeaderSection(theme),

          ConstantSizing.columnSpacingLarge,

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 16,
              children: [
                Flexible(
                  child: CustomElevatedButton(
                    onClick: () async {
                      final url = content.path.url;
                      if (url != null) {
                        await Clipboard.setData(ClipboardData(text: url));
                      }
                    },
                    pixelHeight: 44,
                    borderRadius: 44,

                    backgroundColor: theme.secondary.withValues(alpha: 0.2),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6.0,
                      children: [
                        Icon(Iconsax.link, color: theme.secondary, size: 20),
                        Flexible(child: CustomText("Copy link", color: theme.secondary)),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: CustomElevatedButton(
                    onClick: () {
                      context.pop();
                      ShareContentActions.shareContent(context, content.uid);
                    },
                    pixelHeight: 44,
                    borderRadius: 44,

                    backgroundColor: theme.primary.withValues(alpha: 0.2),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6.0,
                      children: [
                        Icon(Icons.share_outlined, color: theme.primary, size: 20),
                        Flexible(child: CustomText("Share", color: theme.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstantSizing.columnSpacingSmall,
        ],
      ),
    );
  }

  Widget _buildHeaderSection(WidgetRef theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        spacing: 12,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.altBackgroundPrimary,
              borderRadius: BorderRadius.circular(15),
              border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(60))),
            ),
            child: SizedBox.square(
              dimension: 60,
              child: SizedBox.expand(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Opacity(
                    opacity: 0.6,
                    child: ContentCardPreviewImage(content: content, isSelected: false, isRefreshing: false),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  CustomText(content.path.url ?? "Link error!", fontWeight: FontWeight.bold, color: theme.secondary),
                  Flexible(
                    child: Tooltip(
                      message: content.description.trim().isEmpty ? "No description" : content.description,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: 4.inSeconds,
                      child: CustomText(
                        content.description.trim().isEmpty ? "No description" : content.description,
                        color: theme.onBackground.withValues(alpha: .5),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
