import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

class TextDocViewer extends ConsumerStatefulWidget {
  final ModuleContent content;

  const TextDocViewer({super.key, required this.content});

  @override
  ConsumerState<TextDocViewer> createState() => _TextDocViewerState();
}

class _TextDocViewerState extends ConsumerState<TextDocViewer> {
  late ScrollController _scrollController;
  late Future<String> _textContentFuture;
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollPosition);
    _textContentFuture = _loadTextContent();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _loadTextContent() async {
    final filePath = widget.content.path.local;
    if (filePath == null || filePath.isEmpty) {
      return 'Could not load content';
    }
    final file = File(filePath);
    if (!await file.exists()) {
      return 'Could not load content';
    }
    return file.readAsString();
  }

  void _updateScrollPosition() {
    final isAtTop = _scrollController.offset <= 0;
    if (isAtTop != _isAtTop) {
      setState(() => _isAtTop = isAtTop);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    UiUtils.showFlushBar(context, msg: 'Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.padding;
    return FutureBuilder<String>(
      future: _textContentFuture,
      builder: (context, snapshot) {
        return AppScaffold(
          title: widget.content.title,
          trailingWidget: BuildButton(
            iconData: HugeIconsSolid.copy01,
            onTap: () {
              final data = snapshot.data;
              if (data == null || data.isEmpty) {
                UiUtils.showFlushBar(context, msg: "Unable to copy content");
                return;
              }
              _copyToClipboard(data);
            },
          ),
          extendBodyBehindAppBar: true,
          systemUiOverlayStyle: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
          body: snapshot.hasData
              ? Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: padding.top + kToolbarHeight + 12,
                      bottom: padding.bottom + 16,
                      left: 16,
                      right: 16,
                    ),
                    child: SelectableText(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 14,
                        color: ref.onBackground,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        height: 1.5,
                      ),
                      onSelectionChanged: (selection, c) {},
                    ),
                  ),
                )
              : snapshot.hasError
              ? Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error loading file: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                )
              : Positioned.fill(child: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
