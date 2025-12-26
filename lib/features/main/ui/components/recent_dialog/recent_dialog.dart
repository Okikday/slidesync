import 'dart:convert';
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/features/main/ui/actions/home/recent_dialog_actions.dart';
import 'package:slidesync/features/main/ui/components/recent_dialog/recent_dialog_selection_options.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class RecentDialog extends ConsumerStatefulWidget {
  final ContentTrack contentTrack;

  const RecentDialog({super.key, required this.contentTrack});

  @override
  ConsumerState createState() => _RecentDialogState();
}

class _RecentDialogState extends ConsumerState<RecentDialog> with RecentDialogActions {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    var divider = Divider(color: theme.onSurface.withAlpha(20), height: 0);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ColoredBox(
        color: Colors.transparent,
        child: Center(
          child:
              Container(
                clipBehavior: Clip.hardEdge,
                margin: EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: context.deviceHeight > context.deviceWidth ? 0 : 32,
                ),

                constraints: BoxConstraints(maxHeight: 320, maxWidth: 320),
                decoration: BoxDecoration(
                  color: theme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.surface.withValues(alpha: 0.95)),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2, tileMode: TileMode.decal),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        ConstantSizing.columnSpacing(24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                clipBehavior: Clip.hardEdge,
                                margin: EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  color: theme.onSurface.withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: BuildImagePathWidget(
                                  fileDetails: FileDetails(
                                    filePath: jsonDecode(widget.contentTrack.metadataJson)['previewPath'] ?? '',
                                  ),
                                  fallbackWidget: Icon(Iconsax.document_1, size: 26, color: ref.onBackground),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    BuildButton(
                                      iconData: null,
                                      backgroundColor: theme.adjustBgAndSecondaryWithLerp,
                                      shape: CircleBorder(),
                                      // contentPadding: EdgeInsets.all(12),
                                      onTap: () => onAddToBookmark(widget.contentTrack.contentId),
                                      child: Icon(Iconsax.star_copy, size: 26, color: theme.supportingText),
                                    ),
                                    BuildButton(
                                      iconData: null,
                                      backgroundColor: theme.adjustBgAndSecondaryWithLerp,
                                      shape: const CircleBorder(),
                                      onTap: () {},
                                      child: Icon(Iconsax.note_add_copy, size: 26, color: theme.supportingText),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        ConstantSizing.columnSpacingLarge,

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0, right: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  widget.contentTrack.title ?? "No title",
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onBackground,
                                ),
                                ConstantSizing.columnSpacingSmall,
                                SizedBox(
                                  height: 16,
                                  child: CustomText(
                                    widget.contentTrack.description ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 12.0,
                                    color: theme.supportingText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (widget.contentTrack.description != null) ConstantSizing.columnSpacingSmall,

                        if (widget.contentTrack.description != null)
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: divider),

                        if (widget.contentTrack.description != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24, top: 8.0, right: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    "Description",
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: theme.onBackground,
                                  ),
                                  ConstantSizing.columnSpacingSmall,
                                  CustomText(
                                    widget.contentTrack.description!
                                        .substring(0, widget.contentTrack.description!.length.clamp(0, 128))
                                        .padRight(3, "."),
                                    fontSize: 13,
                                    color: theme.supportingText,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ConstantSizing.columnSpacingMedium,

                        RecentDialogSelectionOptions(contentTrack: widget.contentTrack, divider: divider),

                        ConstantSizing.columnSpacing(24),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn().scaleXY(
                begin: 0.4,
                end: 1,
                duration: Duration(milliseconds: 800),
                curve: CustomCurves.bouncySpring,
                alignment: Alignment.bottomCenter,
              ),
        ),
      ),
    );
  }
}
