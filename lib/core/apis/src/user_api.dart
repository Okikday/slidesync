part of '../api.dart';

class _UserApi {
  Future<Result<UserEntity?>> get(String uid) =>
      Result.tryRunAsync(() async {
        final doc = await ApiPaths.user(uid).get();
        return doc.data();
      });

  /// Stream for real-time courseCount / verified state — use in Riverpod provider.
  Stream<UserEntity?> stream(String uid) =>
      ApiPaths.user(uid).snapshots().map((s) => s.data());

  /// Called on first sign-in. merge:true means safe to call repeatedly.
  Future<Result<void>> initUser(String uid) =>
      Result.tryRunAsync(() => FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'courseCount': 0, 'verified': false},
              SetOptions(merge: true)));
}
