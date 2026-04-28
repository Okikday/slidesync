import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/features/main/ui/actions/home/recent_dialog_actions.dart';
import 'package:slidesync/features/main/ui/widgets/home_tab_view/home_body/recents_section/recent_dialog/recent_dialog_selection_options.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/formatter.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';
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
                          child: Container(
                            width: 100,
                            height: 100,
                            clipBehavior: Clip.hardEdge,
                            margin: EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: theme.onSurface.withAlpha(40),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: BuildImagePathWidget(
                              fileDetails: widget.contentTrack.thumbnail,
                              fallbackWidget: Icon(
                                IconHelper.getContentTypeIconData(widget.contentTrack.type),
                                size: 26,
                                color: ref.onBackground,
                              ),
                            ),
                          ),
                        ),

                        ConstantSizing.columnSpacingLarge,

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                            child: CustomText(
                              () {
                                final title = widget.contentTrack.title;
                                return title.isEmpty ? "No title" : title;
                              }(),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: theme.onBackground,
                            ),
                          ),
                        ),

                        if (widget.contentTrack.description.trim().isNotEmpty) ConstantSizing.columnSpacingSmall,

                        if (widget.contentTrack.description.trim().isNotEmpty)
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: divider),

                        if (widget.contentTrack.description.trim().isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8.0, right: 12.0),
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
                                    widget.contentTrack.description,
                                    fontSize: 13,
                                    color: theme.supportingText,
                                    maxLines: 5,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ConstantSizing.columnSpacingSmall,

                        divider,

                        ConstantSizing.columnSpacingSmall,

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CustomText(
                              "Last accessed ${widget.contentTrack.lastRead == null ? '' : Formatter.timeAgo(widget.contentTrack.lastRead!)}",
                              fontSize: 11,
                              color: theme.onBackground.withAlpha(150),
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
