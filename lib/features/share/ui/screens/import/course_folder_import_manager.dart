import 'package:flutter/material.dart';
import 'dart:async';

typedef FolderFilesGetter<TFolder, TFile> = List<TFile> Function(TFolder folder);
typedef FolderSubfoldersGetter<TFolder> = List<TFolder> Function(TFolder folder);
typedef FileNameGetter<TFile> = String Function(TFile file);
typedef FileExtensionGetter<TFile> = String Function(TFile file);
typedef FolderNameGetter<TFolder> = String Function(TFolder folder);

/// File type filter options shared by SAF and desktop imports.
class FileTypeFilter {
  final String extension;
  final String displayName;
  final IconData icon;
  bool isEnabled;

  FileTypeFilter({required this.extension, required this.displayName, required this.icon, this.isEnabled = true});
}

/// Import progress state shared by SAF and desktop imports.
class ImportProgress {
  final String message;
  final double? progress;
  final int? currentCollection;
  final int? totalCollections;
  final String? currentCollectionName;

  ImportProgress({
    required this.message,
    this.progress,
    this.currentCollection,
    this.totalCollections,
    this.currentCollectionName,
  });

  String get displayMessage {
    if (currentCollection != null && totalCollections != null) {
      return 'Processing collection $currentCollection of $totalCollections\n${currentCollectionName ?? ""}\n$message';
    }
    return message;
  }
}

/// Shared helpers for folder import managers.
class CourseFolderImportManagerCore {
  static List<FileTypeFilter> getDefaultFileFilters() {
    return [
      // Documents
      FileTypeFilter(extension: '.pdf', displayName: 'PDF Documents', icon: Icons.picture_as_pdf),
      FileTypeFilter(extension: '.docx', displayName: 'Word Documents', icon: Icons.description),
      FileTypeFilter(extension: '.doc', displayName: 'Word Documents (Old)', icon: Icons.description),
      FileTypeFilter(extension: '.pptx', displayName: 'PowerPoint', icon: Icons.slideshow),
      FileTypeFilter(extension: '.ppt', displayName: 'PowerPoint (Old)', icon: Icons.slideshow),
      FileTypeFilter(extension: '.xlsx', displayName: 'Excel Spreadsheets', icon: Icons.table_chart),
      FileTypeFilter(extension: '.xls', displayName: 'Excel (Old)', icon: Icons.table_chart),
      FileTypeFilter(extension: '.txt', displayName: 'Text Files', icon: Icons.text_snippet),
      FileTypeFilter(extension: '.rtf', displayName: 'Rich Text Format', icon: Icons.text_fields),
      FileTypeFilter(extension: '.odt', displayName: 'OpenDocument Text', icon: Icons.article),

      // Images
      FileTypeFilter(extension: '.jpg', displayName: 'JPEG Images', icon: Icons.image),
      FileTypeFilter(extension: '.jpeg', displayName: 'JPEG Images', icon: Icons.image),
      FileTypeFilter(extension: '.png', displayName: 'PNG Images', icon: Icons.image),
      FileTypeFilter(extension: '.gif', displayName: 'GIF Images', icon: Icons.gif),
      FileTypeFilter(extension: '.webp', displayName: 'WebP Images', icon: Icons.image),
      FileTypeFilter(extension: '.bmp', displayName: 'Bitmap Images', icon: Icons.image),
      FileTypeFilter(extension: '.svg', displayName: 'SVG Graphics', icon: Icons.brush),

      // Archives
      FileTypeFilter(extension: '.zip', displayName: 'ZIP Archives', icon: Icons.folder_zip),
      FileTypeFilter(extension: '.rar', displayName: 'RAR Archives', icon: Icons.folder_zip),
    ];
  }

  static Set<String> getEnabledExtensions(List<FileTypeFilter> filters) {
    return filters.where((filter) => filter.isEnabled).map((filter) => filter.extension.toLowerCase()).toSet();
  }

  static String extractFolderNameFromUri(String folderUri) {
    try {
      final decodedUri = Uri.decodeComponent(folderUri);
      final lastSlashIndex = decodedUri.lastIndexOf('/');
      if (lastSlashIndex != -1 && lastSlashIndex < decodedUri.length - 1) {
        final afterSlash = decodedUri.substring(lastSlashIndex + 1);
        final lastColonIndex = afterSlash.lastIndexOf(':');
        if (lastColonIndex != -1) {
          final afterColon = afterSlash.substring(lastColonIndex + 1);
          final pathParts = afterColon.split('/');
          final folderName = pathParts.last.trim();
          return folderName.isEmpty ? 'Folder' : folderName;
        }

        final folderName = afterSlash.trim();
        return folderName.isEmpty ? 'Folder' : folderName;
      }
    } catch (_) {
      // Fall through to the default.
    }

    return 'Folder';
  }

  static Future<List<T>> runInBatches<T>(List<T> items, int maxConcurrency, Future<void> Function(T item) task) async {
    if (items.isEmpty) {
      return const [];
    }

    final effectiveConcurrency = maxConcurrency < 1 ? 1 : maxConcurrency;

    for (int index = 0; index < items.length; index += effectiveConcurrency) {
      final endIndex = index + effectiveConcurrency > items.length ? items.length : index + effectiveConcurrency;
      final batch = items.sublist(index, endIndex);

      await Future.wait(
        batch.map((item) async {
          try {
            await task(item);
          } catch (_) {
            // Individual tasks are expected to handle their own failures.
          }
        }),
      );
    }

    return items;
  }

  static bool shouldThrottleProgressUpdate({
    required int processedCount,
    required int totalCount,
    required DateTime? lastUpdate,
    Duration minInterval = const Duration(milliseconds: 300),
    int everyNthItem = 10,
  }) {
    if (processedCount >= totalCount) {
      return true;
    }

    if (processedCount % everyNthItem == 0) {
      return true;
    }

    if (lastUpdate == null) {
      return true;
    }

    return DateTime.now().difference(lastUpdate) >= minInterval;
  }

  static List<TFile> getFilteredFiles<TFolder, TFile>({
    required TFolder folder,
    required List<FileTypeFilter> filters,
    required bool includeSubfolders,
    required FolderFilesGetter<TFolder, TFile> getFiles,
    required FolderSubfoldersGetter<TFolder> getSubfolders,
    required FileExtensionGetter<TFile> getFileExtension,
    Set<String>? enabledExtensions,
  }) {
    final List<TFile> allFiles = [];
    final effectiveEnabledExtensions = enabledExtensions ?? getEnabledExtensions(filters);

    if (effectiveEnabledExtensions.isEmpty) {
      return allFiles;
    }

    for (final file in getFiles(folder)) {
      final extension = getFileExtension(file).toLowerCase();
      if (effectiveEnabledExtensions.contains(extension)) {
        allFiles.add(file);
      }
    }

    if (includeSubfolders) {
      for (final subfolder in getSubfolders(folder)) {
        allFiles.addAll(
          getFilteredFiles<TFolder, TFile>(
            folder: subfolder,
            filters: filters,
            includeSubfolders: true,
            getFiles: getFiles,
            getSubfolders: getSubfolders,
            getFileExtension: getFileExtension,
            enabledExtensions: effectiveEnabledExtensions,
          ),
        );
      }
    }

    return allFiles;
  }

  static Map<String, List<TFile>> calculateImportStructure<TFolder, TFile>({
    required TFolder targetFolder,
    required List<FileTypeFilter> filters,
    required bool includeSubfolders,
    required FolderFilesGetter<TFolder, TFile> getFiles,
    required FolderSubfoldersGetter<TFolder> getSubfolders,
    required FileNameGetter<TFolder> getFolderName,
    required FileExtensionGetter<TFile> getFileExtension,
    String rootCollectionName = '___',
    String leafCollectionName = 'Materials',
    Set<String>? enabledExtensions,
  }) {
    final Map<String, List<TFile>> collections = {};
    final hasSubfolders = getSubfolders(targetFolder).isNotEmpty;
    final effectiveEnabledExtensions = enabledExtensions ?? getEnabledExtensions(filters);

    if (hasSubfolders) {
      for (final subfolder in getSubfolders(targetFolder)) {
        final files = getFilteredFiles<TFolder, TFile>(
          folder: subfolder,
          filters: filters,
          includeSubfolders: includeSubfolders,
          getFiles: getFiles,
          getSubfolders: getSubfolders,
          getFileExtension: getFileExtension,
          enabledExtensions: effectiveEnabledExtensions,
        );
        if (files.isNotEmpty) {
          collections[getFolderName(subfolder)] = files;
        }
      }

      final rootFiles = getFiles(
        targetFolder,
      ).where((file) => effectiveEnabledExtensions.contains(getFileExtension(file).toLowerCase())).toList();

      if (rootFiles.isNotEmpty) {
        collections[rootCollectionName] = rootFiles;
      }
    } else {
      final files = getFilteredFiles<TFolder, TFile>(
        folder: targetFolder,
        filters: filters,
        includeSubfolders: false,
        getFiles: getFiles,
        getSubfolders: getSubfolders,
        getFileExtension: getFileExtension,
        enabledExtensions: effectiveEnabledExtensions,
      );

      if (files.isNotEmpty) {
        collections[leafCollectionName] = files;
      }
    }

    return collections;
  }
}
