// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/data/models/file_details.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

enum ProgressLevel { neutral, warning, danger, success }

class RecentListTile extends ConsumerWidget {
  final RecentListTileModel dataModel;
  const RecentListTile({super.key, required this.dataModel});

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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.onBackground.withAlpha(20))),
      ),

      child: InkWell(
        // backgroundColor: context.isDarkMode ? HSLColor.fromColor(ref.scaffoldBackgroundColor).withLightness(0.1).toColor() : HSLColor.fromColor(ref.scaffoldBackgroundColor).withLightness(0.9).toColor(),
        overlayColor: WidgetStatePropertyAll(theme.altBackgroundPrimary),
        onTap: () {
          if (dataModel.onTapTile != null) dataModel.onTapTile!();
        },
        onLongPress: () {
          if (dataModel.onLongTapTile != null) dataModel.onLongTapTile!();
        },
        onSecondaryTap: () {
          if (dataModel.onLongTapTile != null) dataModel.onLongTapTile!();
        },

        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  Badge(
                    backgroundColor: Colors.transparent,
                    isLabelVisible: dataModel.isStarred,
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
                            if (dataModel.onLongTapTile != null) dataModel.onLongTapTile!();
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
                              fileDetails: FileDetails(filePath: dataModel.previewPath ?? ''),
                              fallbackWidget: Icon(Iconsax.document_1, size: 26, color: ref.primary),
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
                        value: dataModel.progress?.clamp(.0, 1.0) ?? .01,
                        strokeCap: StrokeCap.round,
                        color: _resolveLevelColor(ref, dataModel.progressLevel),
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
                            dataModel.title,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: theme.onBackground,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                      if (dataModel.subtitle.isNotEmpty)
                        Flexible(
                          child: CustomText(
                            dataModel.subtitle,
                            fontSize: 12,
                            color: theme.supportingText.withValues(alpha: 0.8),
                          ),
                        ),
                      if (dataModel.extraContent.isNotEmpty)
                        Flexible(child: CustomText(dataModel.extraContent, fontSize: 13)),
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
  final String title;
  final String subtitle;
  final String extraContent;
  final String? previewPath;
  final double? progress;
  final ProgressLevel progressLevel;
  final bool isStarred;
  final void Function()? onTapTile;
  final void Function()? onLongTapTile;

  RecentListTileModel({
    required this.title,
    required this.subtitle,
    this.extraContent = "",
    this.previewPath,
    this.progress,
    required this.progressLevel,
    required this.isStarred,
    this.onTapTile,
    this.onLongTapTile,
  });

  RecentListTileModel copyWith({
    String? title,
    String? subtitle,
    String? extraContent,
    String? previewPath,
    double? progress,
    ProgressLevel? progressLevel,
    bool? isStarred,
    void Function()? onTapTile,
    void Function()? onLongTapTile,
  }) {
    return RecentListTileModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      extraContent: extraContent ?? this.extraContent,
      previewPath: previewPath ?? this.previewPath,
      progress: progress ?? this.progress,
      progressLevel: progressLevel ?? this.progressLevel,
      isStarred: isStarred ?? this.isStarred,
      onTapTile: onTapTile ?? this.onTapTile,
      onLongTapTile: onLongTapTile ?? this.onLongTapTile,
    );
  }

  @override
  bool operator ==(covariant RecentListTileModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.subtitle == subtitle &&
        other.extraContent == extraContent &&
        other.previewPath == previewPath &&
        other.progress == progress &&
        other.progressLevel == progressLevel &&
        other.isStarred == isStarred &&
        other.onTapTile == onTapTile &&
        other.onLongTapTile == onLongTapTile;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        subtitle.hashCode ^
        extraContent.hashCode ^
        previewPath.hashCode ^
        progress.hashCode ^
        progressLevel.hashCode ^
        isStarred.hashCode ^
        onTapTile.hashCode ^
        onLongTapTile.hashCode;
  }
}
