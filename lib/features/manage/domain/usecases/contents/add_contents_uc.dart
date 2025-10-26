import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/select_contents_uc.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/store_contents.dart';
import 'package:slidesync/features/manage/domain/usecases/types/add_content_result.dart';
import 'package:slidesync/features/manage/domain/usecases/types/store_content_args.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:uuid/uuid.dart';

class AddContentsUc {
  static Future<List<AddContentResult>> _processAndStoreContents({
    required CourseCollection collection,
    required List<String> filePaths,
    required List<String> uuids,
    required RootIsolateToken rootIsolateToken,
    ValueNotifier<String>? valueNotifier,
  }) async {
    final uuidFileNames = [
      for (int i = 0; i < filePaths.length; i++) p.setExtension(uuids[i], p.extension(filePaths[i])),
    ];

    await Result.tryRunAsync(() async {
      await AppHiveData.instance.setData(
        key: HiveDataPathKey.contentsAddingProgressList.name,
        value: <String, dynamic>{
          for (int i = 0; i < uuidFileNames.length; i++) uuidFileNames[i]: filePaths[i],
          'collectionId': collection.collectionId,
        },
      );
    });

    final args = StoreContentArgs(
      token: rootIsolateToken,
      collectionId: collection.collectionId,
      filePaths: filePaths,
      uuids: uuids,
      deleteCache: true,
    ).toMap();

    final result = await storeContents(args, valueNotifier);

    await Result.tryRunAsync(() async {
      await AppHiveData.instance.deleteData(key: HiveDataPathKey.contentsAddingProgressList.name);
    });

    log("Done");
    final resultList = result.map((e) => AddContentResult.fromMap(e)).toList();

    await AppHiveData.instance.setData(
      key: HiveDataPathKey.globalFileSizeSum.name,
      value: resultList.fold<int>(0, (prev, next) => prev + (next.fileSize ?? 0)),
    );

    return resultList;
  }

  static Future<List<AddContentResult>> addToCollection({
    required CourseCollection collection,
    required CourseContentType type,
    ValueNotifier<String>? valueNotifier,
  }) async {
    log("Consulting add to collections...");
    final Result<dynamic> outcome = await Result.tryRunAsync(() async {
      if (valueNotifier != null) valueNotifier.value = "Consulting system selection";
      if (rootNavigatorKey.currentContext!.mounted) {
        GlobalNav.popGlobal();
      }
      UiUtils.showLoadingDialog(rootNavigatorKey.currentContext!, message: "Consulting system selection");

      final selectedContents = await SelectContentsUc().referToAddContents(type);
      valueNotifier?.value = "Scanning contents";
      if (rootNavigatorKey.currentContext!.mounted) {
        Navigator.pop(rootNavigatorKey.currentContext!);
      }
      if (selectedContents == null) return "No content was selected!";

      final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) return "Unable to process adding content in background";

      valueNotifier?.value =
          "Adding contents...\nPlease, do not close app until this is complete.\nClosing app abruptly might take up more space";

      final filePaths = <String>[for (final value in selectedContents) value.path];
      final uuids = [for (int i = 0; i < filePaths.length; i++) const Uuid().v4()];

      // Use shared method
      return await _processAndStoreContents(
        collection: collection,
        filePaths: filePaths,
        uuids: uuids,
        rootIsolateToken: rootIsolateToken,
        valueNotifier: valueNotifier,
      );
    });

    if (outcome.isSuccess && outcome.data is List) {
      return outcome.data as List<AddContentResult>;
    } else {
      log("An error occurred while adding to collection! => ${outcome.data}");
      log("${outcome.message}");
      return [];
    }
  }

  static Future<List<AddContentResult>> addToCollectionNoRef({
    required CourseCollection collection,
    required List<String> filePaths,
    ValueNotifier<String>? valueNotifier,
  }) async {
    log("Adding to collection without ref...");
    final Result<dynamic> outcome = await Result.tryRunAsync(() async {
      if (valueNotifier != null) valueNotifier.value = "Scanning contents";

      if (filePaths.isEmpty) return "No content was selected!";

      final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) return "Unable to process adding content in background";

      valueNotifier?.value =
          "Adding contents...\nPlease, do not close app until this is complete.\nClosing app abruptly might take up more space";

      final uuids = [for (int i = 0; i < filePaths.length; i++) const Uuid().v4()];

      // Use shared method
      return await _processAndStoreContents(
        collection: collection,
        filePaths: filePaths,
        uuids: uuids,
        rootIsolateToken: rootIsolateToken,
        valueNotifier: valueNotifier,
      );
    });

    if (outcome.isSuccess && outcome.data is List) {
      return outcome.data as List<AddContentResult>;
    } else {
      log("An error occurred while adding to collection! => ${outcome.data}");
      log("${outcome.message}");
      return [];
    }
  }

  // static Future<void> resumeFromLastAddToCollection(
  //   Map<String, dynamic> selectedContentPathsOnStorage,
  //   CourseCollection collection,
  // ) async {
  //   GlobalNav.withContext(
  //     (context) => UiUtils.showLoadingDialog(context, canPop: false, message: "Just a moment, initializing..."),
  //   );
  //   final collectionId = selectedContentPathsOnStorage['collectionId'] as String?;
  //   if (collectionId != null) {
  //     log("collectionId");
  //     final lastCollection = await CourseCollectionRepo.getById(collectionId);
  //     log("lastCollection: $lastCollection");
  //     if (lastCollection != null) {
  //       selectedContentPathsOnStorage.remove('collectionId');
  //       log("selected: $selectedContentPathsOnStorage");
  //       final baseDir = await FileUtils.getAppDocumentsDirectory();
  //       final targetDir = Directory(p.join(baseDir.path, lastCollection.absolutePath));
  //       if (!(await targetDir.exists())) {
  //         await targetDir.create(recursive: true);
  //       }
  //       List<String> alreadyExists = [];
  //       List<String> toRemoveUuidWithExt = [];
  //       for (final uuidWithExt in selectedContentPathsOnStorage.keys) {
  //         log("UuidwithExt: $uuidWithExt");
  //         final dir = p.join(targetDir.path, uuidWithExt);
  //         if ((await File(dir).exists())) {
  //           alreadyExists.add(dir);
  //           toRemoveUuidWithExt.add(uuidWithExt);
  //           continue;
  //         }
  //         final filePath = selectedContentPathsOnStorage[uuidWithExt] as String?;
  //         if (filePath == null) continue;
  //         if (!(await File(filePath).exists())) {
  //           toRemoveUuidWithExt.add(uuidWithExt);
  //           continue;
  //         }
  //       }

  //       toRemoveUuidWithExt.map((e) => selectedContentPathsOnStorage.remove(e));

  //       log("alreadyExists: $alreadyExists");
  //       final List<CourseContent> contentsToAdd = [];
  //       for (final uuidWithExtFull in alreadyExists) {
  //         final uuidWithExt = p.basename(uuidWithExtFull);
  //         final filePath = uuidWithExtFull;

  //         final hash = await BasicUtils.calculatePartialHash(filePath);
  //         final fileName = selectedContentPathsOnStorage[uuidWithExt];
  //         final uuid = p.basenameWithoutExtension(uuidWithExt);
  //         final fileNameWithoutExt = p.basenameWithoutExtension(fileName);
  //         final contentType = checkContentType(filePath);
  //         final CourseContent content = CourseContent.create(
  //           contentHash: hash,
  //           contentId: uuid,
  //           title: fileNameWithoutExt,
  //           parentId: collection.collectionId,
  //           fileSize: await FileUtils.getFileSize(filePath),
  //           path: FileDetails(filePath: filePath),
  //           courseContentType: contentType,
  //           metadataJson: jsonEncode(<String, dynamic>{'filename': fileName}),
  //         );
  //         await CreateContentPreviewImage.createPreviewImageForContent(
  //           filePath,
  //           courseContentType: contentType,
  //           filePath: filePath,
  //         );
  //         contentsToAdd.add(content);
  //       }
  //       await CourseContentRepo.addMultipleContents(collectionId, contentsToAdd);
  //       // Done, no more last progress
  //       await AppHiveData.instance.deleteData(key: HiveDataPathKey.contentsAddingProgressList.name);

  //       GlobalNav.withContext((context) => context.pop());
  //       ValueNotifier<String> valueNotifier = ValueNotifier("Loading...");
  //       final entry = OverlayEntry(
  //         builder: (context) => ValueListenableBuilder(
  //           valueListenable: valueNotifier,
  //           builder: (context, value, child) => LoadingOverlay(
  //             message: value,
  //             onCancel: (ref) {
  //               GlobalNav.withContext(
  //                 (c) => UiUtils.showFlushBar(context, msg: "Can't cancel operation Please keep app open"),
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //       GlobalNav.overlay?.insert(entry);
  //       await AddContentsUc.addToCollectionNoRef(
  //         collection: lastCollection,
  //         filePaths: selectedContentPathsOnStorage.values.toList() as List<String>,
  //         valueNotifier: valueNotifier,
  //       );
  //       entry.remove();
  //       valueNotifier.dispose();
  //     }
  //   }
  // }
}
