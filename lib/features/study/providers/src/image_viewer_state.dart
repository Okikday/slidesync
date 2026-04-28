import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/base/mixins/use_value_notifier.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/features/study/logic/usecases/content_progress_tracker.dart';

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
      progressTrack = await ProgressTracker.getLastTrack(contentId);
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
        progressTrack = await ProgressTracker.saveTrack(
          progressTrack!.copyWith(progress: 1.0, lastRead: DateTime.now()),
        );
        await ProgressTracker.updateCourseTrackProgress(contentId);
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
}
