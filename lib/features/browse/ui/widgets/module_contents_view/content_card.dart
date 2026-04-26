import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroine/heroine.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/content_card_context_menu.dart';
import 'package:slidesync/features/browse/logic/src/contents/retrieve_content_uc.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';

import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/content_card_actions.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';
import 'package:slidesync/shared/widgets/progress_indicator/app_circular_loading_indicator.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ContentCard extends ConsumerStatefulWidget {
  const ContentCard({super.key, required this.content, this.select});

  final ModuleContent content;
  final ({bool isSelected, void Function(ModuleContent content) onSelect})? select;

  @override
  ConsumerState<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends ConsumerState<ContentCard> {
  late Stream<double> progressStream;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    progressStream = ContentTrackRepo.watchByContentId(
      widget.content.uid,
    ).map((c) => c?.progress ?? 0.0).asBroadcastStream();
  }

  @override
  void didUpdateWidget(covariant ContentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _initializeData();
      setState(() {});
    }
  }

  // void updateTapDownDetailsProvider(WidgetRef ref, Offset det) {
  //   CollectionMaterialsState.cardTapPositionDetails = det;
  // }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final content = widget.content;
    final isDarkMode = theme.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (widget.select == null) {
                ContentViewGateActions.redirectToViewer(ref, content);
              } else {
                widget.select?.onSelect(content);
              }
            },
            child: Heroine(
              tag: widget.content.uid,
              child: Container(
                // curve: CustomCurves.defaultIosSpring,
                // duration: Durations.extralong1,
                constraints: BoxConstraints(maxHeight: 400, maxWidth: 700),
                clipBehavior: Clip.antiAlias,
                decoration: _getCardDecoration(theme),
                child: Stack(
                  // clipBehavior: Clip.antiAlias,
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SizedBox.expand(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: ContentCardPreviewImage(content: content)
                                  .animate(
                                    key: ValueKey(content.uid),
                                    target: widget.select?.isSelected == true ? 0 : 1,
                                  )
                                  .fade(begin: isDarkMode ? 0.4 : 0.7, end: isDarkMode ? 0.6 : 1.0),
                            ),
                          ),
                        ),
                        StreamBuilder(
                          stream: progressStream,
                          builder: (context, asyncSnapshot) {
                            return LinearProgressIndicator(
                              value: asyncSnapshot.hasData && asyncSnapshot.data != null ? asyncSnapshot.data : 0.0,
                              color: theme.primaryColor,
                              backgroundColor: theme.background.lightenColor(isDarkMode ? 0.15 : 0.85).withAlpha(200),
                            );
                          },
                        ),

                        Container(
                          padding: EdgeInsets.fromLTRB(8, 8, 4, 8),
                          decoration: BoxDecoration(
                            color: theme.background.lightenColor(isDarkMode ? 0.15 : 0.85).withAlpha(200),
                            borderRadius: BorderRadius.only(
                              bottomLeft: const Radius.circular(16),
                              bottomRight: const Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2.5,
                                  children: [
                                    Flexible(child: ContentCardTitle(content: content)),
                                    StreamBuilder(
                                      stream: progressStream,
                                      builder: (context, asyncSnapshot) {
                                        final progress = asyncSnapshot.hasData && asyncSnapshot.data != null
                                            ? asyncSnapshot.data
                                            : 0.0;
                                        return CustomText(
                                          progress == 0.0
                                              ? "Start reading!"
                                              : progress == 1.0
                                              ? "Completed!"
                                              : (progress != null && progress > .95)
                                              ? "Almost done!"
                                              : "${((progress?.clamp(0, 100) ?? 0.0) * 100.0).toInt()}% read",
                                          fontSize: 10,
                                          color: progress == 1.0 ? theme.primary : theme.supportingText,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // ContentCardPopUpMenuButton(content: content, previewDetailsFuture: previewDetailsFuture),
                              if (widget.select?.isSelected == null)
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),

                                    overlayColor: WidgetStatePropertyAll(theme.onSurface),
                                    onTap: () async {
                                      final collection = await ModuleRepo.getByUid(content.parentId);
                                      if (collection == null) return;
                                      GlobalNav.withContext(
                                        (c) => Navigator.push(
                                          context.mounted ? context : c,
                                          PageAnimation.pageRouteBuilder(
                                            ContentCardContextMenu(collection: collection, content: content),
                                            opaque: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox.square(dimension: 36, child: Icon(HugeIconsSolid.moreHorizontal)),
                                  ),
                                )
                              else
                                () {
                                  return Icon(
                                    widget.select?.isSelected == true ? Iconsax.tick_circle : Icons.circle,
                                    color: widget.select?.isSelected == true
                                        ? theme.primary
                                        : theme.onPrimary.withAlpha(100),
                                    size: 24,
                                  );
                                }(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ContentTypeBadge(content: content),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _getCardDecoration(WidgetRef theme) {
    final isDarkMode = theme.isDarkMode;
    return BoxDecoration(
      color: theme.background.lightenColor(isDarkMode ? 0.1 : 0.9),
      borderRadius: BorderRadius.circular(16),
      border: Border.fromBorderSide(
        BorderSide(
          color: widget.select?.isSelected == true ? theme.altBackgroundPrimary : theme.onBackground.withAlpha(40),
        ),
      ),
      boxShadow: _getCardShadow(isDarkMode),
    );
  }

  List<BoxShadow> _getCardShadow(bool isDarkMode) {
    return isDarkMode
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.04),
              offset: Offset(0, 6),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ];
  }
}

class ContentCardTitle extends ConsumerStatefulWidget {
  const ContentCardTitle({super.key, required this.content});

  final ModuleContent content;

  @override
  ConsumerState<ContentCardTitle> createState() => _ContentCardTitleState();
}

class _ContentCardTitleState extends ConsumerState<ContentCardTitle> {
  late Future<PreviewLinkDetails?>? previewDetailsFuture = widget.content.type == ModuleContentType.link
      ? previewDetailsFuture = RetriveContentUc.getLinkPreviewData(widget.content.path.url)
      : null;

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    return FutureBuilder(
      future: previewDetailsFuture,
      builder: (context, asyncSnapshot) {
        final resolveUrl =
            widget.content.type == ModuleContentType.link && widget.content.title.toLowerCase() == "unknown"
            ? widget.content.path.url
            : widget.content.title;
        final resolveTitle = previewDetailsFuture == null
            ? widget.content.title
            : (asyncSnapshot.hasData && asyncSnapshot.data != null
                  ? (asyncSnapshot.data?.title ?? resolveUrl)
                  : resolveUrl);
        return Tooltip(
          showDuration: 4.inSeconds,
          message: resolveTitle,
          triggerMode: TooltipTriggerMode.tap,
          child: CustomText(
            resolveTitle ?? "Unknown",
            color: theme.onBackground,
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

class ContentCardPreviewImage extends StatefulWidget {
  const ContentCardPreviewImage({super.key, required this.content});

  final ModuleContent content;

  @override
  State<ContentCardPreviewImage> createState() => _ContentCardPreviewImageState();
}

class _ContentCardPreviewImageState extends State<ContentCardPreviewImage> {
  late final previewDetailsFuture = widget.content.type == ModuleContentType.link
      ? RetriveContentUc.getLinkPreviewData(widget.content.path.url)
      : null;

  @override
  Widget build(BuildContext context) {
    if (previewDetailsFuture == null) {
      return ImageFiltered(
        imageFilter: ColorFilter.mode(Colors.black.withAlpha(10), BlendMode.color),
        child: BuildImagePathWidget(
          fileDetails: widget.content.type == ModuleContentType.link
              ? FilePath(url: widget.content.previewPath)
              : FilePath(local: widget.content.previewPath),
          fit: BoxFit.cover,
          fallbackWidget: Icon(IconHelper.getContentTypeIconData(widget.content.type, false), size: 36),
        ),
      );
    }
    return FutureBuilder(
      future: previewDetailsFuture,
      builder: (context, dataSnapshot) {
        if (dataSnapshot.data != null && dataSnapshot.hasData) {
          final previewUrl = dataSnapshot.data!.previewUrl;
          return ImageFiltered(
            imageFilter: ColorFilter.mode(Colors.black.withAlpha(10), BlendMode.color),
            child: BuildImagePathWidget(
              fileDetails: previewUrl != null ? FilePath(url: previewUrl) : FilePath(),
              fit: BoxFit.cover,
              fallbackWidget: Icon(IconHelper.getContentTypeIconData(widget.content.type, false), size: 36),
            ),
          );
        } else if (dataSnapshot.hasError) {
          return BuildImagePathWidget(
            fileDetails: FilePath(),
            fallbackWidget: Icon(IconHelper.getContentTypeIconData(widget.content.type, false), size: 36),
          );
        } else {
          return const AppCircularLoadingIndicator();
        }
      },
    );
  }
}

class ContentTypeBadge extends ConsumerWidget {
  const ContentTypeBadge({super.key, required this.content});

  final ModuleContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Positioned(
      top: 8,
      right: 8,
      child: Builder(
        builder: (context) {
          final res = ContentCardActions.resolveExtension(content);
          if (res.isEmpty) return const SizedBox();
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: theme.altBackgroundSecondary.withAlpha(200),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: CustomText(res, color: theme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
