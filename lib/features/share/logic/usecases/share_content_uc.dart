import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/storage_utils/clean_up_utils.dart';
// import 'package:printing/printing.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

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

    if (DeviceUtils.isDesktop()) {
      await Pasteboard.writeFiles([path]);
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Copied file to clipboard"));
      return;
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
    CleanUpUtils().clearCacheOrTemp();
  }

  Future<void> shareFiles(
    BuildContext context,
    List<File> files, {
    List<String?>? filenames, // optional per-file desired names (same length as files or null)
    String? title,
    File? previewThumbnail,
  }) async {
    if (files.isEmpty) return;

    // normalize filenames list length (if provided)
    filenames ??= List<String?>.filled(files.length, null);
    if (filenames.length < files.length) {
      // extend with nulls if too short
      filenames = [...filenames, ...List<String?>.filled(files.length - filenames.length, null)];
    }

    final List<XFile> xfiles = <XFile>[];
    final List<String> filePaths = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final desiredName = filenames[i];

      String path;
      if (desiredName != null && desiredName.trim().isNotEmpty) {
        // storeFile returns path (same as your single-file version)
        final res = await FileUtils.storeFile(file: file, base: AppDirType.temporary, newFileName: desiredName);
        path = res;
      } else {
        path = file.path;
      }

      xfiles.add(XFile(path));
      filePaths.add(path);
    }

    if (DeviceUtils.isDesktop()) {
      await Pasteboard.writeFiles(filePaths);
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Copied file to clipboard"));
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        files: xfiles,
        title: "Sharing from SlideSync",
        text: title,
        subject: title ?? "SlideSync",
        previewThumbnail: previewThumbnail != null ? await _genPreview(previewThumbnail) : null,
      ),
    );

    // Clear any temporary files you created
    await CleanUpUtils().clearCacheOrTemp();
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

  // Future<void> copyFileToClipboard(List<String> filePaths) async {
  //   final clipboard = SystemClipboard.instance;
  //   if (clipboard == null) return;

  //   final item = DataWriterItem();

  //   for (final filePath in filePaths) {
  //     item.add(Formats.fileUri(Uri.file(filePath)));
  //   }

  //   await clipboard.write([item]);
  // }
}
