import 'package:cloud_firestore/cloud_firestore.dart';

class AddContentInput {
  final String contentId;
  final String title;
  final String addedBy;
  final String type; // pdf, video, slides, link, etc.
  final int fileSize;
  final String description;
  final ContentMetadata metadata;

  const AddContentInput({
    required this.contentId,
    required this.title,
    required this.addedBy,
    required this.type,
    required this.fileSize,
    this.description = '',
    this.metadata = const ContentMetadata(),
  });
}

class ContentEntity {
  final String xxh3Hash; // doc ID
  final String contentId;
  final String collectionId;
  final String title;
  final String addedBy;
  final String type;
  final int fileSize;
  final String description;
  final DateTime createdAt;
  final ContentMetadata metadata;

  const ContentEntity({
    required this.xxh3Hash,
    required this.contentId,
    required this.collectionId,
    required this.title,
    required this.addedBy,
    required this.type,
    required this.fileSize,
    required this.description,
    required this.createdAt,
    required this.metadata,
  });

  factory ContentEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final d = doc.data()!;
    return ContentEntity(
      xxh3Hash: doc.id,
      contentId: d['contentId'] as String? ?? '',
      collectionId: d['collectionId'] as String? ?? '',
      title: d['title'] as String? ?? 'Untitled',
      addedBy: d['addedBy'] as String? ?? '',
      type: d['type'] as String? ?? 'unknown',
      fileSize: d['fileSize'] as int? ?? 0,
      description: d['description'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      metadata: ContentMetadata.fromMap(d['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'xxh3Hash': xxh3Hash,
    'contentId': contentId,
    'collectionId': collectionId,
    'title': title,
    'addedBy': addedBy,
    'type': type,
    'fileSize': fileSize,
    'description': description,
    'createdAt': Timestamp.fromDate(createdAt),
    'metadata': metadata.toMap(),
  };

  static Map<String, dynamic> createMap(String xxh3Hash, String collectionId, AddContentInput input) => {
    'xxh3Hash': xxh3Hash,
    'contentId': input.contentId,
    'collectionId': collectionId,
    'title': input.title,
    'addedBy': input.addedBy,
    'type': input.type,
    'fileSize': input.fileSize,
    'description': input.description,
    'createdAt': FieldValue.serverTimestamp(),
    'metadata': input.metadata.toMap(),
  };
}

class ContentMetadata {
  final String? originalFileName;
  final String? contentOrigin;
  final String? author;
  final Map<String, dynamic> thumbnails;

  const ContentMetadata({this.originalFileName, this.contentOrigin, this.author, this.thumbnails = const {}});

  factory ContentMetadata.fromMap(Map<String, dynamic> map) => ContentMetadata(
    originalFileName: map['originalFileName'] as String?,
    contentOrigin: map['contentOrigin'] as String?,
    author: map['author'] as String?,
    thumbnails: map['thumbnails'] as Map<String, dynamic>? ?? {},
  );

  Map<String, dynamic> toMap() => {
    'originalFileName': originalFileName,
    'contentOrigin': contentOrigin,
    'author': author,
    'thumbnails': thumbnails,
  };
}
