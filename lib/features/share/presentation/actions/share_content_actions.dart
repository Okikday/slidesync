// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/share/domain/usecases/share_content_uc.dart';
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
    final origFilename = (metadata['originalFilename']);
    final fileName = (metadata['filename'] ?? metadata['fileName']) as String? ?? content.title;

    ShareContentUc().shareFile(
      context,
      File(content.path.filePath),
      filename: origFilename ?? p.setExtension(fileName, p.extension(content.path.filePath)),
    );
  }
}
