import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slidesync/domain/models/file_details.dart';

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class BuildImagePathWidget extends ConsumerStatefulWidget {
  final FileDetails fileDetails;
  final Widget fallbackWidget;
  final BoxFit fit;
  final double? width;
  final double? height;
  const BuildImagePathWidget({
    super.key,
    required this.fileDetails,
    this.fallbackWidget = const Icon(Iconsax.document),
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BuildImagePathWidgetState();
}

class _BuildImagePathWidgetState extends ConsumerState<BuildImagePathWidget> {
  Uint8List? imageBytes;
  DateTime? _lastModified;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  @override
  void didUpdateWidget(covariant BuildImagePathWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldPath = oldWidget.fileDetails.filePath;
    final newPath = widget.fileDetails.filePath;

    if (newPath.isNotEmpty) {
      final file = File(newPath);
      if (file.existsSync()) {
        final newModified = file.lastModifiedSync();
        if (oldPath != newPath || _lastModified == null || newModified != _lastModified) {
          _loadImageBytes();
        }
      }
    }
  }

  void _loadImageBytes() {
    final filePath = widget.fileDetails.filePath;
    if (filePath.isNotEmpty && File(filePath).existsSync()) {
      final file = File(filePath);
      final bytes = file.readAsBytesSync();
      final modified = file.lastModifiedSync();

      if (_lastModified != modified) {
        setState(() {
          imageBytes = bytes;
          _lastModified = modified;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileDetails = widget.fileDetails;
    final fallbackWidget = widget.fallbackWidget;
    final fit = widget.fit;
    final width = widget.width;
    final height = widget.height;

    if (!fileDetails.containsFilePath) return fallbackWidget;

    if (fileDetails.filePath.isNotEmpty && imageBytes != null) {
      return ImageFromMemory(
        imageBytes: imageBytes,
        fit: fit,
        width: width,
        height: height,
        fallbackWidget: fallbackWidget,
      ).animate().fadeIn();
    } else if (fileDetails.urlPath.isNotEmpty) {
      return ImageFromNetwork(
        fileDetails: fileDetails,
        fit: fit,
        width: width,
        height: height,
        fallbackWidget: fallbackWidget,
      ).animate().fadeIn();
    }

    return fallbackWidget;
  }
}

class ImageFromNetwork extends StatelessWidget {
  const ImageFromNetwork({
    super.key,
    required this.fileDetails,
    required this.fit,
    required this.width,
    required this.height,
    required this.fallbackWidget,
  });

  final FileDetails fileDetails;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallbackWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: fileDetails.urlPath,
      fit: fit,
      width: width,
      height: height,
      progressIndicatorBuilder: (context, url, progress) {
        return Skeletonizer(child: SizedBox.expand());
      },
      errorWidget: (context, error, stackTrace) => fallbackWidget,
    );
  }
}

class ImageFromMemory extends ConsumerWidget {
  const ImageFromMemory({
    super.key,
    required this.imageBytes,
    required this.fit,
    required this.width,
    required this.height,
    required this.fallbackWidget,
  });

  final Uint8List? imageBytes;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget fallbackWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Image.memory(
      imageBytes!,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        } else {
          return SizedBox.expand(child: ColoredBox(color: ref.primaryColor.withAlpha(40)))
              .animate(onComplete: (controller) => controller.repeat())
              .shimmer(duration: const Duration(seconds: 1), curve: Curves.decelerate)
              .blurXY(begin: 2, end: 0, duration: Duration(seconds: 1))
              .animate(onComplete: (controller) => controller.repeat(reverse: true))
              .tint(color: ref.primaryColor.withAlpha(10), duration: Duration(seconds: 1));
        }
      },
      errorBuilder: (context, error, stackTrace) => fallbackWidget,
    );
  }
}
