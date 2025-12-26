import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/base/use_value_notifier.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/content_track_repo.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';

class ImageViewerState with ValueNotifierFactoryMixin {
  // static final ScreenshotController screenshotController = ScreenshotController();

  ///|
  ///|
  /// ===================================================================================================
  /// VARIABLES
  /// ===================================================================================================
  final String contentId;
  final Ref ref;

  late Future<void> isInitialized;
  late final ValueNotifier<bool> isAppBarVisibleNotifier;
  late final ValueNotifier<int> rotationNotifier;
  late final PhotoViewController controller;

  final Stopwatch _viewStopwatch = Stopwatch();
  ContentTrack? progressTrack;

  // Read validity duration constant
  static const Duration readValidityDuration = Duration(seconds: 40);

  ImageViewerState(this.ref, this.contentId) {
    isAppBarVisibleNotifier = useValueNotifier(true);
    rotationNotifier = useValueNotifier(0);
    controller = PhotoViewController();
    isInitialized = _initialize();
  }

  Future<void> _initialize() async {
    await Result.tryRunAsync(() async {
      progressTrack = await _getLastProgressTrack(contentId);
      rotationNotifier.value = (await AppHiveData.instance.getData(key: "${contentId}_rotation") as int?) ?? 0;
    });
    controller.rotation = (math.pi / 2) * rotationNotifier.value;
    _viewStopwatch.start();
  }

  void dispose() {
    _viewStopwatch.stop();
    controller.dispose();

    // Mark as fully read if user stayed long enough
    if (_viewStopwatch.elapsed >= readValidityDuration && progressTrack != null) {
      Future.microtask(() async {
        await _updateProgressTrack(progressTrack!.copyWith(progress: 1.0, lastRead: DateTime.now()));
        await _updateCourseTrackProgress();
      });
    }

    disposeNotifiers();
  }

  // ============================================================================
  // PUBLIC UPDATE METHODS
  // ============================================================================

  void setAppBarVisible(bool visible) {
    isAppBarVisibleNotifier.value = visible;
  }

  void toggleAppBarVisible() {
    final visible = isAppBarVisibleNotifier.value;
    isAppBarVisibleNotifier.value = !visible;
    SystemChrome.setEnabledSystemUIMode(visible ? SystemUiMode.immersive : SystemUiMode.edgeToEdge);
  }

  Future<void> setRotation() async {
    final rotation = rotationNotifier.value;
    final newRotation = rotation >= 3 ? 0 : rotation + 1;
    rotationNotifier.value = newRotation;
    controller.rotation = (math.pi / 2) * newRotation;
    await AppHiveData.instance.setData(key: "${contentId}_rotation", value: newRotation);
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  Future<ContentTrack?> _getLastProgressTrack(String contentId) async {
    final content = await CourseContentRepo.getByContentId(contentId);
    if (content == null) return null;

    final ptm = await (await ContentTrackRepo.isar).contentTracks.where().contentIdEqualTo(contentId).findFirst();

    if (ptm == null) {
      return await _createProgressTrackModel(content);
    } else {
      return await _updateProgressTrack(
        ptm.copyWith(
          lastRead: DateTime.now(),
          metadataJson: jsonEncode(<String, dynamic>{'previewPath': content.thumbnailPath}),
        ),
      );
    }
  }

  Future<ContentTrack?> _createProgressTrackModel(CourseContent content) async {
    log("Creating progress track model for image");
    final result = await Result.tryRunAsync<ContentTrack?>(() async {
      final courseId = (await CourseCollectionRepo.getById(content.parentId))?.parentId;
      if (courseId == null) return null;

      final parentId = (await CourseTrackRepo.getByCourseId(courseId))?.courseId;
      if (parentId == null) return null;

      final ContentTrack newPtm = ContentTrack.create(
        contentId: content.contentId,
        parentId: parentId,
        title: content.title,
        description: content.description,
        contentHash: content.contentHash,
        progress: 0.0,
        pages: const [],
        lastRead: DateTime.now(),
        metadataJson: jsonEncode({'previewPath': content.thumbnailPath}),
      );

      return await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(newPtm));
    });
    return result.data;
  }

  Future<ContentTrack> _updateProgressTrack(ContentTrack ptm) async {
    log("Updating progress track model for image");
    progressTrack = await ContentTrackRepo.isarData.getById(await ContentTrackRepo.isarData.store(ptm)) ?? ptm;
    return progressTrack!;
  }

  Future<void> _updateCourseTrackProgress() async {
    if (progressTrack == null) return;

    final courseTrack = await CourseTrackRepo.getByCourseId(progressTrack!.parentId);
    if (courseTrack == null) return;

    await courseTrack.contentTracks.load();
    final contentsLength = courseTrack.contentTracks.length;
    if (contentsLength == 0) return;

    final totalProgress = courseTrack.contentTracks.fold<double>(0.0, (sum, track) => sum + (track.progress ?? 0.0));

    final newProgress = totalProgress / contentsLength;
    await CourseTrackRepo.isarData.store(courseTrack.copyWith(progress: newProgress));
  }
}
