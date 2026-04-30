import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/storage_utils/file_utils.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class ShareContentUc {
  Future<void> shareText(BuildContext context, String text, {String? title, File? previewThumbnail}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: title ?? 'SlideSync', previewThumbnail: await _genPreview(previewThumbnail)),
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

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        title: 'Sharing from SlideSync',
        text: title,
        subject: title ?? 'SlideSync',
        previewThumbnail: await _genPreview(previewThumbnail),
      ),
    );
  }

  Future<void> shareFiles(
    BuildContext context,
    List<File> files, {
    List<String?>? filenames,
    String? title,
    File? previewThumbnail,

    /// Optional link texts to append alongside the files (e.g. "Title\nURL")
    List<String>? linkTexts,
  }) async {
    if (files.isEmpty) return;

    // Normalize filenames length
    filenames ??= List<String?>.filled(files.length, null);
    if (filenames.length < files.length) {
      filenames = [...filenames, ...List<String?>.filled(files.length - filenames.length, null)];
    }

    // Resolve all file paths in parallel
    final resolvedPaths = await Future.wait([
      for (int i = 0; i < files.length; i++) _resolvePath(files[i], filenames[i]),
    ]);

    final validPaths = resolvedPaths.whereType<String>().toList();
    if (validPaths.isEmpty) return;

    if (DeviceUtils.isDesktop()) {
      await Pasteboard.writeFiles(validPaths);
      GlobalNav.withContext((context) => UiUtils.showFlushBar(context, msg: "Copied files to clipboard"));
      return;
    }

    final xfiles = validPaths.map(XFile.new).toList();

    // Append link texts to the share body if provided
    final String? shareText = (linkTexts != null && linkTexts.isNotEmpty) ? linkTexts.join('\n\n') : title;

    await SharePlus.instance.share(
      ShareParams(
        files: xfiles,
        title: 'Sharing from SlideSync',
        text: shareText,
        subject: title ?? 'SlideSync',
        previewThumbnail: previewThumbnail != null ? await _genPreview(previewThumbnail) : null,
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
    await File(path).writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        text: title,
        subject: title,
        previewThumbnail: await _genPreview(previewThumbnail),
      ),
    );
  }

  /// Resolves a file to its final share path (renaming to [desiredName] if needed).
  /// Returns null if the operation fails, so the file is skipped.
  Future<String?> _resolvePath(File file, String? desiredName) async {
    if (desiredName != null && desiredName.trim().isNotEmpty) {
      return Result.fromAsync(
        () => FileUtils.storeFile(file: file, base: AppDirType.temporary, newFileName: desiredName),
        fallback: null,
      );
    }
    return file.path;
  }

  Future<XFile?> _genPreview(File? previewThumbnail) async {
    if (previewThumbnail == null) return null;
    return await previewThumbnail.exists() ? XFile(previewThumbnail.path) : null;
  }
}
