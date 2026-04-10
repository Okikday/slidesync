import 'package:cloud_firestore/cloud_firestore.dart';

class CreateSourceInput {
  final String url;
  final String title;
  final String type; // pdf, video, slides, link
  final String uploadedBy;

  const CreateSourceInput({
    required this.url,
    required this.title,
    required this.type,
    required this.uploadedBy,
  });
}

class UpdateSourceInput {
  final String? url;
  final String? title;
  final String? type;

  const UpdateSourceInput({this.url, this.title, this.type});

  Map<String, dynamic> toMap() => {
        // Only these three fields are owner-updatable (rules enforce the rest)
        if (url != null) 'url': url,
        if (title != null) 'title': title,
        if (type != null) 'type': type,
      };
}

class SourceEntity {
  final String userId; // doc ID
  final String url;
  final String title;
  final String type;
  final int flagCount;
  final bool flagged;
  final String uploadedBy;
  final DateTime createdAt;

  const SourceEntity({
    required this.userId,
    required this.url,
    required this.title,
    required this.type,
    required this.flagCount,
    required this.flagged,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory SourceEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final d = doc.data()!;
    return SourceEntity(
      userId: doc.id,
      url: d['url'] as String,
      title: d['title'] as String,
      type: d['type'] as String,
      flagCount: d['flagCount'] as int? ?? 0,
      flagged: d['flagged'] as bool? ?? false,
      uploadedBy: d['uploadedBy'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'url': url,
        'title': title,
        'type': type,
        'flagCount': flagCount,
        'flagged': flagged,
        'uploadedBy': uploadedBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static Map<String, dynamic> createMap(CreateSourceInput input) => {
        'url': input.url,
        'title': input.title,
        'type': input.type,
        'flagCount': 0,
        'flagged': false,
        'uploadedBy': input.uploadedBy,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// Winner from resolution logic:
/// 1. Most votes → 2. Earliest createdAt → 3. null (no sources / all flagged)
class ResolvedSource {
  final SourceEntity source;
  final int voteCount;

  const ResolvedSource({required this.source, required this.voteCount});
}
