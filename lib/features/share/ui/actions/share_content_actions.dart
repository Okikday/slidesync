// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/share/logic/usecases/share_content_uc.dart';

class ShareContentActions {
  static Future<void> shareContent(BuildContext context, String contentId) async {
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return;
    if (content.type == ModuleContentType.document ||
        content.type == ModuleContentType.image ||
        content.type == ModuleContentType.unknown) {
      ShareContentActions.shareFileContent(context, content.uid);
    } else if (content.type == ModuleContentType.link) {
      UiUtils.showFlushBar(context, msg: "Preparing content...");
      ShareContentUc().shareText(context, content.path.url ?? '');
    } else {
      UiUtils.showFlushBar(context, msg: "Sharing not supported!");
    }
  }

  static Future<void> shareFileContent(BuildContext context, String contentId) async {
    UiUtils.showFlushBar(context, msg: "Preparing file...");
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return;
    final origFilename = (content.metadata?.originalFileName);
    // final fileName = (metadata['filename'] ?? metadata['fileName']) as String? ?? content.title;
    final localPath = content.path.local ?? '';
    await ShareContentUc().shareFile(
      context,
      File(localPath),
      filename: origFilename ?? p.setExtension(content.title, p.extension(localPath)),
    );
  }

  static Future<void> shareCollection(BuildContext context, String collectionId) async {
    UiUtils.showFlushBar(context, msg: "Preparing files...");
    final contents = await (ModuleContentRepo.filter).parentIdEqualTo(collectionId).sortByUid().findAll();
    if (contents.isEmpty) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }
    final Set<(File file, String fileName)> dataSet = contents.map((e) {
      final localPath = e.path.local ?? '';
      return (File(localPath), (e.metadata?.originalFileName) ?? p.setExtension(e.title, p.extension(localPath)));
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
    final contents = await (ModuleContentRepo.filter).anyOf(contentIds, (a, b) => a.uidEqualTo(b)).findAll();
    final Set<(File file, String fileName)> dataSet = contents.map((e) {
      final filename = p.setExtension(e.title, p.extension(e.path.local ?? ''));
      return (
        File(e.path.local ?? ''),
        filename.isEmpty ? ((e.metadata?.originalFileName) ?? "Unknown file") : filename,
      );
    }).toSet();
    final files = dataSet.map((e) => e.$1).toList();
    final fileNames = dataSet.map((e) => e.$2).toList();

    await ShareContentUc().shareFiles(context, files, filenames: fileNames);
  }
}
