import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class DesktopDropWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final Function(List<String> filePaths)? onFilesDropped;

  const DesktopDropWrapper({super.key, required this.child, this.onFilesDropped});

  @override
  ConsumerState<DesktopDropWrapper> createState() => _DesktopDropWrapperState();
}

class _DesktopDropWrapperState extends ConsumerState<DesktopDropWrapper> {
  bool _isDragging = false;
  int _fileCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        log("Dropped something");
        // Allow drop operation
        if (!_isDragging) {
          setState(() {
            _isDragging = true;
            _fileCount = event.session.items.length;
          });
        }
        return DropOperation.copy;
      },
      onDropLeave: (event) {
        log("Dropped something");
        setState(() {
          _isDragging = false;
          _fileCount = 0;
        });
      },
      onPerformDrop: (event) async {
        log("Dropped something");
        setState(() {
          _isDragging = false;
          _fileCount = 0;
        });

        final filePaths = <String>[];

        for (final item in event.session.items) {
          final reader = item.dataReader!;

          // Check if item can provide file URI
          if (reader.canProvide(Formats.fileUri)) {
            reader.getValue<Uri>(
              Formats.fileUri,
              (uri) {
                if (uri != null) {
                  filePaths.add(uri.toFilePath());
                }
              },
              onError: (error) {
                debugPrint('Error reading file: $error');
              },
            );
          }
        }

        await Future.delayed(const Duration(milliseconds: 100));

        if (filePaths.isNotEmpty && widget.onFilesDropped != null) {
          widget.onFilesDropped!(filePaths);
        }
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            widget.child,

            // Overlay when dragging
            if (_isDragging) Positioned.fill(child: _DragOverlay(fileCount: _fileCount)),
          ],
        ),
      ),
    );
  }
}

class _DragOverlay extends ConsumerWidget {
  final int fileCount;

  const _DragOverlay({required this.fileCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ref.primary.withValues(alpha: 0.15), ref.secondary.withValues(alpha: 0.15)],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: ref.primary, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [ref.primary.withValues(alpha: 0.3), ref.secondary.withValues(alpha: 0.3)],
                        ),
                        boxShadow: [
                          BoxShadow(color: ref.primary.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 10),
                        ],
                      ),
                      child: Icon(Icons.upload_file_rounded, size: 64, color: ref.primary),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Title text
              Text(
                'Drop to add files',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ref.onBackground,
                  fontFamily: ref.fontFamily,
                ),
              ),

              const SizedBox(height: 12),

              // File count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ref.primary.withValues(alpha: 0.2), ref.secondary.withValues(alpha: 0.2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ref.primary.withValues(alpha: 0.5), width: 1),
                ),
                child: Text(
                  '$fileCount file${fileCount != 1 ? 's' : ''} ready',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ref.primary,
                    fontFamily: ref.fontFamily,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Supporting text
              Text(
                'Release to select a collection',
                style: TextStyle(fontSize: 14, color: ref.supportingText, fontFamily: ref.fontFamily),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
