import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/retrieve_content_uc.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/add_link_actions.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';

class ContentCardActions {
  static Future<FileDetails> resolvePreviewPath(CourseContent content) async {
    switch (content.courseContentType) {
      case CourseContentType.link:
        final String? previewUrl = jsonDecode(content.metadataJson)['previewUrl'] as String?;
        if (previewUrl == null || previewUrl.isEmpty) {
          final args = <String, dynamic>{'url': content.path.urlPath, 'driveApiKey': dotenv.env['DRIVE_API_KEY']};
          final Map<String, String?>? previewMap = await compute(_fetchPreviewWorker, args);
          log("After checking internet: $previewMap");
          if (previewMap == null) return FileDetails();
          final PreviewLinkDetails previewLinkDetails = (
            description: previewMap['description'],
            title: previewMap['title'],
            previewUrl: previewMap['previewUrl'],
          );
          if (previewLinkDetails.isEmpty) {
            return FileDetails();
          }
          await AddLinkActions.onAddLinkContent(
            content.path.urlPath,
            parentId: content.parentId,
            previewLinkDetails: previewLinkDetails,
          );

          return FileDetails(urlPath: previewLinkDetails.previewUrl!);
        } else {
          return FileDetails(urlPath: previewUrl);
        }
      default:
        return FileDetails(
          filePath: CreateContentPreviewImage.genPreviewImagePath(filePath: content.path.filePath),
          urlPath: content.path.urlPath,
        );
    }
  }

  static Future<Map<String, String?>?> _fetchPreviewWorker(Map<String, dynamic> args) async {
    final url = args['url'] ?? '';
    // final driveApiKey = args['driveApiKey'];
    // final isDriveLink = DriveBrowser.isGoogleDriveLink(url);
    final PreviewLinkDetails? data;
    data = await RetriveContentUc.getLinkPreviewData(url);

    // if (isDriveLink) {
    //   final rawData = await DriveBrowser.fetchResourceFromLink(url, apiKey: driveApiKey);
    //   data = (
    //     title: rawData.file?.name,
    //     description: rawData.file?.description,
    //     previewUrl: rawData.file?.thumbnailLink ?? rawData.file?.iconLink,
    //   );
    // } else {
    //   data = await RetriveContentUc.getLinkPreviewData(url);
    // }

    if (data == null) return null;
    return {'title': data.title, 'description': data.description, 'previewUrl': data.previewUrl};
  }

  static String resolveExtension(CourseContent content) {
    final res = p.extension(content.path.filePath).replaceAll('.', '').toUpperCase();
    switch (content.courseContentType) {
      case CourseContentType.image:
        return res;
      case CourseContentType.document:
        return res;
      case CourseContentType.link:
        return "link";
      default:
        return '';
    }
  }
}
