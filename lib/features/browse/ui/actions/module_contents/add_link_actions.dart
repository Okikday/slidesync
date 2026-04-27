import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/retrieve_content_uc.dart';
import 'package:super_clipboard/super_clipboard.dart';

class AddLinkActions {
  static Future<bool> onAddLinkContent(
    String link, {
    required String parentId,
    required PreviewLinkDetails? details,
  }) async {
    log("previewLinkDetails: $details");
    if (link.isEmpty || parentId.isEmpty) return false;

    final module = await ModuleRepo.getByUid(parentId);
    if (module == null) return false;

    final xxh3Hash = CryptoUtils.calculateStringHash(link);
    final sameHashedContent = await ModuleContentRepo.findFirstDuplicateContentByHash(module, xxh3Hash);

    final ModuleContent newContent;
    final bool isExistingSameLinkInModule = sameHashedContent != null && link == sameHashedContent.path.url;
    if (isExistingSameLinkInModule) {
      // They are the same
      {
        newContent = sameHashedContent.copyWith(
          xxh3Hash: xxh3Hash,
          title: details?.title ?? sameHashedContent.title,
          description: details?.description ?? sameHashedContent.description,
          lastModified: DateTime.now(),
          metadata: sameHashedContent.metadata?.copyWith(
            thumbnail: FilePath(
              url: details?.previewUrl ?? sameHashedContent.metadata?.thumbnail?.url,
              local: sameHashedContent.metadata?.thumbnail?.local,
            ),
          ),
        );
      }
    } else {
      if (link != sameHashedContent?.path.url) {
        details ??= await RetriveContentUc.getLinkPreviewData(link); // Try again
      }
      newContent = ModuleContent.create(
        xxh3Hash: xxh3Hash,
        parentId: module.uid,
        title: details?.title ?? link,
        type: ModuleContentType.link,
        description: details?.description ?? '',
        path: FilePath(url: link),
        metadata: ModuleContentMetadata.create(
          thumbnail: FilePath(url: details?.previewUrl),
          contentOrigin: ContentOrigin.server,
        ),
      );
    }

    // When the same link already exists in this module, update that record directly.
    // Routing through addContent() would attempt to create another ContentTrack with the same uid.
    if (isExistingSameLinkInModule) {
      await ModuleContentRepo.add(newContent);

      final existingTrack = await ContentTrackRepo.getByContentId(newContent.uid);
      if (existingTrack != null) {
        await ContentTrackRepo.add(
          existingTrack.copyWith(
            title: newContent.title,
            description: newContent.description,
            thumbnail: newContent.metadata?.thumbnail ?? existingTrack.thumbnail,
          ),
        );
      }

      return true;
    }

    return await ModuleContentRepo.addContent(newContent.parentId, newContent);
  }

  static void pasteFromClipboard(TextEditingController linkInputController) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final reader = await clipboard.read();

    // Check for URI first (links have priority)
    if (reader.canProvide(Formats.uri)) {
      final NamedUri? namedUri = await reader.readValue(Formats.uri);
      if (namedUri != null && namedUri.uri.toString().isNotEmpty) {
        linkInputController.text = namedUri.uri.toString();
        return;
      }
    }

    // Fallback to plain text and validate if it's a link
    if (reader.canProvide(Formats.plainText)) {
      final String? clipboardText = await reader.readValue(Formats.plainText);
      if (clipboardText != null && clipboardText.isNotEmpty) {
        final text = clipboardText.trim();

        // Try to extract link from text
        final extractedLink = _extractLinkFromText(text);
        if (extractedLink != null) {
          linkInputController.text = extractedLink;
          return;
        }

        // If no link found but text exists, use it as fallback
        linkInputController.text = text;
      }
    }
  }

  static String? _extractLinkFromText(String text) {
    // Check if entire text is a valid URL
    final uri = Uri.tryParse(text);
    if (uri != null && _isValidWebUrl(uri)) {
      return text;
    }

    // Look for URLs within the text using regex
    final urlRegex = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+', caseSensitive: false, multiLine: true);

    final matches = urlRegex.allMatches(text);
    if (matches.isNotEmpty) {
      // Return the most recent (last) link found
      return matches.last.group(0);
    }

    // Look for www. patterns and add https://
    final wwwRegex = RegExp(r'www\.[^\s<>"{}|\\^`\[\]]+', caseSensitive: false, multiLine: true);

    final wwwMatches = wwwRegex.allMatches(text);
    if (wwwMatches.isNotEmpty) {
      return 'https://${wwwMatches.last.group(0)}';
    }

    return null;
  }

  static bool _isValidWebUrl(Uri uri) {
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'ftp') && uri.hasAuthority;
  }
}
