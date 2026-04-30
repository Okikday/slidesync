// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/share/logic/usecases/share_content_uc.dart';

class ShareContentActions {
  static Future<void> shareContent(BuildContext context, String contentId) async {
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return;

    if (content.type == ModuleContentType.link) {
      final url = content.path.url ?? '';
      if (url.isEmpty) {
        UiUtils.showFlushBar(context, msg: "No link to share.");
        return;
      }
      UiUtils.showFlushBar(context, msg: "Preparing content...");
      await ShareContentUc().shareText(context, url, title: content.title);
      return;
    }

    if (content.type == ModuleContentType.document ||
        content.type == ModuleContentType.image ||
        content.type == ModuleContentType.unknown) {
      await ShareContentActions.shareFileContent(context, content.uid);
      return;
    }

    UiUtils.showFlushBar(context, msg: "Sharing not supported!");
  }

  static Future<void> shareFileContent(BuildContext context, String contentId) async {
    final content = await ModuleContentRepo.getByUid(contentId);
    if (content == null) return;

    final localPath = content.path.local ?? '';

    // If no local file, fall back to sharing the URL as text
    if (localPath.isEmpty) {
      final url = content.path.url ?? '';
      if (url.isEmpty) {
        UiUtils.showFlushBar(context, msg: "Nothing to share.");
        return;
      }
      UiUtils.showFlushBar(context, msg: "Preparing content...");
      await ShareContentUc().shareText(context, '${content.title}\n$url', title: content.title);
      return;
    }

    UiUtils.showFlushBar(context, msg: "Preparing file...");
    final origFilename = content.metadata?.originalFileName;
    await ShareContentUc().shareFile(
      context,
      File(localPath),
      filename: origFilename ?? p.setExtension(content.title, p.extension(localPath)),
    );
  }

  static Future<void> shareCollection(BuildContext context, String collectionId) async {
    UiUtils.showFlushBar(context, msg: "Preparing files...");
    final collection = await ModuleRepo.getByUid(collectionId);
    if (collection == null) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }

    await collection.contents.load();
    final contents = UnmodifiableListView(collection.contents);

    if (contents.isEmpty) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }

    await _shareContentList(context, contents);
  }

  static Future<void> shareContents(BuildContext context, List<String> contentIds) async {
    if (contentIds.isEmpty) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }

    UiUtils.showFlushBar(context, msg: "Preparing files...");

    // Single batch fetch instead of anyOf query
    final fetched = await ModuleContentRepo.getAllByUids(contentIds);
    final contents = fetched.whereType<ModuleContent>().toList();

    if (contents.isEmpty) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }

    await _shareContentList(context, contents);
  }

  /// Shared logic: splits contents into files + links, shares both together.
  static Future<void> _shareContentList(BuildContext context, List<ModuleContent> contents) async {
    final List<File> files = [];
    final List<String?> fileNames = [];
    final List<String> linkTexts = [];

    for (final e in contents) {
      if (e.type == ModuleContentType.link) {
        final url = e.path.url ?? '';
        if (url.isNotEmpty) {
          // Format: "Title\nURL" so receiving apps show them clearly
          linkTexts.add('${e.title}\n$url');
        }
        continue;
      }

      final localPath = e.path.local ?? '';

      if (localPath.isEmpty) {
        // No local file — try URL fallback as a link-style text entry
        final url = e.path.url ?? '';
        if (url.isNotEmpty) {
          linkTexts.add('${e.title}\n$url');
        }
        continue;
      }

      files.add(File(localPath));
      fileNames.add(e.metadata?.originalFileName ?? p.setExtension(e.title, p.extension(localPath)));
    }

    final bool hasFiles = files.isNotEmpty;
    final bool hasLinks = linkTexts.isNotEmpty;

    if (!hasFiles && !hasLinks) {
      UiUtils.showFlushBar(context, msg: "Nothing to share");
      return;
    }

    if (!hasFiles && hasLinks) {
      // Links only — share as text
      await ShareContentUc().shareText(context, linkTexts.join('\n\n'));
      return;
    }

    // Files (+ optional appended links as text)
    await ShareContentUc().shareFiles(context, files, filenames: fileNames, linkTexts: hasLinks ? linkTexts : null);
  }
}
