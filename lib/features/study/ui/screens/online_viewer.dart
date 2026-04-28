import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

enum OnlineViewerKind { pdf, image }

class OnlineViewerArgs {
  final String title;
  final String? localPath;
  final String fallbackUrl;
  final OnlineViewerKind kind;

  const OnlineViewerArgs({required this.title, required this.fallbackUrl, required this.kind, this.localPath});
}

class OnlineViewer extends StatelessWidget {
  final OnlineViewerArgs args;

  const OnlineViewer({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: args.title,
      systemUiOverlayStyle: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
      body: switch (args.kind) {
        OnlineViewerKind.pdf => _OnlinePdfBody(args: args),
        OnlineViewerKind.image => _OnlineImageBody(args: args),
      },
    );
  }
}

class _OnlinePdfBody extends StatelessWidget {
  final OnlineViewerArgs args;

  const _OnlinePdfBody({required this.args});

  @override
  Widget build(BuildContext context) {
    final localPath = args.localPath;
    if (localPath != null && localPath.isNotEmpty && File(localPath).existsSync()) {
      return PdfViewer.file(localPath);
    }

    return PdfViewer.uri(Uri.parse(args.fallbackUrl));
  }
}

class _OnlineImageBody extends StatelessWidget {
  final OnlineViewerArgs args;

  const _OnlineImageBody({required this.args});

  @override
  Widget build(BuildContext context) {
    final localPath = args.localPath;
    final hasLocal = localPath != null && localPath.isNotEmpty && File(localPath).existsSync();

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5,
      panEnabled: true,
      child: Center(
        child: hasLocal
            ? Image.file(File(localPath), fit: BoxFit.contain)
            : Image.network(
                args.fallbackUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_outlined, size: 42),
                        const SizedBox(height: 10),
                        const Text('Unable to load image.'),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => launchUrl(Uri.parse(args.fallbackUrl), mode: LaunchMode.externalApplication),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text('Open in browser'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
