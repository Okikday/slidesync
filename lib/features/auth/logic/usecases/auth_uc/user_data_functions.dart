import 'dart:developer';

// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:slidesync/core/storage/hive_data/hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/auth/logic/models/user_credential_model.dart';

class UserDataFunctions {
  static final _path = HiveDataKey.userData.name;
  KVStore get store => KVStore.me;

  static final me = const UserDataFunctions._();

  const UserDataFunctions._();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _pathUserCredentialMap = "user_credential";

  Future<Result<bool>> saveUserDetails({
    String? googleIDToken,
    String? googleAccessToken,
    required UserCredentialModel userCredentialModel,
  }) async {
    try {
      if (googleIDToken != null) {
        await _secureStorage.write(key: "googleIDToken", value: googleIDToken);
      }
      if (googleAccessToken != null) {
        await _secureStorage.write(
          key: "googleAccessToken",
          value: googleAccessToken,
        );
      }

      await store.setData(
        key: "$_path/$_pathUserCredentialMap",
        value: userCredentialModel.toMap(),
      );

      return Result.success(true, logMsg: "Successfully saved user details!");
    } catch (e) {
      return Result.error("Error: $e");
    }
  }

  Future<Result<bool>> clearUserDetails() async {
    try {
      // Clear stored tokens and user information
      await _secureStorage.delete(key: 'googleIDToken');
      await _secureStorage.delete(key: 'googleAccessToken');
      // await hiveData.deleteData(key: "$_path/$pathUserCredentialMap");
      try {
        await store.deleteData(key: "$_path/$_pathUserCredentialMap");
      } catch (e) {
        log("Error deleting user Data, $e");
      }
      log("Successfully cleared user's data");
      return Result.success(true);
    } catch (e) {
      return Result.error("Error: $e");
    }
  }

  Future<Result<UserCredentialModel?>> getUserDetails() async {
    try {
      final userData = await store.getData(
        key: "$_path/$_pathUserCredentialMap",
      );

      if (userData == null) return Result.error("Couldn't load user's data");

      // Create the UserCredentialModel from the fetched data
      final user = UserCredentialModel.fromMap(
        Map<String, dynamic>.from(userData),
      );
      return Result.success(user);
    } catch (e) {
      return Result.error("Failed to fetch user details: ${e.toString()}");
    }
  }

  Future<Result<String>> getUserId() async {
    try {
      final userData = await store.getData(
        key: "$_path/$_pathUserCredentialMap",
      );
      if (userData == null) return Result.error("Unable to fetch user data");
      // Create the UserCredentialModel from the fetched data
      final UserCredentialModel user = UserCredentialModel.fromMap(
        Map<String, dynamic>.from(userData),
      );
      return Result.success(user.userID);
    } catch (e) {
      return Result.error("error: $e");
    }
  }

  bool isUserSignedIn() {
    try {
      final userData = store.getData(key: "$_path/$_pathUserCredentialMap");
      if (userData == null) return false;
      // Create the UserCredentialModel from the fetched data
      final user = UserCredentialModel.fromMap(
        Map<String, dynamic>.from(userData),
      );
      return user.userID.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
