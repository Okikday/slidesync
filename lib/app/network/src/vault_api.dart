part of '../api.dart';

class _VaultApi {
  // ── Vault links (admin CRUD) ───────────────────────────────────────────────

  Query<VaultEntity> query() => ApiPaths.storageVault().orderBy('createdAt', descending: true);

  Future<Result<List<VaultEntity>?>> listVaults({int limit = 50}) => Result.tryRunAsync(() async {
    final snapshot = await query().limit(limit).get();
    return snapshot.docs.map((d) => d.data()).toList();
  });

  Future<Result<VaultEntity?>> getVault(String linkId) => Result.tryRunAsync(() async {
    final doc = await ApiPaths.vaultEntry(linkId).get();
    return doc.data();
  });

  Future<Result<String?>> createVault(CreateVaultInput input) => Result.tryRunAsync(() async {
    final ref = ApiPaths.storageVault().doc();
    await FirebaseFirestore.instance.collection('storageVault').doc(ref.id).set(VaultEntity.createMap(ref.id, input));
    return ref.id;
  });

  Future<Result<void>> updateVault(String linkId, UpdateVaultInput input) =>
      Result.tryRunAsync(() => ApiPaths.vaultEntry(linkId).update(input.toMap()));

  Future<Result<void>> deleteVault(String linkId) => Result.tryRunAsync(() => ApiPaths.vaultEntry(linkId).delete());

  // /// Debug helper: return current Firebase Auth UID and email so developer
  // /// can copy the UID and add it to /admins via the Firebase Console.
  // Future<Result<Map<String, String?>>> currentAuthInfo() => Result.tryRunAsync(() async {
  //   log("Getting usr");
  //   final user = FirebaseAuth.instance.currentUser;
  //   log("uid: ${user?.uid}, email: ${user?.email}");
  //   return {'uid': user?.uid, 'email': user?.email};
  // }).then((v) => Result.success(v.data ?? {}));

  // ── Upload log (paginated) ─────────────────────────────────────────────────

  Query<VaultUploadEntity> uploadsQuery(String linkId) =>
      ApiPaths.vaultUploads(linkId).orderBy('uploadedAt', descending: true);

  Future<Result<PageResult<VaultUploadEntity>?>> listUploads({
    required String linkId,
    int limit = 30,
    DocumentSnapshot<VaultUploadEntity>? startAfter,
  }) => Result.tryRunAsync(() async {
    Query<VaultUploadEntity> q = uploadsQuery(linkId).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snapshot = await q.get();
    return PageResult(
      items: snapshot.docs.map((d) => d.data()).toList(),
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  });

  // ── Atomic batch: log upload + register source ────────────────────────────
  //
  // Both writes succeed or neither does.
  // Vault upload log → /storageVault/{linkId}/uploads/{uploadId}
  // Source entry     → /content-lookup/{xxh3Hash}/sources/{uid}

  Future<Result<String?>> logUploadWithSource({
    required String linkId,
    required LogUploadInput uploadInput,
    required CreateSourceInput sourceInput,
  }) => Result.tryRunAsync(() async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // 1. Vault upload log
    final uploadRef = db.collection('storageVault').doc(linkId).collection('uploads').doc(); // auto UUID
    batch.set(uploadRef, VaultUploadEntity.createMap(uploadRef.id, uploadInput));

    // 2. Content-lookup hash doc (immutable — only create if missing)
    final hashRef = db.collection('content-lookup').doc(uploadInput.xxh3Hash);
    final hashSnap = await hashRef.get();
    if (!hashSnap.exists) {
      batch.set(hashRef, {'xxh3Hash': uploadInput.xxh3Hash, 'createdAt': FieldValue.serverTimestamp()});
    }

    // 3. Source entry under the hash
    final sourceRef = db
        .collection('content-lookup')
        .doc(uploadInput.xxh3Hash)
        .collection('sources')
        .doc(uploadInput.uploadedBy); // one source per user per hash
    batch.set(sourceRef, SourceEntity.createMap(sourceInput));

    await batch.commit();
    return uploadRef.id;
  });
}
