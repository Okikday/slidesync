import 'package:cloud_firestore/cloud_firestore.dart';

// ── User ───────────────────────────────────────────────────────────────────

class UserEntity {
  final String uid;
  final int courseCount;
  final bool verified;

  const UserEntity({required this.uid, required this.courseCount, required this.verified});

  factory UserEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final d = doc.data()!;
    return UserEntity(
      uid: doc.id,
      courseCount: d['courseCount'] as int? ?? 0,
      verified: d['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {'courseCount': courseCount, 'verified': verified};
}

// ── Institution ────────────────────────────────────────────────────────────

class InstitutionEntity {
  final String institutionId;
  final String name;
  final String shortName;
  final String country;
  final DateTime createdAt;

  const InstitutionEntity({
    required this.institutionId,
    required this.name,
    required this.shortName,
    required this.country,
    required this.createdAt,
  });

  factory InstitutionEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final d = doc.data()!;
    return InstitutionEntity(
      institutionId: doc.id,
      name: d['name'] as String? ?? 'Unknown',
      shortName: d['shortName'] as String? ?? 'N/A',
      country: d['country'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'shortName': shortName,
    'country': country,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ── Catalog ────────────────────────────────────────────────────────────────

class CatalogEntity {
  final String catalogId;
  final String title;
  final String institutionId;
  final String department;

  const CatalogEntity({
    required this.catalogId,
    required this.title,
    required this.institutionId,
    required this.department,
  });

  factory CatalogEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final d = doc.data()!;
    return CatalogEntity(
      catalogId: doc.id,
      title: d['title'] as String? ?? 'Untitled',
      institutionId: d['institutionId'] as String? ?? '',
      department: d['department'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'title': title, 'institutionId': institutionId, 'department': department};
}
