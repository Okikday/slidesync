// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/share/logic/usecases/share_content_uc.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class ShareContentActions {
  static Future<void> shareContent(BuildContext context, String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return;
    if (content.courseContentType == CourseContentType.document ||
        content.courseContentType == CourseContentType.image ||
        content.courseContentType == CourseContentType.unknown) {
      ShareContentActions.shareFileContent(context, content.contentId);
    } else if (content.courseContentType == CourseContentType.link) {
      UiUtils.showFlushBar(context, msg: "Preparing content...");
      ShareContentUc().shareText(context, content.path.urlPath);
    } else {
      UiUtils.showFlushBar(context, msg: "Sharing not supported!");
    }
  }

  static Future<void> shareFileContent(BuildContext context, String contentId) async {
    UiUtils.showFlushBar(context, msg: "Preparing file...");
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return;
    final metadata = (content.metadataJson.decodeJson);
    final origFilename = (metadata['originalFilename'] as String?);
    // final fileName = (metadata['filename'] ?? metadata['fileName']) as String? ?? content.title;

    await ShareContentUc().shareFile(
      context,
      File(content.path.filePath),
      filename: origFilename ?? p.setExtension(content.title, p.extension(content.path.filePath)),
    );
  }

  static Future<void> shareCollection(BuildContext context, String collectionId) async {
    UiUtils.showFlushBar(context, msg: "Preparing files...");
    final contents = await (await CourseContentRepo.filter).parentIdEqualTo(collectionId).sortByContentId().findAll();
    if (contents.isEmpty) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }
    final Set<(File file, String fileName)> dataSet = contents.map((e) {
      return (
        File(e.path.filePath),
        (e.metadata.originalFileName) ?? p.setExtension(e.title, p.extension(e.path.filePath)),
      );
    }).toSet();
    final files = dataSet.map((e) => e.$1).toList();
    final fileNames = dataSet.map((e) => e.$2).toList();

    await ShareContentUc().shareFiles(context, files, filenames: fileNames);
  }

  static Future<void> shareContents(BuildContext context, List<String> contentIds) async {
    UiUtils.showFlushBar(context, msg: "Preparing files...");
    if (contentIds.isEmpty) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }
    final contents = await (await CourseContentRepo.filter)
        .anyOf(contentIds, (a, b) => a.contentIdEqualTo(b))
        .findAll();
    final Set<(File file, String fileName)> dataSet = contents.map((e) {
      return (
        File(e.path.filePath),
        (e.metadata.originalFileName) ?? p.setExtension(e.title, p.extension(e.path.filePath)),
      );
    }).toSet();
    final files = dataSet.map((e) => e.$1).toList();
    final fileNames = dataSet.map((e) => e.$2).toList();

    await ShareContentUc().shareFiles(context, files, filenames: fileNames);
  }
}
