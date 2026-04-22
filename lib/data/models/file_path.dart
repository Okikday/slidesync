// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:isar_community/isar.dart';

part 'file_path.g.dart';

@embedded
class FilePath {
  String url;
  String local;
  FilePath({this.url = '', this.local = ''});

  bool get containsFilePath => url.isNotEmpty || local.isNotEmpty;

  FilePath copyWith({String? url, String? local}) {
    return FilePath(url: url ?? this.url, local: local ?? this.local);
  }

  Map<String, String> toMap() => <String, String>{'url': url, 'local': local};

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
  FilePath get fileDetails => isEmpty ? FilePath.fromJson('{}') : FilePath.fromJson(this);
  bool get containsFilePath => url.isNotEmpty || local.isNotEmpty;
  bool get containsAnyFilePath => containsFilePath;
  String get local => fileDetails.local;
  String get url => fileDetails.url;
}
