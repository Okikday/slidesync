import 'package:dart_mappable/dart_mappable.dart';
import 'package:isar_community/isar.dart';

part 'file_path.mapper.dart';
part 'file_path.g.dart';

@MappableClass()
@Embedded(ignore: {'copyWith'})
class FilePath with FilePathMappable {
  String? url;
  String? local;

  FilePath({this.url, this.local});

  static const fromJson = FilePathMapper.fromJson;
  factory FilePath.empty() => FilePath(url: '', local: '');
}

extension FilePathExtension on FilePath {
  bool get containsLocalPath => (local != null && local!.trim().isNotEmpty);
  bool get containsUrlPath => (url != null && url!.trim().isNotEmpty);
  bool get containsAnyPath => containsLocalPath || containsUrlPath;
}
