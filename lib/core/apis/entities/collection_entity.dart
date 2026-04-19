import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCollectionInput {
  final String collectionTitle;
  final String description;
  final int order;
  final String createdBy;
  final String? forkedFrom;
  final CollectionMetadata metadata;

  const CreateCollectionInput({
    required this.collectionTitle,
    required this.description,
    required this.order,
    required this.createdBy,
    this.forkedFrom,
    this.metadata = const CollectionMetadata(),
  });
}

class UpdateCollectionInput {
  final String? collectionTitle;
  final String? description;
  final int? order;
  final CollectionMetadata? metadata;

  const UpdateCollectionInput({this.collectionTitle, this.description, this.order, this.metadata});

  Map<String, dynamic> toMap() => {
    if (collectionTitle != null) 'collectionTitle': collectionTitle,
    if (description != null) 'description': description,
    if (order != null) 'order': order,
    if (metadata != null) 'metadata': metadata!.toMap(),
  };
}

class CollectionEntity {
  final String collectionId;
  final String courseId;
  final String collectionTitle;
  final String description;
  final int order;
  final String createdBy;
  final String? forkedFrom;
  final int flagCount;
  final DateTime createdAt;
  final CollectionMetadata metadata;

  const CollectionEntity({
    required this.collectionId,
    required this.courseId,
    required this.collectionTitle,
    required this.description,
    required this.order,
    required this.createdBy,
    this.forkedFrom,
    required this.flagCount,
    required this.createdAt,
    required this.metadata,
  });

  factory CollectionEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final d = doc.data()!;
    return CollectionEntity(
      collectionId: doc.id,
      courseId: d['courseId'] as String,
      collectionTitle: d['collectionTitle'] as String,
      description: d['description'] as String? ?? '',
      order: d['order'] as int? ?? 0,
      createdBy: d['createdBy'] as String,
      forkedFrom: d['forkedFrom'] as String?,
      flagCount: d['flagCount'] as int? ?? 0,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      metadata: CollectionMetadata.fromMap(d['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'collectionTitle': collectionTitle,
    'description': description,
    'order': order,
    'createdBy': createdBy,
    'forkedFrom': forkedFrom,
    'flagCount': flagCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'metadata': metadata.toMap(),
  };

  static Map<String, dynamic> createMap(String collectionId, String courseId, CreateCollectionInput input) => {
    'collectionId': collectionId,
    'courseId': courseId,
    'collectionTitle': input.collectionTitle,
    'description': input.description,
    'order': input.order,
    'createdBy': input.createdBy,
    'forkedFrom': input.forkedFrom,
    'flagCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'metadata': input.metadata.toMap(),
  };
}

class CollectionMetadata {
  final String? author;
  final String? color;
  final Map<String, dynamic> thumbnails;

  const CollectionMetadata({this.author, this.color, this.thumbnails = const {}});

  factory CollectionMetadata.fromMap(Map<String, dynamic> map) => CollectionMetadata(
    author: map['author'] as String?,
    color: map['color'] as String?,
    thumbnails: map['thumbnails'] as Map<String, dynamic>? ?? {},
  );

  Map<String, dynamic> toMap() => {'author': author, 'color': color, 'thumbnails': thumbnails};
}
