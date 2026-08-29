import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slidesync/core/utils/result.dart';

/// Abstract base class for Firestore CRUD APIs following the Firebase rules.
/// Enforces consistency across all API implementations.
abstract class FirestoreApiBase {
  /// Fetch a single document by ID.
  /// Must validate ownership/admin permissions per Firebase rules.
  Future<Result<T?>> get<T>(String id);

  /// Stream real-time updates for a document.
  /// Used for Riverpod providers.
  Stream<T?> stream<T>(String id);

  /// List documents with pagination support.
  /// Returns [PageResult] with lastDoc and hasMore flags.
  Future<Result<PageResult<T>?>> list<T>({int limit = 20, DocumentSnapshot<T>? startAfter});

  /// Create a new document.
  /// Returns the generated ID on success.
  /// Must validate user permissions per Firebase rules.
  Future<Result<String?>> create<T>(T data);

  /// Update an existing document.
  /// Must validate ownership/admin permissions per Firebase rules.
  Future<Result<void>> update(String id, Map<String, dynamic> data);

  /// Delete a document.
  /// Must validate ownership/admin permissions per Firebase rules.
  Future<Result<void>> delete(String id);
}

/// Pagination result wrapper for all list() operations.
class PageResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  const PageResult({required this.items, required this.lastDoc, required this.hasMore});
}

/// Abstract base for hierarchical Firestore APIs (nested collections).
/// E.g., courses → collections → contents
abstract class NestedFirestoreApiBase {
  /// Fetch from nested collection: parent/{parentId}/child/{childId}
  Future<Result<T?>> getFromNested<T>(String parentId, String childId);

  /// Stream from nested collection.
  Stream<T?> streamFromNested<T>(String parentId, String childId);

  /// List from nested collection with pagination.
  Future<Result<PageResult<T>?>> listFromNested<T>({
    required String parentId,
    int limit = 20,
    DocumentSnapshot<T>? startAfter,
  });

  /// Create in nested collection.
  Future<Result<String?>> createInNested<T>(String parentId, T data);

  /// Update in nested collection.
  Future<Result<void>> updateInNested(String parentId, String childId, Map<String, dynamic> data);

  /// Delete from nested collection.
  Future<Result<void>> deleteFromNested(String parentId, String childId);
}

/// Abstract for voting mechanism (per Firebase rules).
abstract class VotableApiBase {
  /// Vote for an entity.
  Future<Result<void>> vote({required String entityId, required String userId});

  /// Unvote for an entity.
  Future<Result<void>> unvote({required String entityId, required String userId});

  /// Check if user has voted.
  Future<Result<bool?>> hasVoted({required String entityId, required String userId});

  /// Stream vote state for real-time UI updates.
  Stream<bool> streamVote({required String entityId, required String userId});
}

/// Abstract for flagging mechanism (per Firebase rules).
abstract class FlaggableApiBase {
  /// Flag an entity (with reason, auto-timestamps).
  Future<Result<void>> flag({required String entityId, required String userId, required String reason});

  /// Unflag an entity.
  Future<Result<void>> unflag({required String entityId, required String userId});

  /// Check if user flagged an entity.
  Future<Result<bool?>> hasFlag({required String entityId, required String userId});
}

/// Abstract for content lookup registry (immutable global registry).
abstract class ContentLookupApiBase {
  /// Register content hash in global immutable registry.
  /// Safe to call multiple times — rules enforce no update/delete.
  Future<Result<void>> registerHash(String xxh3Hash);

  /// Check if hash is registered.
  Future<Result<bool?>> isHashRegistered(String xxh3Hash);
}

/// Abstract for batch operations (atomicity).
abstract class BatchableApiBase {
  /// Execute atomic batch write (all or nothing).
  /// Returns batch transaction ID or null on failure.
  Future<Result<String?>> executeBatch(List<BatchOperation> operations);
}

/// Represents a single operation in a batch transaction.
class BatchOperation {
  final String path;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  const BatchOperation({required this.path, required this.type, this.data});
}

enum BatchOperationType { set, update, delete }
