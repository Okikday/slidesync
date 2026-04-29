import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/study/ui/screens/link_viewer/src/drive_listing_controller.dart';
import 'package:slidesync/features/study/ui/screens/link_viewer/src/drive_listing_state.dart';
import 'package:slidesync/features/study/ui/screens/link_viewer/src/drive_listing_widgets.dart';
import 'package:slidesync/features/sync/providers/selection_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/dialogs/app_alert_dialog.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

class DriveListingView extends ConsumerStatefulWidget {
  final String? initialFolderId;
  final String collectionId;

  const DriveListingView({super.key, required this.collectionId, this.initialFolderId});

  @override
  ConsumerState<DriveListingView> createState() => _DriveListingViewState();
}

class _DriveListingViewState extends ConsumerState<DriveListingView> {
  String? _currentFolderLabel;
  final ScrollController _breadcrumbsScrollController = ScrollController();
  String _lastBreadcrumbPathKey = '';

  @override
  void initState() {
    super.initState();
    final initialFolderId = widget.initialFolderId;
    if (initialFolderId != null && initialFolderId.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(driveListingNavProvider.notifier).initializeRoot(initialFolderId, rootLabel: 'Root');
      });
    }
  }

  @override
  void dispose() {
    _breadcrumbsScrollController.dispose();
    super.dispose();
  }

  void _scheduleBreadcrumbsScrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_breadcrumbsScrollController.hasClients) return;
      _breadcrumbsScrollController.animateTo(
        _breadcrumbsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final controller = ref.watch(driveListingControllerProvider(widget.collectionId));

    final navState = ref.watch(driveListingNavProvider);
    final currentFolderId = navState.currentFolderId ?? widget.initialFolderId;
    final resourceAsync = ref.watch(driveResourceProvider(currentFolderId));
    final selection = ref.watch(driveSelectionProvider);

    return AppScaffold(
      title: 'Drive Listing',
      canPop: navState.navigationHistory.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && navState.navigationHistory.isNotEmpty) {
          _navigateBack();
        }
      },
      extendBodyBehindAppBar: true,
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          ref.isDarkMode,
          title: "Drive files",
          titleWidget: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: 'Browsing drive',
            child: CustomText(
              'Browsing drive',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.onSurfaceColor,
              overflow: TextOverflow.fade,
              maxLines: 2,
            ),
          ),
          // resourceAsync.when(
          //   data: (resource) => Tooltip(
          //     triggerMode: TooltipTriggerMode.tap,
          //     message: resource?.file?.name ?? 'Drive Files',
          //     child: CustomText(
          //       resource?.file?.name ?? 'Drive Files',
          //       fontSize: 16,
          //       fontWeight: FontWeight.w600,
          //       color: theme.onSurfaceColor,
          //       overflow: TextOverflow.fade,
          //       maxLines: 2,
          //     ),
          //   ),
          //   loading: () => CustomText('Loading...', fontSize: 18, color: theme.onSurfaceColor),
          //   error: (_, _) => CustomText('Drive Files', fontSize: 18, color: theme.onSurfaceColor),
          // ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selection.count > 0)
                IconButton(
                  icon: Icon(HugeIconsSolid.downloadCircle01, color: theme.primaryColor),
                  tooltip: 'Download Selected',
                  onPressed: resourceAsync.hasValue == true
                      ? () {
                          final selectedIdsSnapshot = Set<String>.from(selection.selectedIds);
                          ref.read(driveSelectionProvider.notifier).clearSelection();
                          controller.downloadSelectedItems(
                            resourceAsync.value!,
                            selectedIdsSnapshot: selectedIdsSnapshot,
                            selectionAlreadyCleared: true,
                          );
                        }
                      : null,
                ),
              if (resourceAsync.hasValue == true &&
                  selection.count == 0 &&
                  resourceAsync.value!.isFolder &&
                  resourceAsync.value!.children != null &&
                  resourceAsync.value!.children!.isNotEmpty)
                IconButton(
                  icon: Icon(HugeIconsSolid.fileDownload, color: theme.primaryColor),
                  tooltip: 'Import All',
                  onPressed: () {
                    CustomDialog.show(
                      context,
                      child: AppAlertDialog(
                        title: "Import all",
                        content: "Are you sure you want to import all files in this folder?",
                        onCancel: () => context.pop(),
                        onConfirm: () {
                          context.pop();
                          controller.importAll(resourceAsync.value!);
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      viewPadding: EdgeInsets.symmetric(horizontal: 16),
      body: currentFolderId == null
          ? const DriveEmptyState()
          : resourceAsync.when(
              data: (resource) {
                if (resource == null) {
                  return const DriveEmptyState();
                }

                if ((resource.file?.name ?? '').trim().isNotEmpty) {
                  _currentFolderLabel = resource.file!.name!.trim();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ref.read(driveListingNavProvider.notifier).setFolderLabel(currentFolderId, _currentFolderLabel!);
                  });
                }

                final breadcrumbs = [
                  for (final folderId in navState.navigationHistory)
                    (folderId: folderId, label: navState.folderLabels[folderId] ?? folderId),
                  (
                    folderId: currentFolderId,
                    label: (resource.file?.name ?? navState.folderLabels[currentFolderId] ?? 'Root'),
                  ),
                ];

                final breadcrumbPathKey = breadcrumbs.map((crumb) => crumb.folderId).join('/');
                if (breadcrumbPathKey != _lastBreadcrumbPathKey) {
                  _lastBreadcrumbPathKey = breadcrumbPathKey;
                  _scheduleBreadcrumbsScrollToEnd();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // ignore: unused_result
                    await ref.refresh(driveResourceProvider(currentFolderId).future);
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    slivers: [
                      const PinnedHeaderSliver(child: TopPadding(withHeight: kToolbarHeight + 4)),
                      if (selection.count <= 0)
                        PinnedHeaderSliver(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.background.lightenColor(theme.isDarkMode ? 0.08 : 0.92),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: theme.onBackground.withValues(alpha: 0.1)),
                              ),
                              child: SingleChildScrollView(
                                controller: _breadcrumbsScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (var index = 0; index < breadcrumbs.length; index++) ...[
                                      if (index > 0)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: CustomText(
                                            '>',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: theme.supportingText.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      TextButton(
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                        onPressed: index == breadcrumbs.length - 1
                                            ? null
                                            : () {
                                                ref.read(driveSelectionProvider.notifier).clearSelection();
                                                ref.read(driveListingNavProvider.notifier).jumpToBreadcrumb(index);
                                              },
                                        child: CustomText(
                                          breadcrumbs[index].label,
                                          fontSize: 12,
                                          fontWeight: index == breadcrumbs.length - 1
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: index == breadcrumbs.length - 1
                                              ? theme.primaryColor
                                              : theme.onBackground.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (selection.count > 0)
                        PinnedHeaderSliver(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.onBackground.withValues(alpha: 0.12)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: theme.primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomText(
                                      '${selection.count} selected',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.onBackground,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => ref.read(driveSelectionProvider.notifier).clearSelection(),
                                    child: const CustomText('Clear', fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      DriveContent(
                        resource: resource,
                        selection: selection,
                        onFolderNavigate: (folderId, folderName) => _navigateToFolder(folderId, folderName: folderName),
                        onFileOpen: (file) {
                          controller.showFileOpenOptions(file, onNavigateToFolder: _navigateToFolder);
                        },
                        onSelectToggle: (id) => ref.read(driveSelectionProvider.notifier).toggleSelect(id),
                      ),
                      const SliverToBoxAdapter(child: BottomPadding()),
                    ],
                  ),
                );
              },
              loading: () => const DriveLoadingState(),
              error: (error, _) =>
                  DriveErrorState(error: error, onRetry: () => ref.refresh(driveResourceProvider(currentFolderId))),
            ),
    );
  }

  void _navigateBack() {
    ref.read(driveListingNavProvider.notifier).navigateBack();
    ref.read(driveSelectionProvider.notifier).clearSelection();
  }

  void _navigateToFolder(String folderId, {String? folderName}) {
    ref
        .read(driveListingNavProvider.notifier)
        .navigateToFolder(folderId, folderName: folderName, currentFolderName: _currentFolderLabel);
    ref.read(driveSelectionProvider.notifier).clearSelection();
  }
}
