import 'dart:convert';

/// ============================================================================
/// REMOTE DATA MODELS
/// ============================================================================
///
/// Models representing data structures in Firebase Firestore.
/// These mirror local models but are optimized for cloud storage.
/// ============================================================================

/// Remote course metadata
class RemoteCourse {
  final String courseId;
  final String courseTitle;
  final String description;
  final DateTime? createdAt;
  final DateTime? lastUpdated;
  final String metadataJson;
  final int collectionsCount;
  final int totalContentsCount;

  RemoteCourse({
    required this.courseId,
    required this.courseTitle,
    this.description = '',
    this.createdAt,
    this.lastUpdated,
    this.metadataJson = '{}',
    this.collectionsCount = 0,
    this.totalContentsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'metadataJson': metadataJson,
      'collectionsCount': collectionsCount,
      'totalContentsCount': totalContentsCount,
    };
  }

  factory RemoteCourse.fromMap(Map<String, dynamic> map) {
    return RemoteCourse(
      courseId: map['courseId'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      lastUpdated: map['lastUpdated'] != null ? DateTime.tryParse(map['lastUpdated']) : null,
      metadataJson: map['metadataJson'] ?? '{}',
      collectionsCount: map['collectionsCount'] ?? 0,
      totalContentsCount: map['totalContentsCount'] ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory RemoteCourse.fromJson(String source) => RemoteCourse.fromMap(jsonDecode(source));
}

/// Remote collection metadata
class RemoteCollection {
  final String collectionId;
  final String parentId; // courseId
  final String collectionTitle;
  final String description;
  final DateTime? createdAt;
  final String metadataJson;
  final int contentsCount;
  final List<String> contentHashes; // List of content hashes in this collection

  RemoteCollection({
    required this.collectionId,
    required this.parentId,
    required this.collectionTitle,
    this.description = '',
    this.createdAt,
    this.metadataJson = '{}',
    this.contentsCount = 0,
    this.contentHashes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'parentId': parentId,
      'collectionTitle': collectionTitle,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'metadataJson': metadataJson,
      'contentsCount': contentsCount,
      'contentHashes': contentHashes,
    };
  }

  factory RemoteCollection.fromMap(Map<String, dynamic> map) {
    return RemoteCollection(
      collectionId: map['collectionId'] ?? '',
      parentId: map['parentId'] ?? '',
      collectionTitle: map['collectionTitle'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      metadataJson: map['metadataJson'] ?? '{}',
      contentsCount: map['contentsCount'] ?? 0,
      contentHashes: List<String>.from(map['contentHashes'] ?? []),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory RemoteCollection.fromJson(String source) => RemoteCollection.fromMap(jsonDecode(source));
}

/// Remote content metadata (global reference)
class RemoteContent {
  final String contentHash;
  final String title;
  final String description;
  final String courseContentType; // Stored as string
  final int fileSize;
  final String storageUrl; // Firebase Storage download URL for .ss file
  final String metadataJson;
  final DateTime? uploadedAt;

  RemoteContent({
    required this.contentHash,
    required this.title,
    this.description = '',
    required this.courseContentType,
    required this.fileSize,
    required this.storageUrl,
    this.metadataJson = '{}',
    this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'contentHash': contentHash,
      'title': title,
      'description': description,
      'courseContentType': courseContentType,
      'fileSize': fileSize,
      'storageUrl': storageUrl,
      'metadataJson': metadataJson,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  factory RemoteContent.fromMap(Map<String, dynamic> map) {
    return RemoteContent(
      contentHash: map['contentHash'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseContentType: map['courseContentType'] ?? 'document',
      fileSize: map['fileSize'] ?? 0,
      storageUrl: map['storageUrl'] ?? '',
      metadataJson: map['metadataJson'] ?? '{}',
      uploadedAt: map['uploadedAt'] != null ? DateTime.tryParse(map['uploadedAt']) : null,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory RemoteContent.fromJson(String source) => RemoteContent.fromMap(jsonDecode(source));
}

/// Upload progress data
class UploadProgress {
  final String id;
  final double progress; // 0.0 to 1.0
  final String message;
  final int uploadedBytes;
  final int totalBytes;

  UploadProgress({
    required this.id,
    required this.progress,
    required this.message,
    this.uploadedBytes = 0,
    this.totalBytes = 0,
  });
}

/// Download progress data
class DownloadProgress {
  final String id;
  final double progress; // 0.0 to 1.0
  final String message;
  final int downloadedBytes;
  final int totalBytes;

  DownloadProgress({
    required this.id,
    required this.progress,
    required this.message,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });
}

/// Merge strategy for existing courses
enum MergeStrategy {
  skip, // Skip if exists
  merge, // Add missing collections/contents
  replace, // Replace everything
}

/// Merge result details
class MergeResult {
  final int addedCollections;
  final int addedContents;
  final int skippedCollections;
  final int skippedContents;
  final List<String> messages;

  MergeResult({
    this.addedCollections = 0,
    this.addedContents = 0,
    this.skippedCollections = 0,
    this.skippedContents = 0,
    this.messages = const [],
  });

  String get summary {
    return 'Added: $addedCollections collections, $addedContents contents. '
        'Skipped: $skippedCollections collections, $skippedContents contents.';
  }
}
