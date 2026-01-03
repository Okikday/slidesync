// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/course_collection/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/main/ui/models/explore_card_data.dart';
import 'package:slidesync/features/main/ui/widgets/explore_tab_view/explore_card.dart';
import 'package:slidesync/features/sync/logic/sync_service.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

/// ============================================================================
/// EXPLORE DOWNLOAD HELPER
/// ============================================================================
///
/// Handles downloading items from Explore view:
/// - Shows appropriate dialogs for course/collection/content
/// - Handles merge vs new creation
/// - Integrates with SyncService
/// - Provides progress feedback
/// ============================================================================

class ExploreDownloadHelper {
  static final ExploreDownloadHelper instance = ExploreDownloadHelper._();
  ExploreDownloadHelper._();

  /// Shows download dialog and initiates download
  Future<void> downloadItem({
    required BuildContext context,
    required WidgetRef ref,
    required ExploreCardData data,
  }) async {
    switch (data.type) {
      case ExploreCardType.course:
        await _downloadCourse(context, ref, data);
        break;
      case ExploreCardType.collection:
        await _downloadCollection(context, ref, data);
        break;
      case ExploreCardType.content:
        await _downloadContent(context, ref, data);
        break;
    }
  }

  // =========================================================================
  // COURSE DOWNLOAD
  // =========================================================================

  Future<void> _downloadCourse(BuildContext context, WidgetRef ref, ExploreCardData data) async {
    // Check if course already exists locally
    final existingCourse = await CourseRepo.getCourseById(data.id);

    if (existingCourse != null) {
      // Show merge dialog
      await _showMergeDialog(context: context, ref: ref, data: data, existingCourse: existingCourse);
    } else {
      // Direct download as new course
      await _startCourseDownload(context: context, ref: ref, remoteCourseId: data.id, courseName: data.title);
    }
  }

  /// Shows merge confirmation dialog
  Future<void> _showMergeDialog({
    required BuildContext context,
    required WidgetRef ref,
    required ExploreCardData data,
    required Course existingCourse,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Course Already Exists'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A course with ID "${data.id}" already exists locally.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Text('Local: ${existingCourse.courseTitle}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Remote: ${data.title}', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Would you like to merge missing collections and contents into the existing course?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Merge')),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await _startCourseDownload(
        context: context,
        ref: ref,
        remoteCourseId: data.id,
        courseName: data.title,
        targetCourseId: existingCourse.courseId, // Merge into existing
      );
    }
  }

  /// Starts course download
  Future<void> _startCourseDownload({
    required BuildContext context,
    required WidgetRef ref,
    required String remoteCourseId,
    required String courseName,
    String? targetCourseId,
  }) async {
    if (!context.mounted) return;

    // Show loading dialog
    UiUtils.showLoadingDialog(
      context,
      message: targetCourseId != null
          ? 'Merging course...\n\nThis may take a while for large courses.'
          : 'Downloading course...\n\nThis may take a while for large courses.',
      canPop: false,
    );

    try {
      final result = await SyncService.instance.downloadCourse(
        ref,
        remoteCourseId,
        targetCourseId: targetCourseId,
        onProgress: (progress, message) {
          log('Download progress: $message');
          // TODO: Update dialog with progress
        },
      );

      if (!context.mounted) return;

      // Hide loading dialog
      Navigator.pop(context);

      if (result.isSuccess) {
        final course = result.data!;

        // Show success message
        UiUtils.showFlushBar(
          context,
          msg: targetCourseId != null
              ? 'Successfully merged into "${course.courseTitle}"'
              : 'Successfully downloaded "${course.courseTitle}"',
          vibe: FlushbarVibe.success,
        );

        // Navigate to course
        context.pushNamed(Routes.courseDetails.name, extra: course);
      } else {
        // Show error
        UiUtils.showFlushBar(context, msg: result.message ?? 'Download failed', vibe: FlushbarVibe.error);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      UiUtils.showFlushBar(context, msg: 'Error: $e', vibe: FlushbarVibe.error);
    }
  }

  // =========================================================================
  // COLLECTION DOWNLOAD
  // =========================================================================

  Future<void> _downloadCollection(BuildContext context, WidgetRef ref, ExploreCardData data) async {
    // Show course selection dialog
    final selectedCourse = await _showCourseSelectionDialog(context);

    if (selectedCourse == null || !context.mounted) return;

    // Show loading dialog
    UiUtils.showLoadingDialog(context, message: 'Downloading collection...', canPop: false);

    try {
      final result = await SyncService.instance.downloadCollection(
        ref,
        data.id,
        selectedCourse.courseId,
        onProgress: (progress, message) {
          log('Download progress: $message');
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      if (result.isSuccess) {
        final collection = result.data!;

        UiUtils.showFlushBar(
          context,
          msg: 'Successfully downloaded "${collection.collectionTitle}"',
          vibe: FlushbarVibe.success,
        );

        // Navigate to collection
        context.pushNamed(Routes.courseMaterials.name, extra: collection);
      } else {
        UiUtils.showFlushBar(context, msg: result.message ?? 'Download failed', vibe: FlushbarVibe.error);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      UiUtils.showFlushBar(context, msg: 'Error: $e', vibe: FlushbarVibe.error);
    }
  }

  /// Shows dialog to select target course
  Future<Course?> _showCourseSelectionDialog(BuildContext context) async {
    final courses = await CourseRepo.getAllCourses();

    if (!context.mounted) return null;

    return await showDialog<Course>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Course'),
        content: SizedBox(
          width: double.maxFinite,
          child: courses.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No courses found. Please create a course first.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return ListTile(
                      title: Text(course.courseTitle),
                      subtitle: Text(course.description),
                      onTap: () => Navigator.pop(context, course),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          if (courses.isEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to create course screen
              },
              child: const Text('Create Course'),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // CONTENT DOWNLOAD
  // =========================================================================

  Future<void> _downloadContent(BuildContext context, WidgetRef ref, ExploreCardData data) async {
    // Show collection selection dialog
    final selectedCollection = await _showCollectionSelectionDialog(context);

    if (selectedCollection == null || !context.mounted) return;

    // Show loading dialog
    UiUtils.showLoadingDialog(context, message: 'Downloading content...', canPop: false);

    try {
      final result = await SyncService.instance.downloadContents(
        ref,
        [data.id], // Single content hash
        selectedCollection.collectionId,
        onProgress: (progress, message) {
          log('Download progress: $message');
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      if (result.isSuccess) {
        UiUtils.showFlushBar(context, msg: 'Successfully downloaded "${data.title}"', vibe: FlushbarVibe.success);

        // Navigate to collection
        context.pushNamed(Routes.courseMaterials.name, extra: selectedCollection);
      } else {
        UiUtils.showFlushBar(context, msg: result.message ?? 'Download failed', vibe: FlushbarVibe.error);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      UiUtils.showFlushBar(context, msg: 'Error: $e', vibe: FlushbarVibe.error);
    }
  }

  /// Shows dialog to select target collection
  Future<CourseCollection?> _showCollectionSelectionDialog(BuildContext context) async {
    final courses = await CourseRepo.getAllCourses();

    if (!context.mounted) return null;

    // First select course, then collection
    final selectedCourse = await _showCourseSelectionDialog(context);
    if (selectedCourse == null || !context.mounted) return null;

    await selectedCourse.collections.load();
    final collections = selectedCourse.collections.toList();

    if (!context.mounted) return null;

    return await showDialog<CourseCollection>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Collection in ${selectedCourse.courseTitle}'),
        content: SizedBox(
          width: double.maxFinite,
          child: collections.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No collections found. Please create a collection first.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return ListTile(
                      title: Text(collection.collectionTitle),
                      subtitle: Text(collection.description),
                      onTap: () => Navigator.pop(context, collection),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }
}
