import 'package:path/path.dart' as p;
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';

class ContentCardActions {
  // static void onMoreOptions(BuildContext context, {required CourseContent content}) async {
  //   final Offset? tapPosition = CollectionMaterialsState.cardTapPositionDetails;
  //   if (tapPosition == null) return;
  //   UiUtils.showCustomDialog(
  //     context,
  //     blurSigma: Offset(2, 2),
  //     barrierColor: Colors.black26,
  //     child: ContentCardContextMenu(tapPosition: tapPosition, content: content),
  //   );
  // }
  // static Future<FileDetails> resolvePreviewPath(CourseContent content) async {
  //   switch (content.type) {
  //     case CourseContentType.link:
  //       final String? previewUrl = jsonDecode(content.metadataJson)['previewUrl'] as String?;
  //       if (previewUrl == null || previewUrl.isEmpty) {
  //         final args = <String, dynamic>{'url': content.path.url, 'driveApiKey': dotenv.env['DRIVE_API_KEY']};
  //         final Map<String, String?>? previewMap = await compute(_fetchPreviewWorker, args);
  //         log("After checking internet: $previewMap");
  //         if (previewMap == null) return FileDetails();
  //         final PreviewLinkDetails previewLinkDetails = (
  //           description: previewMap['description'],
  //           title: previewMap['title'],
  //           previewUrl: previewMap['previewUrl'],
  //         );
  //         if (previewLinkDetails.isEmpty) {
  //           return FileDetails();
  //         }
  //         await AddLinkActions.onAddLinkContent(
  //           content.path.url,
  //           parentId: content.parentId,
  //           previewLinkDetails: previewLinkDetails,
  //         );

  //         return FileDetails(urlPath: previewLinkDetails.previewUrl!);
  //       } else {
  //         return FileDetails(urlPath: previewUrl);
  //       }
  //     default:
  //       return FileDetails(filePath: content.previewPath ?? '', urlPath: content.path.url);
  //   }
  // }

  // static Future<Map<String, String?>?> _fetchPreviewWorker(Map<String, dynamic> args) async {
  //   final url = args['url'] ?? '';
  //   // final driveApiKey = args['driveApiKey'];
  //   // final isDriveLink = DriveBrowser.isGoogleDriveLink(url);
  //   final PreviewLinkDetails? data;
  //   data = await RetriveContentUc.getLinkPreviewData(url);

  //   // if (isDriveLink) {
  //   //   final rawData = await DriveBrowser.fetchResourceFromLink(url, apiKey: driveApiKey);
  //   //   data = (
  //   //     title: rawData.file?.name,
  //   //     description: rawData.file?.description,
  //   //     previewUrl: rawData.file?.thumbnailLink ?? rawData.file?.iconLink,
  //   //   );
  //   // } else {
  //   //   data = await RetriveContentUc.getLinkPreviewData(url);
  //   // }

  //   if (data == null) return null;
  //   return {'title': data.title, 'description': data.description, 'previewUrl': data.previewUrl};
  // }

  static String resolveExtension(ModuleContent content) {
    final path = content.path.local;
    if (path == null) return '';
    final res = p.extension(path).replaceAll('.', '').toUpperCase();
    return switch (content.type) {
      ModuleContentType.image || ModuleContentType.document => res,
      ModuleContentType.link => "link",
      _ => res,
    };
  }
}
