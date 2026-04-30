import 'dart:developer';
import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:heroine/heroine.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/add_link_actions.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/content_card_context_menu.dart';
import 'package:slidesync/features/browse/logic/src/contents/retrieve_content_uc.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';

import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/features/browse/ui/actions/module_contents/content_card_actions.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/helpers/icon_helper.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

final _refreshedLinksNotifier = NotifierProvider.autoDispose.family(
  (String collectionId) => ImpliedNotifier<Set<int>>({}),
);
final _progressStreamNotifier = StreamNotifierProvider.autoDispose.family(
  (int contentId) => StreamedNotifier(() => ContentTrackRepo.watchById(contentId).map((c) => c?.progress ?? 0.0)),
);
typedef ContentCardSelectRecord = ({bool isSelected, void Function(ModuleContent content) onSelect});

class ContentCard extends ConsumerWidget {
  const ContentCard({super.key, required this.content, this.select});

  final ModuleContent content;
  final ContentCardSelectRecord? select;

  static NotifierProvider<ImpliedNotifier, Set<int>> refreshedLinksNotifier(String collectionId) =>
      _refreshedLinksNotifier(collectionId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () =>
                select == null ? ContentViewGateActions.redirectToViewer(ref, content) : select?.onSelect(content),
            child: _CardOuterShell(content: content, select: select),
          ),
        ),
      ],
    );
  }
}

class _CardOuterShell extends ConsumerWidget {
  const _CardOuterShell({required this.content, required this.select});

  final ModuleContent content;
  final ContentCardSelectRecord? select;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Heroine(
      tag: content.uid,
      flightShuttleBuilder: const FlipShuttleBuilder(),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 700),
          clipBehavior: Clip.antiAlias,
          decoration: _getCardDecoration(theme),
          child: _CardStack(content: content, select: select),
        ),
      ),
    );
  }

  BoxDecoration _getCardDecoration(WidgetRef theme) {
    final shadow = select?.isSelected == true
        ? theme.shadow
        : (theme.shadow.withValues(alpha: theme.isDarkMode ? 0.8 : 0.4));
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.fromBorderSide(
        BorderSide(color: theme.outline.withValues(alpha: select?.isSelected == true ? 1 : 0.8)),
      ),
      boxShadow: [
        BoxShadow(color: shadow, offset: const Offset(0, 1), blurRadius: 3, spreadRadius: 0),
        BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 6, spreadRadius: 0),
      ],
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({required this.content, required this.select});

  final ModuleContent content;
  final ContentCardSelectRecord? select;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // clipBehavior: Clip.antiAlias,
      fit: StackFit.expand,
      children: [
        _StackedBelow(content: content, select: select),
        ContentTypeBadge(content: content),
      ],
    );
  }
}

class _StackedBelow extends ConsumerStatefulWidget {
  const _StackedBelow({required this.content, required this.select});

  final ModuleContent content;
  final ContentCardSelectRecord? select;

  @override
  ConsumerState<_StackedBelow> createState() => _StackedBelowState();
}

class _StackedBelowState extends ConsumerState<_StackedBelow> {
  late bool isRefreshing = refreshable;
  late final progressProvider = _progressStreamNotifier(widget.content.id);
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() =>
      Future.microtask(() => isRefreshing ? _revalidateContentIfNeeded(ref, widget.content) : () {}).then(
        (_) => WidgetsBinding.instance.addPostFrameCallback(
          (_) => mounted && isRefreshing ? setState(() => isRefreshing = false) : () {},
        ),
      );

  @override
  void didUpdateWidget(covariant _StackedBelow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      isRefreshing = refreshable;
      _initializeData();
    }
  }

  bool get refreshable => widget.content.type == ModuleContentType.link;

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final isDarkMode = theme.isDarkMode;
    return Column(
      children: [
        Expanded(
          child: ContentCardPreviewImage(
            content: widget.content,
            isSelected: widget.select?.isSelected ?? false,
            isRefreshing: isRefreshing,
          ),
        ),

        AbsorberWatch(
          listenable: progressProvider,
          builder: (context, progressAsync, ref, _) => LinearProgressIndicator(
            value: progressAsync.value,
            color: theme.primaryColor,
            backgroundColor: theme.background.lightenColor(isDarkMode ? 0.15 : 0.85).withAlpha(200),
          ),
        ),

        _CardAboveFooter(
          isRefreshing: isRefreshing,
          progressProvider: progressProvider,
          content: widget.content,
          isSelected: widget.select?.isSelected,
        ),
      ],
    );
  }
}

class _CardAboveFooter extends ConsumerWidget {
  const _CardAboveFooter({
    required this.isRefreshing,
    required this.progressProvider,
    required this.content,
    required this.isSelected,
  });
  final ModuleContent content;
  final bool? isSelected;
  final bool isRefreshing;
  final StreamNotifierProvider<StreamedNotifier<double>, double> progressProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2.5,
              children: [
                Flexible(
                  child: Tooltip(
                    showDuration: 4.inSeconds,
                    message: content.title,
                    triggerMode: isSelected == null ? TooltipTriggerMode.tap : TooltipTriggerMode.longPress,
                    child: CustomText(
                      content.title,
                      color: theme.onBackground,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (isRefreshing)
                  CustomText("Loading link...", fontSize: 10, color: theme.primary)
                else
                  AbsorberWatch(
                    listenable: progressProvider,
                    builder: (context, progressAsync, ref, _) {
                      final progress = progressAsync.value;
                      return CustomText(
                        progress == null
                            ? "Loading progress..."
                            : progress == 0.0
                            ? "Start reading!"
                            : progress == 1.0
                            ? "Completed!"
                            : (progress > .95)
                            ? "Almost done!"
                            : "${((progress.clamp(0, 100)) * 100.0).toInt()}% read",
                        fontSize: 10,
                        color: progress == 1.0 ? theme.primary : theme.supportingText,
                      );
                    },
                  ),
              ],
            ),
          ),

          if (isSelected == null)
            Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              child: InkWell(
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
            Builder(
              builder: (context) {
                return Icon(
                  isSelected == true ? HugeIconsSolid.tick04 : HugeIconsSolid.circle,
                  color: isSelected == true ? theme.primary : theme.onPrimary.withAlpha(100),
                  size: 24,
                );
              },
            ),
        ],
      ),
    );
  }
}

class ContentCardPreviewImage extends ConsumerWidget {
  const ContentCardPreviewImage({
    super.key,
    required this.content,
    required this.isSelected,
    required this.isRefreshing,
  });

  final ModuleContent content;
  final bool isSelected;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isRefreshing) {
      final theme = ref;
      ColoredBox(
        color: theme.background.lightenColor(ref.isDarkMode ? 0.15 : 0.85).withAlpha(200),
        child: SizedBox.expand(),
      ).animate(onInit: (c) => c.repeat()).shimmer(color: theme.primary.withAlpha(20), duration: 1.5.seconds);
    }
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSelected ? 0.6 : 1.0,
          child: BuildImagePathWidget(
            fileDetails: content.metadata?.thumbnail ?? FilePath.empty(),
            fit: BoxFit.cover,
            fallbackWidget: Icon(IconHelper.getContentTypeIconData(content.type, false), size: 36),
          ),
        ),
      ),
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

Future<dynamic> _revalidateContentIfNeeded(WidgetRef ref, ModuleContent content) async => switch (content.type) {
  ModuleContentType.link => _refreshLinkIfNeeded(ref, content),
  _ => '',
};

Future<void> _refreshLinkIfNeeded(WidgetRef ref, ModuleContent content) async {
  if (!_shouldRefresh(content)) return;
  if (!ref.context.mounted) return;
  final refreshProvider = ref.read(ContentCard.refreshedLinksNotifier(content.parentId));
  if (refreshProvider.contains(content.id)) return;
  refreshProvider.add(content.id);

  final path = content.path;
  if (!path.containsUrlPath) return;

  log("Refreshing link content url ${content.path.url}");
  final previewLinkDetails = await RetriveContentUc.getLinkPreviewData(content.path.url);
  await AddLinkActions.onAddLinkContent(path.url!, parentId: content.parentId, details: previewLinkDetails);
}

bool _shouldRefresh(ModuleContent content) {
  log("Checking if content ${content.id} needs refreshing");
  return content.metadata?.thumbnail?.containsUrlPath != true ||
      content.lastModified.isBefore(DateTime.now().subtract(7.days)) ||
      content.path.url == content.title;
}
