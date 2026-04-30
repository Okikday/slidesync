// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';

import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

enum ProgressLevel { neutral, warning, danger, success }

class RecentListTile extends ConsumerWidget {
  final RecentListTileModel data;
  const RecentListTile({super.key, required this.data});

  Color _resolveLevelColor(WidgetRef ref, ProgressLevel level) {
    return level == ProgressLevel.danger
        ? Colors.red
        : (level == ProgressLevel.warning
              ? Colors.orange
              : (level == ProgressLevel.success ? Colors.green : ref.primaryColor));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final contentTrack = data.contentTrack;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.onBackground.withAlpha(20))),
      ),

      child: InkWell(
        // backgroundColor: context.isDarkMode ? HSLColor.fromColor(ref.scaffoldBackgroundColor).withLightness(0.1).toColor() : HSLColor.fromColor(ref.scaffoldBackgroundColor).withLightness(0.9).toColor(),
        overlayColor: WidgetStatePropertyAll(theme.altBackgroundPrimary),
        onTap: () {
          if (data.onTapTile != null) data.onTapTile!();
        },
        onLongPress: () {
          if (data.onLongTapTile != null) data.onLongTapTile!();
        },
        onSecondaryTap: () {
          if (data.onLongTapTile != null) data.onLongTapTile!();
        },

        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  Badge(
                    backgroundColor: Colors.transparent,
                    isLabelVisible: data.isStarred,
                    label: CircleAvatar(
                      radius: 10.5,
                      backgroundColor: Color(0xff0e1d27),
                      child: Icon(Iconsax.star_1, size: 16, color: theme.primaryColor),
                    ),
                    offset: Offset(0, -2),
                    child: Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: ClipOval(
                        child: CustomElevatedButton(
                          onClick: () {
                            if (data.onLongTapTile != null) data.onLongTapTile!();
                          },
                          pixelHeight: 48,
                          pixelWidth: 48,
                          shape: CircleBorder(),
                          contentPadding: EdgeInsets.zero,
                          backgroundColor: theme.altBackgroundPrimary.withValues(alpha: 1),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(theme.background.withAlpha(40), BlendMode.color),
                            child: BuildImagePathWidget(
                              width: 48,
                              height: 48,
                              fileDetails: contentTrack.thumbnail,
                              fallbackWidget: Icon(
                                IconHelper.getContentTypeIconData(contentTrack.type),
                                size: 26,
                                color: ref.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // CustomElevatedButton(
                  //   pixelWidth: 40,
                  //   pixelHeight: 40,
                  //   contentPadding: EdgeInsets.zero,
                  //   shape: CircleBorder(),
                  //   backgroundColor: ref.surface,
                  //   overlayColor: ref.secondary.withAlpha(50),
                  //   child: CustomText(
                  //     "${((dataModel.progress ?? 0.0) * 100).truncate()}%",
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.bold,
                  //     color: theme.supportingText.withValues(alpha: 0.5),
                  //   ),
                  // ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: CircularProgressIndicator(
                        value: contentTrack.progress.clamp(.0, 1.0),
                        strokeCap: StrokeCap.round,
                        color: _resolveLevelColor(
                          ref,
                          contentTrack.progress == 1.0
                              ? ProgressLevel.success
                              : (contentTrack.progress >= 0.75 ? ProgressLevel.warning : ProgressLevel.neutral),
                        ),
                        backgroundColor: theme.altBackgroundSecondary.withValues(alpha: 0.4),
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                ],
              ),

              ConstantSizing.rowSpacingMedium,

              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4.0,
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 30),
                          child: CustomText(
                            contentTrack.title.isEmpty ? "No title" : contentTrack.title,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: theme.onBackground,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                      Flexible(
                        child: CustomText(
                          switch (contentTrack.type) {
                            ModuleContentType.document =>
                              contentTrack.pages.isEmpty ? "Start reading" : "Page ${contentTrack.pages.last}",
                            _ => contentTrack.description.isNotEmpty ? contentTrack.description : "",
                          },
                          fontSize: 12,
                          color: theme.supportingText.withValues(alpha: 0.8),
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ConstantSizing.rowSpacingMedium,

              Icon(
                Iconsax.arrow_right_3_copy,
                size: 24,
                fontWeight: FontWeight.bold,
                color: theme.supportingText.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentListTileModel {
  final ContentTrack contentTrack;
  final bool isStarred;
  final void Function()? onTapTile;
  final void Function()? onLongTapTile;

  RecentListTileModel({required this.contentTrack, required this.isStarred, this.onTapTile, this.onLongTapTile});

  @override
  bool operator ==(covariant RecentListTileModel other) {
    if (identical(this, other)) return true;

    return other.isStarred == isStarred && other.onTapTile == onTapTile && other.onLongTapTile == onLongTapTile;
  }

  @override
  int get hashCode => isStarred.hashCode ^ onTapTile.hashCode ^ onLongTapTile.hashCode;
}
