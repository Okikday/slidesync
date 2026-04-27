import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({
    super.key,
    required this.data,
    this.onReadingBtnTapped,
    this.onShareTapped,
    this.isFirst,
    this.buttonText,
  });

  final ContentTrack data;
  final String? buttonText;
  final void Function()? onReadingBtnTapped;
  final void Function()? onShareTapped;

  final bool? isFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    // final previewPath = jsonDecode(data.metadataJson)['previewPath'];
    // final isPreviewPathValid = previewPath != null && previewPath is String;
    final title = data.title.isEmpty ? "Unknown material" : data.title;
    final description = data.description;
    final progressValue = data.progress;
    final completed = data.progress == 1.0;
    final isTypeLink = data.type == ModuleContentType.link;
    return Container(
      constraints: BoxConstraints(maxHeight: 160, maxWidth: 400),
      width: context.deviceWidth,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 12),
      // margin: EdgeInsets.only(left: isFirst  == null ? 8 : 12, right: isFirst == null ? 0 : (isFirst! ? 0 : 12)),
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.adjustBgAndPrimaryWithLerp,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(width: 2, color: theme.adjustBgAndPrimaryWithLerpExtra),
        image: DecorationImage(
          image:
              // previewPath != null && previewPath is String
              //     ? previewPath.asImageProvider
              //     :
              Assets.images.bookSparkleBg.asImageProvider,
          fit: BoxFit.cover,
          opacity: 0.05,
          colorFilter:
              // isPreviewPathValid
              //     ? ColorFilter.mode(theme.primaryColor.withValues(alpha: 0.05), BlendMode.difference)
              //     :
              ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: title,
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: 4.inSeconds,
                  child: CustomText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.onBackground,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          if (description.isNotEmpty) ConstantSizing.columnSpacingSmall,
          if (description.isNotEmpty)
            CustomText(
              description,
              fontSize: 12,
              color: theme.supportingText.withValues(alpha: 0.5),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),

          ConstantSizing.columnSpacingLarge,

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 10,
            children: [
              Expanded(
                child: ClipRSuperellipse(
                  borderRadius: BorderRadiusGeometry.circular(16),
                  child: CustomElevatedButton(
                    pixelHeight: 48,
                    elevation: 100,
                    borderRadius: 0,
                    overlayColor: ref.onPrimary.withAlpha(20),
                    backgroundColor: theme.primaryColor,
                    child: CustomText(
                      buttonText ??
                          (completed
                              ? "Go to next"
                              : isTypeLink
                              ? "Open link"
                              : "Continue reading"),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.onPrimary,
                    ),
                    onClick: () {
                      if (onReadingBtnTapped != null) onReadingBtnTapped!();
                    },
                  ),
                ),
              ),

              // ConstantSizing.rowSpacing(4),
              if (completed)
                Stack(
                  children: [
                    CustomElevatedButton(
                      pixelWidth: 46,
                      pixelHeight: 46,
                      contentPadding: EdgeInsets.zero,
                      shape: CircleBorder(),
                      backgroundColor: theme.background,
                      onClick: () {},
                      child: CustomText(
                        "${((progressValue.clamp(0, 100)) * 100.0).toInt()}%",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.onBackground,
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: CircularProgressIndicator(
                          value: ((progressValue.clamp(0, 100))).toDouble(),
                          strokeCap: StrokeCap.round,
                          color: theme.primaryColor,
                          backgroundColor: theme.altBackgroundSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              // CustomElevatedButton(
              //   pixelHeight: 48,
              //   pixelWidth: 48,
              //   borderRadius: 12,
              //   elevation: 10,
              //   overlayColor: Colors.white.withAlpha(50),
              //   backgroundColor: context.isDarkMode ? theme.primaryColor.withAlpha(160) : Colors.black,
              //   onClick: () {
              //     if (onShareTapped != null) onShareTapped!();
              //   },
              //   child: Icon(Icons.share_rounded, color: Colors.white),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  factory HomeDashboard.defaultConfig(
    BuildContext context,
    bool? hasAnyCourse,
    void Function() onEmptyReadingButtonTapped,
  ) {
    if (hasAnyCourse == null) {
      return HomeDashboard(
        data: ContentTrack.create(
          uid: "_",
          courseId: "_",
          title: "Looking around",
          type: ModuleContentType.unknown,
          progress: 0.0,
        ),
        buttonText: "",
        isFirst: true,
        onReadingBtnTapped: () async {},
      );
    }

    if (!hasAnyCourse) {
      return HomeDashboard(
        data: ContentTrack.create(
          uid: "_",
          courseId: "_",
          title: "Add a course",
          type: ModuleContentType.unknown,
          description: "Let's add a course to get you started!",
          progress: 0.0,
        ),

        buttonText: "Get started!",
        isFirst: true,
        onReadingBtnTapped: () async {
          log("Routing to create course page");
          context.pushNamed(Routes.createCourse.name);
        },
      );
    }

    return HomeDashboard(
      data: ContentTrack.create(
        uid: "_",
        courseId: "_",
        type: ModuleContentType.unknown,
        title: "Start reading",
        description: "You haven't started reading, get started!",
        progress: 0.0,
      ),
      buttonText: "Take me there!",
      isFirst: true,
      onReadingBtnTapped: onEmptyReadingButtonTapped,
    );
  }
}

// BoxDecoration _dashDecoratedBox(WidgetRef theme) {
//   return BoxDecoration(
//     color: theme.adjustBgAndPrimaryWithLerp,
//     borderRadius: BorderRadius.circular(18),
//     border: Border.all(width: 2, color: theme.adjustBgAndPrimaryWithLerpExtra),
//     image: DecorationImage(
//       image: Assets.images.bookSparkleBg.asImageProvider,
//       fit: BoxFit.cover,
//       opacity: 0.03,
//       colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
//     ),
//   );
// }
