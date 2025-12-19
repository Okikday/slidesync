import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart';
import 'package:slidesync/features/study/logic/services/drive_result_extractor.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

/// Navigation history provider
final navigationHistoryProvider = StateProvider.autoDispose<List<String>>((ref) => []);
final currentFolderIdProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Drive resource provider with proper caching
final driveResourceProvider = FutureProvider.autoDispose.family<DriveResource, String?>((ref, folderId) async {
  if (folderId == null) throw ArgumentError('Folder ID cannot be null');

  final apiKey = dotenv.env['DRIVE_API_KEY'] ?? '';
  String linkToFetch;

  if (folderId.startsWith('http')) {
    linkToFetch = folderId;
  } else {
    try {
      final metadata = await DriveBrowser.getFileMetadata(folderId, apiKey: apiKey);
      final mimeType = metadata.mimeType ?? '';

      if (mimeType == 'application/vnd.google-apps.folder') {
        linkToFetch = 'https://drive.google.com/drive/folders/$folderId';
      } else {
        return DriveResource(type: _getResourceTypeFromMimeType(mimeType), file: metadata);
      }
    } catch (e) {
      linkToFetch = 'https://drive.google.com/drive/folders/$folderId';
    }
  }

  return DriveBrowser.fetchResourceFromLink(linkToFetch, apiKey: apiKey);
});

DriveResourceType _getResourceTypeFromMimeType(String mimeType) {
  final mt = mimeType.toLowerCase();
  if (mt == 'application/vnd.google-apps.folder') return DriveResourceType.folder;
  if (mt.startsWith('application/vnd.google-apps.document')) return DriveResourceType.googleDoc;
  if (mt.startsWith('application/vnd.google-apps.spreadsheet')) return DriveResourceType.googleSheet;
  if (mt.startsWith('application/vnd.google-apps.presentation')) return DriveResourceType.googleSlide;
  if (mt == 'application/vnd.google-apps.shortcut') return DriveResourceType.shortcut;
  return DriveResourceType.file;
}

class DriveListingView extends ConsumerWidget {
  final String? initialFolderId;
  final String collectionId;

  const DriveListingView({super.key, this.initialFolderId, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final currentFolderId = ref.watch(currentFolderIdProvider) ?? initialFolderId;
    final navigationHistory = ref.watch(navigationHistoryProvider);
    final resourceAsync = currentFolderId != null ? ref.watch(driveResourceProvider(currentFolderId)) : null;

    return PopScope(
      canPop: navigationHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && navigationHistory.isNotEmpty) {
          _navigateBack(ref);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.surfaceColor,
          foregroundColor: theme.onSurfaceColor,
          leading: navigationHistory.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.onSurfaceColor),
                  onPressed: () => _navigateBack(ref),
                )
              : null,
          title: resourceAsync?.when(
            data: (resource) => CustomText(
              resource.file?.name ?? 'Drive Files',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.onSurfaceColor,
            ),
            loading: () => CustomText('Loading...', fontSize: 18, color: theme.onSurfaceColor),
            error: (_, _) => CustomText('Drive Files', fontSize: 18, color: theme.onSurfaceColor),
          ),
          actions: [
            if (resourceAsync?.hasValue == true &&
                resourceAsync!.value!.type == DriveResourceType.folder &&
                resourceAsync.value!.children != null &&
                resourceAsync.value!.children!.isNotEmpty)
              IconButton(
                icon: Icon(Icons.download, color: theme.primaryColor),
                tooltip: 'Import All',
                onPressed: () => _handleImportAll(context, ref, resourceAsync.value!),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: currentFolderId == null
            ? _EmptyState()
            : resourceAsync?.when(
                    data: (resource) => _DriveContent(
                      resource: resource,
                      onFolderNavigate: (folderId) => _navigateToFolder(ref, folderId),
                    ),
                    loading: () => _LoadingState(),
                    error: (error, _) =>
                        _ErrorState(error: error, onRetry: () => ref.refresh(driveResourceProvider(currentFolderId))),
                  ) ??
                  _EmptyState(),
      ),
    );
  }

  void _navigateBack(WidgetRef ref) {
    final history = List<String>.from(ref.read(navigationHistoryProvider));
    if (history.isNotEmpty) {
      final previousFolderId = history.removeLast();
      ref.read(navigationHistoryProvider.notifier).state = history;
      ref.read(currentFolderIdProvider.notifier).state = previousFolderId;
    }
  }

  void _navigateToFolder(WidgetRef ref, String folderId) {
    final currentId = ref.read(currentFolderIdProvider);
    if (currentId != null) {
      final history = List<String>.from(ref.read(navigationHistoryProvider));
      ref.read(navigationHistoryProvider.notifier).state = [...history, currentId];
    }
    ref.read(currentFolderIdProvider.notifier).state = folderId;
  }

  Future<void> _handleImportAll(BuildContext context, WidgetRef ref, DriveResource resource) async {
    if (resource.file?.id == null) return;

    final folderLink = 'https://drive.google.com/drive/folders/${resource.file!.id}';
    final result = await extractAndAddDriveResources(
      driveLink: folderLink,
      collectionId: collectionId,
      apiKey: dotenv.env['DRIVE_API_KEY'] ?? '',
      showProgress: true,
      contentType: CourseContentType.link,
    );

    // Show result message
    if (context.mounted) {
      final message = result.success
          ? 'Successfully added ${result.addedFiles} file(s)'
          : result.error ?? 'Failed to add files';

      GlobalNav.withContext((context) {
        UiUtils.showFlushBar(context, msg: message, vibe: result.success ? FlushbarVibe.success : FlushbarVibe.error);
      });
    }
  }
}

class _DriveContent extends ConsumerWidget {
  final DriveResource resource;
  final Function(String folderId)? onFolderNavigate;

  const _DriveContent({required this.resource, this.onFolderNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (resource.type == DriveResourceType.folder) {
      final children = resource.children ?? [];

      if (children.isEmpty) {
        return _EmptyFolderState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final file = children[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DriveItemTile(
              file: file,
              onTap: () {
                if (file.mimeType == 'application/vnd.google-apps.folder') {
                  onFolderNavigate?.call(file.id!);
                }
              },
            ),
          );
        },
      );
    }

    // Single file - shouldn't happen in folder browsing but handle it
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _DriveItemTile(file: resource.file!),
      ),
    );
  }
}

class _DriveItemTile extends ConsumerWidget {
  final DriveFile file;
  final VoidCallback? onTap;

  const _DriveItemTile({required this.file, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final isFolder = file.mimeType == 'application/vnd.google-apps.folder';

    return CustomElevatedButton(
      backgroundColor: theme.cardColor,
      borderRadius: 12,
      elevation: 0,
      onClick: isFolder ? onTap : null,
      contentPadding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _FileIcon(file: file),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  file.name ?? 'Unnamed',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.onCardColor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                CustomText(_getFileDescription(file), fontSize: 12, color: theme.supportingText),
              ],
            ),
          ),
          if (isFolder) Icon(Icons.chevron_right, color: theme.supportingText),
        ],
      ),
    );
  }

  String _getFileDescription(DriveFile file) {
    final parts = <String>[];
    final mimeType = file.mimeType ?? '';

    if (mimeType == 'application/vnd.google-apps.folder') {
      parts.add('Folder');
    } else if (mimeType.startsWith('application/vnd.google-apps.document')) {
      parts.add('Google Docs');
    } else if (mimeType.startsWith('application/vnd.google-apps.spreadsheet')) {
      parts.add('Google Sheets');
    } else if (mimeType.startsWith('application/vnd.google-apps.presentation')) {
      parts.add('Google Slides');
    } else if (file.fileExtension != null) {
      parts.add(file.fileExtension!.toUpperCase());
    }

    if (file.size != null && !file.isGoogleNative) {
      parts.add(file.formattedSize);
    }

    return parts.join(' • ');
  }
}

class _FileIcon extends ConsumerWidget {
  final DriveFile file;

  const _FileIcon({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final mimeType = file.mimeType ?? '';

    // Use thumbnail for images if available
    if (file.thumbnailLink != null && mimeType.startsWith('image/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: file.thumbnailLink!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, _) => _buildIconContainer(Icons.image, Colors.purple, theme),
          errorWidget: (_, _, _) => _buildIcon(mimeType, theme),
        ),
      );
    }

    return _buildIcon(mimeType, theme);
  }

  Widget _buildIcon(String mimeType, WidgetRef theme) {
    IconData iconData;
    Color iconColor;

    if (mimeType == 'application/vnd.google-apps.folder') {
      iconData = Icons.folder;
      iconColor = theme.primaryColor;
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

    return _buildIconContainer(iconData, iconColor, theme);
  }

  Widget _buildIconContainer(IconData icon, Color color, WidgetRef theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _LoadingState extends ConsumerWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primaryColor),
          const SizedBox(height: 16),
          CustomText('Loading files...', fontSize: 14, color: theme.supportingText),
        ],
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.withAlpha(200)),
            const SizedBox(height: 16),
            CustomText(
              'Error loading files',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.onSurfaceColor,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              error.toString(),
              fontSize: 14,
              color: theme.supportingText,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              backgroundColor: theme.primaryColor,
              onClick: onRetry,
              child: CustomText('Try Again', color: theme.onPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: theme.supportingText.withAlpha(100)),
            const SizedBox(height: 16),
            CustomText(
              'No folder selected',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              'Select a Drive folder to browse',
              fontSize: 14,
              color: theme.supportingText.withAlpha(125),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFolderState extends ConsumerWidget {
  const _EmptyFolderState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: theme.supportingText.withAlpha(100)),
            const SizedBox(height: 16),
            CustomText(
              'Empty folder',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.supportingText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              'This folder contains no files',
              fontSize: 14,
              color: theme.supportingText.withAlpha(125),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
