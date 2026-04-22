import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content_metadata.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/file_path.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/study/logic/services/drive_browser.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

/// Result class for the extraction operation
class DriveExtractionResult {
  final bool success;
  final int totalFiles;
  final int addedFiles;
  final String? error;
  final List<String> failedFiles;

  DriveExtractionResult({
    required this.success,
    this.totalFiles = 0,
    this.addedFiles = 0,
    this.error,
    this.failedFiles = const [],
  });
}

/// Extracts all resources from a Google Drive link and adds them as course contents
///
/// [driveLink] - The Google Drive folder or file link
/// [collectionId] - The collection ID to add the contents to
/// [apiKey] - Google Drive API key for authentication
/// [showProgress] - Whether to show loading dialog (default: true)
/// [contentType] - The type of course content (default: CourseContentType.file)
Future<DriveExtractionResult> extractAndAddDriveResources({
  required String driveLink,
  required String collectionId,
  required String apiKey,
  bool showProgress = true,
  ModuleContentType contentType = ModuleContentType.unknown,
}) async {
  List<ModuleContent> contentsToAdd = [];
  List<String> failedFiles = [];
  int totalFiles = 0;

  try {
    // Show loading dialog if requested
    if (showProgress) {
      GlobalNav.withContext((context) {
        UiUtils.showLoadingDialog(context, message: "Extracting Drive resources...", canPop: false);
      });
    }

    // Validate the link
    if (!DriveBrowser.isGoogleDriveLink(driveLink)) {
      throw ArgumentError('Invalid Google Drive link');
    }

    // Fetch the resource
    final resource = await DriveBrowser.fetchResourceFromLink(driveLink, apiKey: apiKey);

    // Process based on resource type
    if (resource.type == DriveResourceType.folder) {
      // Process folder contents
      if (resource.children != null && resource.children!.isNotEmpty) {
        totalFiles = resource.children!.length;

        for (final child in resource.children!) {
          try {
            final content = await _createCourseContentFromDriveFile(child, collectionId, contentType);

            if (content != null) {
              contentsToAdd.add(content);
            } else {
              failedFiles.add(child.name ?? 'Unknown file');
            }
          } catch (e) {
            log('Error processing file ${child.name}: $e');
            failedFiles.add(child.name ?? 'Unknown file');
          }
        }
      }
    } else if (resource.type == DriveResourceType.file ||
        resource.type == DriveResourceType.googleDoc ||
        resource.type == DriveResourceType.googleSheet ||
        resource.type == DriveResourceType.googleSlide) {
      // Single file
      totalFiles = 1;

      if (resource.file != null) {
        try {
          final content = await _createCourseContentFromDriveFile(resource.file!, collectionId, contentType);

          if (content != null) {
            contentsToAdd.add(content);
          } else {
            failedFiles.add(resource.file!.name ?? 'Unknown file');
          }
        } catch (e) {
          log('Error processing file ${resource.file!.name}: $e');
          failedFiles.add(resource.file!.name ?? 'Unknown file');
        }
      }
    } else {
      throw StateError('Unsupported resource type: ${resource.type}');
    }

    // Add contents to collection
    bool addSuccess = false;
    if (contentsToAdd.isNotEmpty) {
      if (showProgress) {
        GlobalNav.withContext((context) {
          // Update loading message
          Navigator.of(context).pop(); // Close previous dialog
          UiUtils.showLoadingDialog(
            context,
            message: "Adding ${contentsToAdd.length} file(s) to collection...",
            canPop: false,
          );
        });
      }

      addSuccess = await CourseContentRepo.addMultipleContents(collectionId, contentsToAdd);
    }

    // Close loading dialog
    if (showProgress) {
      GlobalNav.withContext((context) {
        Navigator.of(context).pop();
      });
    }

    return DriveExtractionResult(
      success: addSuccess && failedFiles.isEmpty,
      totalFiles: totalFiles,
      addedFiles: contentsToAdd.length,
      failedFiles: failedFiles,
    );
  } catch (e) {
    log('Error in extractAndAddDriveResources: $e');

    // Close loading dialog on error
    if (showProgress) {
      GlobalNav.withContext((context) {
        Navigator.of(context).pop();
      });
    }

    return DriveExtractionResult(
      success: false,
      error: e.toString(),
      totalFiles: totalFiles,
      addedFiles: 0,
      failedFiles: failedFiles,
    );
  }
}

/// Creates a CourseContent from a DriveFile
Future<ModuleContent?> _createCourseContentFromDriveFile(
  DriveFile driveFile,
  String collectionId,
  ModuleContentType contentType,
) async {
  if (driveFile.id == null || driveFile.name == null) {
    return null;
  }

  // Skip folders and shortcuts
  final mimeType = driveFile.mimeType?.toLowerCase() ?? '';
  if (mimeType == 'application/vnd.google-apps.folder' || mimeType == 'application/vnd.google-apps.shortcut') {
    return null;
  }

  // Determine file name with extension
  String fileName = driveFile.name!;

  // Add extension if not present for Google native files
  if (driveFile.isGoogleNative) {
    final extension = _getExtensionForGoogleFile(mimeType);
    if (extension != null && !fileName.toLowerCase().endsWith(extension)) {
      fileName = '$fileName$extension';
    }
  } else if (driveFile.fileExtension != null && !fileName.toLowerCase().endsWith('.${driveFile.fileExtension}')) {
    fileName = '$fileName.${driveFile.fileExtension}';
  }

  // Create FileDetails with the Drive URL
  final fileDetails = FilePath(
    url: driveFile.webViewLink ?? 'https://drive.google.com/file/d/${driveFile.id}/view',
    local: '', // No local file path for Drive files
  );

  // Generate content hash from file ID and name
  final xxh3Hash = '${driveFile.id}_$fileName'.hashCode.toString();

  // Create metadata JSON with Drive file information
  final metadata = {
    'driveId': driveFile.id,
    'mimeType': driveFile.mimeType,
    'size': driveFile.size,
    'webViewLink': driveFile.webViewLink,
    'webContentLink': driveFile.webContentLink,
    'modifiedTime': driveFile.modifiedTime,
    'createdTime': driveFile.createdTime,
    'isGoogleNative': driveFile.isGoogleNative,
    'md5Checksum': driveFile.md5Checksum,
    'iconLink': driveFile.iconLink,
    'thumbnailLink': driveFile.thumbnailLink,
  };

  // Determine the appropriate CourseContentType based on MIME type
  ModuleContentType determinedType = mimeType.contains('pdf') || mimeType.contains('image')
      ? _determineCourseContentType(mimeType)
      : ModuleContentType.link;

  return ModuleContent.create(
    xxh3Hash: xxh3Hash,
    parentId: collectionId,
    title: fileName,
    path: fileDetails,
    fileSizeInBytes: 0,
    createdAt: driveFile.createdTime != null ? DateTime.tryParse(driveFile.createdTime!) : DateTime.now(),
    lastModified: driveFile.modifiedTime != null ? DateTime.tryParse(driveFile.modifiedTime!) : DateTime.now(),
    type: determinedType,
    description: driveFile.description ?? '',
    metadata: ModuleContentMetadata.create(
      thumbnails: FilePath(url: metadata['thumbnailLink'] as String? ?? ''),
      fields: {'previewUrl': metadata['thumbnailLink'], 'resolved': true, 'size': driveFile.size},
    ),
  );
}

/// Gets the appropriate file extension for Google native files
String? _getExtensionForGoogleFile(String mimeType) {
  if (mimeType.contains('document')) return '.gdoc';
  if (mimeType.contains('spreadsheet')) return '.gsheet';
  if (mimeType.contains('presentation')) return '.gslides';
  if (mimeType.contains('drawing')) return '.gdraw';
  if (mimeType.contains('form')) return '.gform';
  return null;
}

/// Determines CourseContentType based on MIME type
ModuleContentType _determineCourseContentType(String mimeType) {
  // // Video types
  // if (mimeType.contains('video')) {
  //   return CourseContentType.video;
  // }

  // Image types
  if (mimeType.contains('image')) {
    return ModuleContentType.image;
  }

  // // Audio types
  // if (mimeType.contains('audio')) {
  //   return CourseContentType.audio;
  // }

  // Document types
  if (mimeType.contains('pdf') ||
      mimeType.contains('document') ||
      mimeType.contains('word') ||
      mimeType.contains('text')) {
    return ModuleContentType.document;
  }

  // Presentation types
  if (mimeType.contains('presentation') || mimeType.contains('powerpoint') || mimeType.contains('slides')) {
    return ModuleContentType.document;
  }

  // Spreadsheet types
  if (mimeType.contains('spreadsheet') || mimeType.contains('excel') || mimeType.contains('sheet')) {
    return ModuleContentType.document;
  }

  return ModuleContentType.unknown;
}

/// Extension to help with displaying results
extension DriveExtractionResultExtension on DriveExtractionResult {
  String get message {
    if (!success) {
      return error ?? 'Failed to extract Drive resources';
    }

    if (failedFiles.isNotEmpty) {
      return 'Added $addedFiles of $totalFiles files. Failed: ${failedFiles.join(", ")}';
    }

    return 'Successfully added $addedFiles file(s) to collection';
  }
}
