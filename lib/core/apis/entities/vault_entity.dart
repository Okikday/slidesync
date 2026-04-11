import 'package:cloud_firestore/cloud_firestore.dart';

// ── Input models ────────────────────────────────────────────────────────────

class CreateVaultInput {
  final String label;
  final String url;
  final String type; // drive, s3, ftp, etc.
  final String addedBy;

  const CreateVaultInput({
    required this.label,
    required this.url,
    required this.type,
    required this.addedBy,
  });
}

class UpdateVaultInput {
  final String? label;
  final String? url;
  final String? type;

  const UpdateVaultInput({this.label, this.url, this.type});

  Map<String, dynamic> toMap() => {
        if (label != null) 'label': label,
        if (url != null) 'url': url,
        if (type != null) 'type': type,
      };
}

class LogUploadInput {
  final String uploadedBy;
  final String contentHash;
  final String fileName;
  final int fileSize;
  final String notes;

  const LogUploadInput({
    required this.uploadedBy,
    required this.contentHash,
    required this.fileName,
    required this.fileSize,
    this.notes = '',
  });
}

// ── Entities ────────────────────────────────────────────────────────────────

class VaultEntity {
  final String linkId;
  final String label;
  final String url;
  final String type;
  final String addedBy;
  final DateTime createdAt;

  const VaultEntity({
    required this.linkId,
    required this.label,
    required this.url,
    required this.type,
    required this.addedBy,
    required this.createdAt,
  });

  factory VaultEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final d = doc.data()!;
    return VaultEntity(
      linkId: doc.id,
      label: d['label'] as String,
      url: d['url'] as String,
      type: d['type'] as String,
      addedBy: d['addedBy'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'url': url,
        'type': type,
        'addedBy': addedBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static Map<String, dynamic> createMap(String linkId, CreateVaultInput input) => {
        'linkId': linkId,
        'label': input.label,
        'url': input.url,
        'type': input.type,
        'addedBy': input.addedBy,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class VaultUploadEntity {
  final String uploadId;
  final String uploadedBy;
  final String contentHash;
  final String fileName;
  final int fileSize;
  final DateTime uploadedAt;
  final String notes;

  const VaultUploadEntity({
    required this.uploadId,
    required this.uploadedBy,
    required this.contentHash,
    required this.fileName,
    required this.fileSize,
    required this.uploadedAt,
    required this.notes,
  });

  factory VaultUploadEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final d = doc.data()!;
    return VaultUploadEntity(
      uploadId: doc.id,
      uploadedBy: d['uploadedBy'] as String,
      contentHash: d['contentHash'] as String,
      fileName: d['fileName'] as String,
      fileSize: d['fileSize'] as int? ?? 0,
      uploadedAt: (d['uploadedAt'] as Timestamp).toDate(),
      notes: d['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'uploadedBy': uploadedBy,
        'contentHash': contentHash,
        'fileName': fileName,
        'fileSize': fileSize,
        'uploadedAt': Timestamp.fromDate(uploadedAt),
        'notes': notes,
      };

  static Map<String, dynamic> createMap(String uploadId, LogUploadInput input) => {
        'uploadId': uploadId,
        // Immutable fields — never updatable after creation
        'uploadedBy': input.uploadedBy,
        'contentHash': input.contentHash,
        'uploadedAt': FieldValue.serverTimestamp(),
        // Mutable
        'fileName': input.fileName,
        'fileSize': input.fileSize,
        'notes': input.notes,
      };
}