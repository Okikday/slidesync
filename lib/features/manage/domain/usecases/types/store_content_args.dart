import 'package:flutter/services.dart';

class StoreContentArgs {
  final RootIsolateToken token;
  final String collectionId;
  final List<String> filePaths;
  final List<String> uuids;

  const StoreContentArgs({
    required this.token,
    required this.collectionId,
    required this.filePaths,
    required this.uuids,
  });

  Map<String, dynamic> toMap() => {
    'token': token,
    'collectionId': collectionId,
    'filePaths': filePaths,
    'uuids': uuids,
  };

  factory StoreContentArgs.fromMap(Map map) => StoreContentArgs(
    token: map['token'] as RootIsolateToken,
    collectionId: map['collectionId'],
    filePaths: List<String>.from(map['filePaths']),
    uuids: List<String>.from(map['uuids']),
  );
}



