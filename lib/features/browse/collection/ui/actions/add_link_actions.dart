import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/crypto_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/models/file_path/file_path.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/shared/usecases/contents/retrieve_content_uc.dart';
import 'package:super_clipboard/super_clipboard.dart';

class AddLinkActions {
  static Future<bool> onAddLinkContent(
    String link, {
    required String parentId,
    required PreviewLinkDetails previewLinkDetails,
  }) async {
    log("previewLinkDetails: $previewLinkDetails");
    if (parentId.isEmpty) return false;
    final collection = await ModuleRepo.getByUid(parentId);
    if (collection == null) return false;
    final xxh3Hash = CryptoUtils.calculateStringHash(link);
    final ModuleContent? sameHashedContent = await ModuleContentRepo.findFirstDuplicateContentByHash(
      collection,
      xxh3Hash,
    );
    final ModuleContent newContent;
    if (sameHashedContent != null) {
      if (xxh3Hash == sameHashedContent.xxh3Hash && link == sameHashedContent.path.url) {
        if (previewLinkDetails.isEmpty) return false;
        if ((previewLinkDetails.title != null && previewLinkDetails.title == sameHashedContent.title)) {
          if (previewLinkDetails.description != null &&
              previewLinkDetails.description == sameHashedContent.description) {
            if ((previewLinkDetails.previewUrl != null &&
                previewLinkDetails.previewUrl == jsonDecode(sameHashedContent.metadataJson)['previewUrl'])) {
              return false;
            }
          }
        }
        // log("They are the same, modify");

        newContent = sameHashedContent.copyWith(
          xxh3Hash: xxh3Hash,
          title: previewLinkDetails.title != "Unknown link" ? previewLinkDetails.title : "Unknown link",
          description: previewLinkDetails.description != '' ? previewLinkDetails.description : '',
          metadata: ModuleContentMetadata.fromMap({
            ...jsonDecode(sameHashedContent.metadataJson),
            'previewUrl': previewLinkDetails.previewUrl,
          }),
        );
        return await ModuleContentRepo.addMultipleContents(newContent.collectionId, [newContent]);
      }
    } else {
      newContent = ModuleContent.create(
        xxh3Hash: xxh3Hash,
        parentId: collection.uid,
        title: previewLinkDetails.title ?? "Unknown link",
        description: previewLinkDetails.description ?? '',
        path: FilePath(url: link),
        fileSizeInBytes: link.length,
        type: ModuleContentType.link,
        metadata: ModuleContentMetadata.create(fields: {'previewUrl': previewLinkDetails.previewUrl}),
      );
      return await ModuleContentRepo.addMultipleContents(newContent.collectionId, [newContent]);
    }
    return false;
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
