import 'package:cloud_firestore/cloud_firestore.dart';

// ── Input model (used for create / fork) ───────────────────────────────────

class CreateCourseInput {
  final String courseTitle;
  final String description;
  final String institutionId;
  final String catalogId;
  final String createdBy;
  final String? forkedFrom;
  final CourseMetadata metadata;

  const CreateCourseInput({
    required this.courseTitle,
    required this.description,
    required this.institutionId,
    required this.catalogId,
    required this.createdBy,
    this.forkedFrom,
    this.metadata = const CourseMetadata(),
  });
}

class UpdateCourseInput {
  final String? courseTitle;
  final String? description;
  final CourseMetadata? metadata;

  const UpdateCourseInput({this.courseTitle, this.description, this.metadata});

  Map<String, dynamic> toMap() => {
        if (courseTitle != null) 'courseTitle': courseTitle,
        if (description != null) 'description': description,
        if (metadata != null) 'metadata': metadata!.toMap(),
      };
}

// ── Entity (what Firestore returns) ───────────────────────────────────────

class CourseEntity {
  final String courseId;
  final String courseTitle;
  final String description;
  final String institutionId;
  final String catalogId;
  final String createdBy;
  final String? forkedFrom;
  final bool verified;
  final int flagCount;
  final DateTime createdAt;
  final CourseMetadata metadata;

  const CourseEntity({
    required this.courseId,
    required this.courseTitle,
    required this.description,
    required this.institutionId,
    required this.catalogId,
    required this.createdBy,
    this.forkedFrom,
    required this.verified,
    required this.flagCount,
    required this.createdAt,
    required this.metadata,
  });

  factory CourseEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final d = doc.data()!;
    return CourseEntity(
      courseId: doc.id,
      courseTitle: d['courseTitle'] as String,
      description: d['description'] as String? ?? '',
      institutionId: d['institutionId'] as String,
      catalogId: d['catalogId'] as String,
      createdBy: d['createdBy'] as String,
      forkedFrom: d['forkedFrom'] as String?,
      verified: d['verified'] as bool? ?? false,
      flagCount: d['flagCount'] as int? ?? 0,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      metadata: CourseMetadata.fromMap(
          d['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  // Used by toFirestore in withConverter — NOT called directly.
  // courseId, verified, flagCount are server/CF managed, excluded from writes.
  Map<String, dynamic> toMap() => {
        'courseTitle': courseTitle,
        'description': description,
        'institutionId': institutionId,
        'catalogId': catalogId,
        'createdBy': createdBy,
        'forkedFrom': forkedFrom,
        'verified': verified,
        'flagCount': flagCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'metadata': metadata.toMap(),
      };

  /// Map for initial creation — uses server timestamp, safe field set only.
  static Map<String, dynamic> createMap(
      String courseId, CreateCourseInput input) => {
        'courseId': courseId,
        'courseTitle': input.courseTitle,
        'description': input.description,
        'institutionId': input.institutionId,
        'catalogId': input.catalogId,
        'createdBy': input.createdBy,
        'forkedFrom': input.forkedFrom,
        'verified': false,
        'flagCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': input.metadata.toMap(),
      };
}

class CourseMetadata {
  final String? author;
  final String? color;
  final Map<String, dynamic> thumbnails;

  const CourseMetadata({
    this.author,
    this.color,
    this.thumbnails = const {},
  });

  factory CourseMetadata.fromMap(Map<String, dynamic> map) => CourseMetadata(
        author: map['author'] as String?,
        color: map['color'] as String?,
        thumbnails: map['thumbnails'] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toMap() => {
        'author': author,
        'color': color,
        'thumbnails': thumbnails,
      };
}
