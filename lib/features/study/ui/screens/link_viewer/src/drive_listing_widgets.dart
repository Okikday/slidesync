import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart' as drive_service;
import 'package:slidesync/features/sync/providers/entities/selection_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/scale_click_wrapper.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

class DriveContent extends ConsumerWidget {
  final drive_service.DriveResource resource;
  final SelectionState selection;
  final void Function(String folderId, String folderName) onFolderNavigate;
  final void Function(drive_service.DriveFile file) onFileOpen;
  final void Function(String id) onSelectToggle;

  const DriveContent({
    super.key,
    required this.resource,
    required this.selection,
    required this.onFolderNavigate,
    required this.onFileOpen,
    required this.onSelectToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (resource.isFolder) {
      if (resource.children?.isEmpty == true) {
        return const SliverFillRemaining(hasScrollBody: false, child: DriveEmptyFolderState());
      }

      return SliverList.builder(
        itemCount: resource.children?.length ?? 0,
        itemBuilder: (context, index) {
          final file = resource.children?[index];
          if (file == null) {
            return const SizedBox.shrink();
          }

          final isSelected = file.id != null && selection.isSelected(file.id!);
          final selectionMode = selection.count > 0;
          final isFolder = file.isFolderLike;

          return DriveFileCard(
            file: file,
            isSelected: isSelected,
            selectionMode: selectionMode,
            onLongPress: file.id != null ? () => onSelectToggle(file.id!) : null,
            onTap: () {
              if (selectionMode) {
                if (file.id != null) {
                  onSelectToggle(file.id!);
                }
                return;
              }

              if (isFolder) {
                final targetFolderId = file.navigationTargetId ?? file.id;
                if (targetFolderId != null) {
                  onFolderNavigate(targetFolderId, file.name ?? targetFolderId);
                }
                return;
              }

              onFileOpen(file);
            },
            onSelectTap: file.id != null ? () => onSelectToggle(file.id!) : null,
          );
        },
      );
    }

    final file = resource.file;
    if (file == null) {
      return const SliverFillRemaining(hasScrollBody: false, child: DriveEmptyState());
    }

    final isSelected = file.id != null && selection.isSelected(file.id!);
    final selectionMode = selection.count > 0;

    return SliverToBoxAdapter(
      child: DriveFileCard(
        file: file,
        isSelected: isSelected,
        selectionMode: selectionMode,
        onLongPress: file.id != null ? () => onSelectToggle(file.id!) : null,
        onTap: () {
          if (selectionMode) {
            if (file.id != null) {
              onSelectToggle(file.id!);
            }
          } else {
            onFileOpen(file);
          }
        },
        onSelectTap: file.id != null ? () => onSelectToggle(file.id!) : null,
      ),
    );
  }
}

class DriveFileCard extends ConsumerWidget {
  final drive_service.DriveFile file;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectTap;

  const DriveFileCard({
    super.key,
    required this.file,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    this.onLongPress,
    this.onSelectTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final isDarkMode = theme.isDarkMode;
    final isFolder = file.isFolderLike;

    return ScaleClickWrapper(
      borderRadius: 14,
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: Durations.medium1,
        curve: CustomCurves.defaultIosSpring,
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.background.lightenColor(isDarkMode ? 0.1 : 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.fromBorderSide(
            BorderSide(
              color: isSelected ? theme.primaryColor.withValues(alpha: 0.8) : theme.onBackground.withAlpha(24),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          boxShadow: isDarkMode
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), offset: const Offset(0, 1), blurRadius: 3)]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DriveFileThumbnail(file: file),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: file.name ?? 'Unnamed file',
                      showDuration: 4.inSeconds,
                      triggerMode: TooltipTriggerMode.tap,
                      child: CustomText(
                        file.name ?? 'Unnamed file',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.onBackground,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      _fileSubtitle(file),
                      fontSize: 12,
                      color: theme.supportingText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (file.ownerDisplayName != null && file.ownerDisplayName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        file.ownerDisplayName!,
                        fontSize: 11,
                        color: theme.supportingText.withValues(alpha: 0.8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isFolder) Icon(Icons.chevron_right, color: theme.supportingText.withValues(alpha: 0.7), size: 20),
              if (isFolder) const SizedBox(width: 6),
              if (selectionMode)
                GestureDetector(
                  onTap: onSelectTap,
                  child: Tooltip(
                    message: isSelected ? 'Deselect' : 'Select',
                    child: AnimatedContainer(
                      duration: Durations.short3,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? theme.primaryColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? theme.primaryColor : theme.supportingText.withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: isSelected ? Icon(Icons.check, color: theme.onPrimary, size: 16) : const SizedBox.shrink(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fileSubtitle(drive_service.DriveFile file) {
  final parts = <String>[];
  final mimeType = (file.mimeType ?? '').toLowerCase();

  if (file.isFolderLike) {
    parts.add('Folder');
  } else if (mimeType == 'application/vnd.google-apps.shortcut') {
    parts.add('Shortcut');
  } else if (mimeType.startsWith('application/vnd.google-apps.document')) {
    parts.add('Google Docs');
  } else if (mimeType.startsWith('application/vnd.google-apps.spreadsheet')) {
    parts.add('Google Sheets');
  } else if (mimeType.startsWith('application/vnd.google-apps.presentation')) {
    parts.add('Google Slides');
  } else if (mimeType.startsWith('image/')) {
    parts.add('Image');
  } else if (mimeType.startsWith('video/')) {
    parts.add('Video');
  } else if (mimeType.startsWith('audio/')) {
    parts.add('Audio');
  } else if (mimeType.contains('pdf')) {
    parts.add('PDF');
  } else if (file.fileExtension != null && file.fileExtension!.isNotEmpty) {
    parts.add(file.fileExtension!.toUpperCase());
  } else {
    parts.add('File');
  }

  if (file.size != null && !file.isGoogleNative) {
    parts.add(file.formattedSize);
  }

  return parts.join(' • ');
}

class DriveFileThumbnail extends ConsumerWidget {
  final drive_service.DriveFile file;

  const DriveFileThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final thumbnailLink = file.thumbnailLink;

    if (thumbnailLink != null && thumbnailLink.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: thumbnailLink,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          placeholder: (_, _) => _buildFallbackIcon(theme, file),
          errorWidget: (_, _, _) => _buildFallbackIcon(theme, file),
        ),
      );
    }

    return _buildFallbackIcon(theme, file);
  }
}

Widget _buildFallbackIcon(WidgetRef theme, drive_service.DriveFile file) {
  final mimeType = (file.mimeType ?? '').toLowerCase();
  IconData iconData;
  Color iconColor;

  if (file.isFolderLike) {
    iconData = Icons.folder;
    iconColor = theme.primaryColor;
  } else if (mimeType == 'application/vnd.google-apps.shortcut') {
    iconData = Icons.shortcut;
    iconColor = theme.supportingText;
  } else if (mimeType.startsWith('application/vnd.google-apps.document')) {
    iconData = Icons.description;
    iconColor = Colors.blue;
  } else if (mimeType.startsWith('application/vnd.google-apps.spreadsheet')) {
    iconData = Icons.table_chart;
    iconColor = Colors.green;
  } else if (mimeType.startsWith('application/vnd.google-apps.presentation')) {
    iconData = Icons.slideshow;
    iconColor = Colors.orange;
  } else if (mimeType.startsWith('image/')) {
    iconData = Icons.image;
    iconColor = Colors.purple;
  } else if (mimeType.startsWith('video/')) {
    iconData = Icons.video_file;
    iconColor = Colors.red;
  } else if (mimeType.startsWith('audio/')) {
    iconData = Icons.audio_file;
    iconColor = Colors.indigo;
  } else if (mimeType.contains('pdf')) {
    iconData = Icons.picture_as_pdf;
    iconColor = Colors.red.shade700;
  } else {
    iconData = Icons.insert_drive_file;
    iconColor = theme.supportingText;
  }

  return Container(
    width: 54,
    height: 54,
    decoration: BoxDecoration(
      color: iconColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: iconColor.withValues(alpha: 0.25)),
    ),
    child: Icon(iconData, color: iconColor, size: 26),
  );
}

class DriveLoadingState extends ConsumerWidget {
  const DriveLoadingState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingLogo(color: theme.primaryColor),
            const SizedBox(height: 16),
            CustomText('Loading files...', fontSize: 14, color: theme.supportingText),
          ],
        ),
      ),
    );
  }
}

class DriveErrorState extends ConsumerWidget {
  final Object error;
  final VoidCallback onRetry;

  const DriveErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.error_outline, size: 36, color: Colors.red.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 16),
            CustomText(
              'Error loading files',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.onBackground,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              error.toString(),
              fontSize: 12,
              color: theme.supportingText,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              backgroundColor: theme.primaryColor,
              onClick: onRetry,
              pixelHeight: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: theme.onPrimary, size: 18),
                  const SizedBox(width: 8),
                  CustomText('Try Again', color: theme.onPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriveEmptyState extends ConsumerWidget {
  const DriveEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.folder_open, size: 36, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            CustomText(
              'No folder selected',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.onBackground,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              'Select a Drive folder to browse its files',
              fontSize: 12,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DriveEmptyFolderState extends ConsumerWidget {
  const DriveEmptyFolderState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: theme.supportingText.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(Icons.folder_off_outlined, size: 36, color: theme.supportingText),
            ),
            const SizedBox(height: 16),
            CustomText(
              'This folder is empty',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.onBackground,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              'No files or folders found here',
              fontSize: 12,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
