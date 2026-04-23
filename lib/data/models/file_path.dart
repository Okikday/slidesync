// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:isar_community/isar.dart';

part 'file_path.g.dart';

@embedded
class FilePath {
  String? url;
  String? local;
  FilePath({this.url, this.local});

  @ignore
  bool get containsLocalPath => (local != null && local!.isNotEmpty);
  @ignore
  bool get containsUrlPath => (url != null && url!.isNotEmpty);
  @ignore
  bool get containsAnyPath => (url != null && url!.isNotEmpty) || (local != null && local!.isNotEmpty);

  factory FilePath.empty() => FilePath(url: '', local: '');

  FilePath copyWith({String? url, String? local}) {
    return FilePath(url: url ?? this.url, local: local ?? this.local);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{'url': url, 'local': local};

  factory FilePath.fromMap(Map<String, dynamic> map) =>
      FilePath(url: map['url'] as String? ?? '', local: map['local'] as String? ?? '');

  String toJson() => json.encode(toMap());

  factory FilePath.fromJson(String source) {
    if (source.isEmpty) return FilePath();

    try {
      return FilePath.fromMap(json.decode(source) as Map<String, dynamic>);
    } catch (e) {
      log("Error converting FilePath from map: $e");
      return FilePath();
    }
  }

  @override
  String toString() => 'FilePath(url: $url, local: $local)';

  @override
  bool operator ==(covariant FilePath other) {
    if (identical(this, other)) return true;

    return other.url == url && other.local == local;
  }

  @override
  int get hashCode => url.hashCode ^ local.hashCode;
}

extension FilePathStringExtension on String {
  // FilePath get fileDetails => isEmpty ? FilePath.fromJson('{}') : FilePath.fromJson(this);
  // bool get containsFilePath => url.isNotEmpty || local.isNotEmpty;
  // bool get containsAnyFilePath => containsFilePath;
}
