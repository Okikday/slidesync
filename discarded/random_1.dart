
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


  
  /// BasicUtils
    // static Future<String> calculatePartialHash(String path, {int chunkSize = 32 * 1024}) async {
  //   final file = File(path);
  //   if (!await file.exists()) {
  //     throw FileSystemException('File does not exist', path);
  //   }

  //   final length = await file.length();

  //   // Setup sha sink
  //   final completer = Completer<Digest>();
  //   final outSink = ChunkedConversionSink<Digest>.withCallback((digests) {
  //     completer.complete(digests.single);
  //   });
  //   final hashSink = sha256.startChunkedConversion(outSink);

  //   try {
  //     if (length <= chunkSize * 2) {
  //       // small file: stream whole file (no large alloc)
  //       await for (final chunk in file.openRead()) {
  //         hashSink.add(chunk);
  //       }
  //     } else {
  //       // Large file: open once and read both chunks using RandomAccessFile
  //       final raf = await file.open();
  //       try {
  //         // Read first chunk
  //         final first = await raf.read(chunkSize);
  //         hashSink.add(first);

  //         // Seek to last chunk and read
  //         await raf.setPosition(length - chunkSize);
  //         final last = await raf.read(chunkSize);
  //         hashSink.add(last);
  //       } finally {
  //         await raf.close();
  //       }
  //     }

  //     // Mix in size bytes
  //     hashSink.add(utf8.encode(length.toString()));
  //     hashSink.close();

  //     final digest = await completer.future;
  //     return digest.toString();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // static Future<String> calculateFileHash(String path) async {
  //   final file = File(path);
  //   final input = file.openRead(); // Stream<List<int>>
  //   final digest = await sha256.bind(input).first;
  //   return digest.toString();
  // }

