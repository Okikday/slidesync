import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/progress_track_models/course_track.dart';
import 'package:slidesync/data/repos/course_track_repo/course_track_repo.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class GridCourseCardProgressIndicator extends ConsumerStatefulWidget {
  const GridCourseCardProgressIndicator({
    super.key,
    required this.courseId,
    this.color,
  });

  final String courseId;
  final Color? color;

  @override
  ConsumerState<GridCourseCardProgressIndicator> createState() =>
      _GridCourseCardProgressIndicatorState();
}

class _GridCourseCardProgressIndicatorState
    extends ConsumerState<GridCourseCardProgressIndicator> {
  late Stream<CourseTrack?> _courseTrackStream;

  @override
  void initState() {
    super.initState();
    _courseTrackStream = CourseTrackRepo.watchByCourseId(widget.courseId);
  }

  @override
  void didUpdateWidget(covariant GridCourseCardProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      setState(() {
        _courseTrackStream = CourseTrackRepo.watchByCourseId(widget.courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).custom;
    return StreamBuilder<CourseTrack?>(
      stream: _courseTrackStream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == .active) {
          final progress = asyncSnapshot.data?.progress;
          return LinearProgressIndicator(
            minHeight: 16,
            value: progress?.clamp(0.2, 1.0) ?? 0.2,
            backgroundColor: (context.isDarkMode
                ? theme.surface.withAlpha(100)
                : theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.5)),
            color: widget.color ?? theme.primary,
            borderRadius: BorderRadius.circular(16),
          );
        }
        return LinearProgressIndicator(
          minHeight: 16,
          backgroundColor: context.isDarkMode
              ? theme.surface.withAlpha(100)
              : theme.adjustBgAndPrimaryWithLerpExtra.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        );
      },
    );
  }
}
