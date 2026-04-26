import 'package:flutter/services.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';

class IsolateContentFetchParams {
  final String collectionId;
  final int pageKey;
  final int limit;
  final EntityOrdering contentOrdering;
  final RootIsolateToken token;

  IsolateContentFetchParams({
    required this.collectionId,
    required this.pageKey,
    required this.limit,
    required this.contentOrdering,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'pageKey': pageKey,
      'limit': limit,
      'contentOrdering': contentOrdering.index,
      'token': token,
    };
  }

  factory IsolateContentFetchParams.fromMap(Map<String, dynamic> map) {
    final sortRaw = map['contentOrdering'] as int?;
    final sort = sortRaw == null ? EntityOrdering.dateModifiedDesc : EntityOrdering.values[sortRaw];

    return IsolateContentFetchParams(
      collectionId: map['collectionId'] as String,
      pageKey: map['pageKey'] as int,
      limit: map['limit'] as int,
      contentOrdering: sort,
      token: map['token'] as RootIsolateToken,
    );
  }
}
