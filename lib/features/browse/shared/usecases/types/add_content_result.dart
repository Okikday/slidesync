// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AddContentResult {
  final bool hasDuplicate;
  final bool isSuccess;
  final String? contentId;
  final String fileName;
  final int? fileSize;

  AddContentResult({
    this.hasDuplicate = false,
    required this.isSuccess,
    this.contentId,
    required this.fileName,
    this.fileSize,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hasDuplicate': hasDuplicate,
      'isSuccess': isSuccess,
      'contentId': contentId,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  factory AddContentResult.fromMap(Map<String, dynamic> map) {
    return AddContentResult(
      hasDuplicate: map['hasDuplicate'] as bool,
      isSuccess: map['isSuccess'] as bool,
      contentId: map['contentId'] != null ? map['contentId'] as String : null,
      fileName: map['fileName'] as String,
      fileSize: map['fileSize'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddContentResult.fromJson(String source) =>
      AddContentResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AddContentResult(hasDuplicate: $hasDuplicate, isSuccess: $isSuccess, contentId: $contentId, fileName: $fileName, fileSize: $fileSize)';
  }
}
