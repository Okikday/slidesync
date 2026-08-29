import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:slidesync/core/utils/result.dart';

import 'api_paths.dart';
import 'entities/course_entity.dart';
import 'entities/collection_entity.dart';
import 'entities/content_entity.dart';
import 'entities/source_entity.dart';
import 'entities/misc_entities.dart';
import 'entities/vault_entity.dart';

part 'src/course_api.dart';
part 'src/collection_api.dart';
part 'src/content_api.dart';
part 'src/source_api.dart';
part 'src/vote_api.dart';
part 'src/flag_api.dart';
part 'src/user_api.dart';
part 'src/institution_api.dart';
part 'src/search_api.dart';
part 'src/vault_api.dart';

/// Shared pagination wrapper returned by all list() calls.
class PageResult<T> {
  final List<T> items;

  /// Pass this to the next list() call as [startAfter] to get the next page.
  final DocumentSnapshot? lastDoc;

  /// False when the last page has been reached.
  final bool hasMore;

  const PageResult({required this.items, required this.lastDoc, required this.hasMore});
}

class Api {
  static final _internal = Api._();
  static Api get instance => _internal;
  Api._();

  final courses = _CourseApi();
  final collections = _CollectionApi();
  final content = _ContentApi();
  final sources = _SourceApi();
  final votes = _VoteApi();
  final flags = _FlagApi();
  final users = _UserApi();
  final institutions = _InstitutionApi();
  final search = _SearchApi();
  final vault = _VaultApi();
}
