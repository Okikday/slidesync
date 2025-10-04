import 'dart:isolate';

import 'package:flutter/services.dart';

/// filePaths and uuids should be of same length
class StoreContentArgs {
  final RootIsolateToken token;
  final String collectionId;
  final List<String> filePaths;
  final List<String> uuids;
  final SendPort? port;

  const StoreContentArgs({
    required this.token,
    required this.collectionId,
    required this.filePaths,
    required this.uuids,
    this.port,
  });
}

extension StoreContentArgsExtension on StoreContentArgs {
  StoreContentArgs copyWith({
    RootIsolateToken? token,
    String? collectionId,
    List<String>? filePaths,
    List<String>? uuids,
    SendPort? port,
  }) {
    return StoreContentArgs(
      token: token ?? this.token,
      collectionId: collectionId ?? this.collectionId,
      filePaths: filePaths ?? this.filePaths,
      uuids: uuids ?? this.uuids,
      port: port ?? this.port,
    );
  }
}
