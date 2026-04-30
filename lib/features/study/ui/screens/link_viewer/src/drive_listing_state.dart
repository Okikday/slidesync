import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart' as drive_service;

class DriveListingNavState {
  final List<String> navigationHistory;
  final String? currentFolderId;
  final Map<String, String> folderLabels;

  const DriveListingNavState({this.navigationHistory = const [], this.currentFolderId, this.folderLabels = const {}});

  DriveListingNavState copyWith({
    List<String>? navigationHistory,
    String? currentFolderId,
    Map<String, String>? folderLabels,
  }) {
    return DriveListingNavState(
      navigationHistory: navigationHistory ?? this.navigationHistory,
      currentFolderId: currentFolderId ?? this.currentFolderId,
      folderLabels: folderLabels ?? this.folderLabels,
    );
  }
}

class DriveListingNavNotifier extends Notifier<DriveListingNavState> {
  @override
  DriveListingNavState build() => const DriveListingNavState();

  void initializeRoot(String folderId, {String? rootLabel}) {
    if (state.currentFolderId != null) {
      return;
    }

    final labels = Map<String, String>.from(state.folderLabels);
    if (rootLabel != null && rootLabel.trim().isNotEmpty) {
      labels[folderId] = rootLabel.trim();
    }

    state = state.copyWith(currentFolderId: folderId, folderLabels: labels);
  }

  void navigateBack() {
    if (state.navigationHistory.isEmpty) {
      return;
    }

    final updated = List<String>.from(state.navigationHistory);
    final previousFolderId = updated.removeLast();

    state = state.copyWith(navigationHistory: updated, currentFolderId: previousFolderId);
  }

  void navigateToFolder(String folderId, {String? folderName, String? currentFolderName}) {
    final currentId = state.currentFolderId;
    final updatedLabels = Map<String, String>.from(state.folderLabels);

    if (currentId != null && currentFolderName != null && currentFolderName.trim().isNotEmpty) {
      updatedLabels[currentId] = currentFolderName.trim();
    }
    if (folderName != null && folderName.trim().isNotEmpty) {
      updatedLabels[folderId] = folderName.trim();
    }

    state = state.copyWith(
      navigationHistory: currentId == null ? state.navigationHistory : [...state.navigationHistory, currentId],
      currentFolderId: folderId,
      folderLabels: updatedLabels,
    );
  }

  void jumpToBreadcrumb(int index) {
    if (index < 0 || index >= state.navigationHistory.length) {
      return;
    }

    final updatedHistory = state.navigationHistory.sublist(0, index);
    final targetFolderId = state.navigationHistory[index];

    state = state.copyWith(navigationHistory: updatedHistory, currentFolderId: targetFolderId);
  }

  void setFolderLabel(String folderId, String label) {
    final cleaned = label.trim();
    if (cleaned.isEmpty) {
      return;
    }

    if (state.folderLabels[folderId] == cleaned) {
      return;
    }

    final updatedLabels = Map<String, String>.from(state.folderLabels)..[folderId] = cleaned;
    state = state.copyWith(folderLabels: updatedLabels);
  }
}

final driveListingNavProvider = NotifierProvider<DriveListingNavNotifier, DriveListingNavState>(
  DriveListingNavNotifier.new,
);

final driveResourceProvider = FutureProvider.family<drive_service.DriveResource?, String?>((ref, folderOrLink) async {
  if (folderOrLink == null || folderOrLink.trim().isEmpty) {
    return null;
  }

  final apiKey = dotenv.env['DRIVE_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return null;
  }

  try {
    if (drive_service.DriveBrowser.isGoogleDriveLink(folderOrLink)) {
      return await drive_service.DriveBrowser.fetchResourceFromLink(folderOrLink, apiKey: apiKey);
    }

    final metadata = await drive_service.DriveBrowser.getFileMetadata(folderOrLink, apiKey: apiKey);

    if (metadata.isFolderLike) {
      final folderId = metadata.navigationTargetId ?? metadata.id;
      if (folderId == null) {
        return drive_service.DriveResource(type: drive_service.DriveResourceType.folder, file: metadata, children: []);
      }

      final children = await drive_service.DriveBrowser.listFolderContents(folderId, apiKey: apiKey);
      return drive_service.DriveResource(
        type: drive_service.DriveResourceType.folder,
        file: metadata,
        children: children,
      );
    }

    final type = _deriveResourceType(metadata);
    return drive_service.DriveResource(type: type, file: metadata);
  } catch (error, stackTrace) {
    log('DriveListingView: failed to fetch Drive resource for $folderOrLink', error: error, stackTrace: stackTrace);
    Error.throwWithStackTrace(error, stackTrace);
  }
});

drive_service.DriveResourceType _deriveResourceType(drive_service.DriveFile file) {
  final mimeType = (file.mimeType ?? '').toLowerCase();

  if (file.isFolderLike) {
    return drive_service.DriveResourceType.folder;
  }
  if (mimeType.startsWith('application/vnd.google-apps.document')) {
    return drive_service.DriveResourceType.googleDoc;
  }
  if (mimeType.startsWith('application/vnd.google-apps.spreadsheet')) {
    return drive_service.DriveResourceType.googleSheet;
  }
  if (mimeType.startsWith('application/vnd.google-apps.presentation')) {
    return drive_service.DriveResourceType.googleSlide;
  }
  if (mimeType == 'application/vnd.google-apps.shortcut') {
    return drive_service.DriveResourceType.shortcut;
  }

  return drive_service.DriveResourceType.file;
}
