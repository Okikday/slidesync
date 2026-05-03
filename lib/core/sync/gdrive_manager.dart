import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/app_config.dart';

import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';

import 'entities/drive_file_entity.dart';
import 'entities/drive_progress.dart';
import 'gdrive_paths.dart';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'src/drive_browser.dart';
part 'src/resumable_upload.dart';
part 'src/resumable_download.dart';
part 'src/private_drive.dart';
part 'src/public_drive.dart';
part 'src/gdrive_auth.dart';

class GDriveManager {
  static final _internal = GDriveManager._();
  static GDriveManager get instance => _internal;
  GDriveManager._();

  final auth = GDriveAuth._();
  final browser = _DriveBrowser._();
  final private = _PrivateDrive._();
  final public = _PublicDrive._();

  /// Call once at app startup with the Drive API key from your env config.
  /// Required for all public browsing operations.
  static void init(String apiKey) => GDriveAuth.setApiKey(apiKey);
}
