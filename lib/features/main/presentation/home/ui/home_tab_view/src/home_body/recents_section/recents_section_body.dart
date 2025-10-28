import 'dart:convert';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/main/presentation/home/actions/recent_dialog_actions.dart';
import 'package:slidesync/features/main/presentation/home/logic/home_provider.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_body/recents_section/recent_dialog.dart';
import 'package:slidesync/features/share/presentation/actions/share_content_actions.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

import 'recent_list_tile.dart';

class RecentsSectionBody extends ConsumerWidget {
  const RecentsSectionBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final AsyncValue<List<ContentTrack>> asyncProgressTrackValues = ref.watch(
      HomeProvider.recentContentsTrackProvider(10),
    );
    final rda = RecentDialogActions();
    return asyncProgressTrackValues.when(
      data: (data) {
        if (data.isEmpty) {
          return const SliverToBoxAdapter(child: RecommendedSection());
        }
        return SliverPadding(
          padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + context.bottomPadding),
          sliver: SliverList.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final content = data[index];
              final previewPath = jsonDecode(content.metadataJson)['previewPath'];
              return RecentListTile(
                dataModel: RecentListTileModel(
                  title: content.title ?? "No title",
                  subtitle: content.pages.isEmpty ? "Unknown" : "Page ${content.pages.last}",
                  // extraContent: DummySlides.dummySlides[index]['extraContent'] as String? ?? "",
                  previewPath: previewPath,
                  progressLevel: ProgressLevel.neutral,
                  isStarred: false,
                  progress: content.progress?.clamp(0, 1.0),
                  onTapTile: () async {
                    await rda.onContinueReading(context, content.contentId);
                  },
                  onLongTapTile: () {
                    UiUtils.showCustomDialog(
                      context,
                      canPop: true,
                      transitionType: TransitionType.cupertinoDialog,
                      barrierColor: Colors.black.withValues(alpha: 0.6),
                      transitionDuration: Durations.short4,
                      reverseTransitionDuration: Durations.short4,
                      child: RecentDialog(
                        recentDialogModel: RecentDialogModel(
                          contentId: content.contentId,
                          imagePreview: BuildImagePathWidget(
                            fileDetails: FileDetails(filePath: previewPath ?? ''),
                            fallbackWidget: Icon(Iconsax.document_1, size: 26, color: ref.onBackground),
                          ),
                          isStarred: false,
                          title: content.title ?? "No title",
                          description: content.description ?? "No description",
                          onContinueReading: () async {
                            await rda.onContinueReading(context, content.contentId);
                          },
                          onShare: () async {
                            ShareContentActions.shareFileContent(context, content.contentId);
                          },
                          onDelete: () async {
                            await rda.onRemoveFromRecents(context, content);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      error: (e, st) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Icon(Icons.error_rounded, size: 64, color: theme.primary),
                CustomText("Oops, we couldn't load up your recent reads", color: theme.onBackground),
              ],
            ),
          ),
        );
      },
      loading: () {
        return SliverToBoxAdapter(child: LoadingRecentsSection());
      },
    );
  }
}

class LoadingRecentsSection extends ConsumerWidget {
  const LoadingRecentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          LoadingLogo(color: ref.primary, rotate: false, size: context.deviceWidth * 0.4),
          CustomText(
            "Looking around for your recents...Where could they be?",
            color: ref.onBackground,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RecommendedSection extends ConsumerStatefulWidget {
  const RecommendedSection({super.key});

  @override
  ConsumerState<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends ConsumerState<RecommendedSection> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: CustomText("Recommended", fontWeight: FontWeight.bold, fontSize: 16, color: theme.onBackground),
          ),
          Center(
            child: SizedBox.square(
              dimension: 100,
              child: LottieBuilder.asset(Assets.icons.roundedPlayingFace, reverse: true),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: CustomText(
                  "No Recommendations.\nTry reading something from library ↷",
                  color: theme.onBackground.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: 10,
          //     scrollDirection: Axis.horizontal,
          //     shrinkWrap: true,
          //     padding: EdgeInsets.symmetric(horizontal: 16),
          //     itemBuilder: (context, index) {
          //       return SizedBox.square(
          //         dimension: 180,
          //         child: Stack(
          //           fit: StackFit.expand,
          //           children: [
          //             Positioned(
          //               top: 0,
          //               bottom: 0,
          //               left: 12,
          //               right: 12,
          //               child: Container(
          //                 width: 180,
          //                 height: 180,
          //                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //                 margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
          //                 decoration: BoxDecoration(
          //                   color: theme.surface.withValues(alpha: 0.6),
          //                   borderRadius: BorderRadius.circular(32),
          //                 ),
          //               ),
          //             ),
          //             Positioned.fill(
          //               bottom: 12,
          //               child: Container(
          //                 width: 180,
          //                 height: 180,
          //                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //                 margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
          //                 decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(32)),
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     CircleAvatar(radius: 20, backgroundColor: theme.surface.lightenColor(0.5)),
          //                     Padding(
          //                       padding: const EdgeInsets.only(bottom: 8),
          //                       child: CustomText(
          //                         "Suggested $index",
          //                         fontWeight: FontWeight.bold,
          //                         color: theme.onSurface,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
