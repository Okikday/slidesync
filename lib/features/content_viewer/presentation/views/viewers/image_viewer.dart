import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/domain/models/course_model/sub/course_content.dart';
import 'package:photo_view/photo_view.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/models/progress_track_models/content_track.dart';
import 'package:slidesync/domain/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/domain/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage_all/manage_contents/usecases/create_contents_uc/create_content_preview_image.dart';
import 'package:slidesync/shared/components/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';

class ImageViewer extends ConsumerStatefulWidget {
  final CourseContent content;
  const ImageViewer({super.key, required this.content});

  @override
  ConsumerState<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        await Future.delayed(Duration(seconds: 15), () {
          _createProgressTrackModel(widget.content);
        });
      }
    });
  }

  static Future<ContentTrack?> _createProgressTrackModel(CourseContent content) async {
    final isarData = IsarData.instance<ContentTrack>();
    final result = await Result.tryRunAsync(() async {
      final courseId = (await CourseCollectionRepo.getById(content.parentId))?.parentId;
      if (courseId == null) return null;

      final parentId = (await CourseRepo.getCourseById(courseId))?.courseId;
      if (parentId == null) return null;
      final ContentTrack newPtm = ContentTrack.create(
        contentId: content.contentId,
        parentId: parentId,
        title: content.title,
        description: content.description,
        contentHash: content.contentHash,
        progress: 0.0,
        lastRead: DateTime.now(),
        metadataJson: jsonEncode({
          'previewPath': CreateContentPreviewImage.genPreviewImagePath(filePath: content.path.filePath),
        }),
      );
      return (await isarData.getById(await isarData.store(newPtm)));
    });
    return result.data;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(theme.background, theme.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(child: AppBarContainerChild(theme.isDarkMode, title: widget.content.title)),
        body: PhotoView(
          imageProvider: FileImage(File(widget.content.path.filePath)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered,
        ),
      ),
    );
  }
}
