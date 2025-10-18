import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slidesync/core/constants/src/enums.dart';
// import 'package:printing/printing.dart';
import 'package:slidesync/core/utils/file_utils.dart';


class ShareContentUc {
  Future<void> shareText(BuildContext context, String text, {String? title, File? previewThumbnail}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: title ?? "SlideSync", previewThumbnail: await _genPreview(previewThumbnail)),
    );
  }

  Future<void> shareFile(
    BuildContext context,
    File file, {
    String? filename,
    String? title,
    File? previewThumbnail,
  }) async {
    final String path;

    if (filename != null) {
      final res = await FileUtils.storeFile(file: file, base: AppDirType.temporary, newFileName: filename);
      path = res;
    } else {
      path = file.path;
    }

    final xf = XFile(path);

    await SharePlus.instance.share(
      ShareParams(
        files: [xf],
        title: "Sharing from SlideSync",
        text: title,
        subject: title ?? "SlideSync",
        previewThumbnail: await _genPreview(previewThumbnail),
      ),
    );
  }

  Future<void> shareFileFromBytes(
    BuildContext context,
    Uint8List bytes,
    String filename, {
    String? title,
    File? previewThumbnail,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/$filename';
    final tempFile = File(path);
    await tempFile.writeAsBytes(bytes, flush: true);

    final xf = XFile(tempFile.path);

    await SharePlus.instance.share(
      ShareParams(files: [xf], text: title, subject: title, previewThumbnail: await _genPreview(previewThumbnail)),
    );
  }

  Future<XFile?> _genPreview(File? previewThumbnail) async {
    return previewThumbnail != null && await previewThumbnail.exists() ? XFile(previewThumbnail.path) : null;
  }
}
