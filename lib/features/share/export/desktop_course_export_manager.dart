import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/presentation/ui/course_details/course_categories_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

/// Export progress state
class ExportProgress {
  final String message;
  final double? progress;
  final int? currentCollection;
  final int? totalCollections;
  final String? currentCollectionName;
  final int? successCount;
  final int? failCount;

  ExportProgress({
    required this.message,
    this.progress,
    this.currentCollection,
    this.totalCollections,
    this.currentCollectionName,
    this.successCount = 0,
    this.failCount = 0,
  });

  ExportProgress copyWith({
    String? message,
    double? progress,
    int? currentCollection,
    int? totalCollections,
    String? currentCollectionName,
    int? successCount,
    int? failCount,
  }) {
    return ExportProgress(
      message: message ?? this.message,
      progress: progress ?? this.progress,
      currentCollection: currentCollection ?? this.currentCollection,
      totalCollections: totalCollections ?? this.totalCollections,
      currentCollectionName: currentCollectionName ?? this.currentCollectionName,
      successCount: successCount ?? this.successCount,
      failCount: failCount ?? this.failCount,
    );
  }
}

/// Export result for individual files
class FileExportResult {
  final String originalName;
  final bool success;
  final String? error;

  FileExportResult({required this.originalName, required this.success, this.error});
}

/// Main class for managing course exports on Windows
class CourseFolderExportManagerWindows {
  /// Pick a folder for export using file_picker
  static Future<String?> pickExportFolder() async {
    try {
      final String? selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Export Folder',
      );

      if (selectedPath != null) {
        log('📂 Selected export folder path: $selectedPath');
        return selectedPath;
      }

      return null;
    } catch (e) {
      log('❌ Error picking export folder: $e');
      return null;
    }
  }

  /// Show the export screen for a course
  static Future<void> showExportScreen(BuildContext context, String courseId) async {
    log('🎯 Opening export screen for course: $courseId');

    // Show loading while fetching course
    GlobalNav.withContext((c) => UiUtils.showLoadingDialog(c, message: 'Loading course...'));

    final course = await CourseRepo.getCourseById(courseId);

    // Hide loading
    GlobalNav.popGlobal();

    if (course == null) {
      log('❌ Course not found: $courseId');
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: 'Error: Course not found', vibe: FlushbarVibe.error);
      }
      return;
    }

    // Load collections
    await course.collections.load();

    if (course.collections.isEmpty) {
      log('⚠️ Course has no collections');
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: 'This course has no content to export', vibe: FlushbarVibe.warning);
      }
      return;
    }

    log('✅ Course loaded with ${course.collections.length} collections. Opening export screen...');

    if (context.mounted) {
      await Navigator.of(context).push(
        PageAnimation.pageRouteBuilder(
          _ExportScreen(course: course),
          type: TransitionType.rightToLeft,
        ),
      );
    }
  }

  static Future<Result<String?>> exportCourse(
    Course course,
    String exportFolderPath,
    ValueNotifier<ExportProgress> progressNotifier,
  ) async {
    return await Result.tryRunAsync(() async {
      log('🚀 Starting export process for course: ${course.courseTitle}');

      progressNotifier.value = ExportProgress(message: 'Preparing export...');

      await course.collections.load();
      final collections = course.collections.toList();

      if (collections.isEmpty) {
        throw Exception('No collections to export');
      }

      log('📦 Exporting ${collections.length} collection(s)');

      int successCount = 0;
      int failCount = 0;
      int totalFiles = 0;

      // Course folder name
      final courseFolderName = _sanitizeFolderName(course.courseTitle);
      final courseFolderPath = p.join(exportFolderPath, courseFolderName);

      // Create course folder
      final courseFolder = Directory(courseFolderPath);
      if (!await courseFolder.exists()) {
        await courseFolder.create(recursive: true);
        log('📁 Created course folder: $courseFolderPath');
      }

      for (int i = 0; i < collections.length; i++) {
        final collection = collections[i];

        progressNotifier.value = ExportProgress(
          message: 'Exporting collection...',
          currentCollection: i + 1,
          totalCollections: collections.length,
          currentCollectionName: collection.collectionTitle,
          successCount: successCount,
          failCount: failCount,
        );

        log('📂 Processing collection ${i + 1}/${collections.length}: ${collection.collectionTitle}');

        await collection.contents.load();
        final contents = collection.contents.toList();

        if (contents.isEmpty) {
          log('⚠️ Collection "${collection.collectionTitle}" has no contents, skipping');
          continue;
        }

        totalFiles += contents.length;

        // Collection folder name
        final collectionFolderName = _sanitizeFolderName(collection.collectionTitle);
        final collectionFolderPath = p.join(courseFolderPath, collectionFolderName);

        // Create collection folder
        final collectionFolder = Directory(collectionFolderPath);
        if (!await collectionFolder.exists()) {
          await collectionFolder.create(recursive: true);
          log('📁 Created collection folder: $collectionFolderPath');
        }

        // Export files in this collection
        for (int j = 0; j < contents.length; j++) {
          final content = contents[j];

          progressNotifier.value = ExportProgress(
            message: 'Exporting file ${j + 1}/${contents.length}...',
            currentCollection: i + 1,
            totalCollections: collections.length,
            currentCollectionName: collection.collectionTitle,
            successCount: successCount,
            failCount: failCount,
          );

          // Export file to: CourseName/CollectionName/filename.ext
          final result = await _exportFile(content, collectionFolderPath);

          if (result.success) {
            successCount++;
            log('✅ Exported: ${result.originalName}');
          } else {
            failCount++;
            log('❌ Failed to export: ${result.originalName} - ${result.error}');
          }
        }
      }

      final summary = 'Successfully exported $successCount/$totalFiles files';
      progressNotifier.value = ExportProgress(
        message: 'Export complete!',
        successCount: successCount,
        failCount: failCount,
      );

      log('🎉 Export complete: $summary');

      if (failCount > 0) {
        return '$summary\n$failCount files failed to export';
      }

      return summary;
    });
  }

  static Future<FileExportResult> _exportFile(
    CourseContent content,
    String destinationFolderPath,
  ) async {
    try {
      // Get original filename
      final metadata = content.metadata;
      String originalFilename = metadata['originalFilename'] as String;

      if (!p.extension(originalFilename).isNotEmpty) {
        final pathDetails = content.path;
        if (pathDetails.isNotEmpty) {
          final storedPath = jsonDecode(pathDetails)['filePath'] as String?;
          if (storedPath != null) {
            final ext = p.extension(storedPath);
            if (ext.isNotEmpty) {
              originalFilename = '$originalFilename$ext';
            }
          }
        }
      }

      originalFilename = _sanitizeFileName(originalFilename);

      // Get file path
      final pathDetails = content.path;
      if (pathDetails.isEmpty) {
        return FileExportResult(
          originalName: originalFilename,
          success: false,
          error: 'No file path found',
        );
      }

      final filePathJson = jsonDecode(pathDetails);
      final storedFilePath = filePathJson['filePath'] as String?;

      if (storedFilePath == null || storedFilePath.isEmpty) {
        return FileExportResult(
          originalName: originalFilename,
          success: false,
          error: 'Invalid file path',
        );
      }

      final sourceFile = File(storedFilePath);

      if (!await sourceFile.exists()) {
        return FileExportResult(
          originalName: originalFilename,
          success: false,
          error: 'File does not exist',
        );
      }

      // Destination file path
      final destinationPath = p.join(destinationFolderPath, originalFilename);
      
      // Handle duplicate filenames by appending a number
      String finalPath = destinationPath;
      int counter = 1;
      while (await File(finalPath).exists()) {
        final nameWithoutExt = p.basenameWithoutExtension(originalFilename);
        final ext = p.extension(originalFilename);
        final newName = '${nameWithoutExt}_$counter$ext';
        finalPath = p.join(destinationFolderPath, newName);
        counter++;
      }

      // Copy file
      await sourceFile.copy(finalPath);

      return FileExportResult(originalName: originalFilename, success: true);
    } catch (e, stackTrace) {
      log('❌ Error exporting file: $e\n$stackTrace');
      return FileExportResult(
        originalName: content.title,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sanitize folder name (remove invalid characters)
  static String _sanitizeFolderName(String name) {
    // Remove invalid characters for folder names
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Sanitize file name (remove invalid characters)
  static String _sanitizeFileName(String name) {
    // Remove invalid characters for file names
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// Export screen widget
class _ExportScreen extends ConsumerStatefulWidget {
  final Course course;

  const _ExportScreen({required this.course});

  @override
  ConsumerState<_ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<_ExportScreen> {
  int totalFiles = 0;
  Map<String, int> collectionFileCounts = {};

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  Future<void> _calculateStats() async {
    int total = 0;
    Map<String, int> counts = {};

    for (final collection in widget.course.collections) {
      await collection.contents.load();
      final fileCount = collection.contents.length;
      counts[collection.collectionTitle] = fileCount;
      total += fileCount;
    }

    setState(() {
      totalFiles = total;
      collectionFileCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;
    final isDarkMode = theme.isDarkTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          isDarkMode,
          title: "Export Course",
          subtitle: widget.course.courseTitle,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: const SizedBox(height: 12)),
              // Summary Card
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primary.withValues(alpha: 0.1),
                        theme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.download, color: theme.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  'Export Summary',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  'Original folder structure will be preserved',
                                  fontSize: 12,
                                  color: theme.supportingText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: theme.supportingText.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip(
                            theme,
                            Icons.folder,
                            '${widget.course.collections.length}',
                            'Collections',
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(theme, Icons.insert_drive_file, '$totalFiles', 'Files'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Collections Preview
              PinnedHeaderSliver(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CustomText(
                    'Collections to Export:',
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverList.separated(
                itemCount: widget.course.collections.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final collection = widget.course.collections.elementAt(index);
                  final fileCount = collectionFileCounts[collection.collectionTitle] ?? 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CourseCategoriesCard(
                      isDarkMode: isDarkMode,
                      title: collection.collectionTitle,
                      contentCount: fileCount,
                      onTap: () {},
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),

              // Info box
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomText(
                          'Files will be exported with their original names to the selected folder',
                          color: theme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),

              if (totalFiles == 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: theme.secondary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            'This course has no files to export',
                            color: theme.supportingText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: context.bottomPadding + 50)),
            ],
          ),

          Positioned(
            bottom: context.bottomPadding + 4,
            left: 12,
            right: 12,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: totalFiles == 0 ? null : _startExport,
                icon: const Icon(Icons.download),
                label: const Text('Select Folder & Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  disabledBackgroundColor: theme.supportingText.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(AppTheme theme, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primary, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  value,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.onSurface,
                ),
                CustomText(label, fontSize: 11, color: theme.supportingText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startExport() async {
    log('🚀 Starting export...');

    // Pick export folder
    final exportFolderPath = await CourseFolderExportManagerWindows.pickExportFolder();

    if (exportFolderPath == null) {
      log('❌ No export folder selected');
      return;
    }

    final progressNotifier = ValueNotifier<ExportProgress>(
      ExportProgress(message: 'Starting export...'),
    );

    // Show progress dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ExportProgressDialog(progressNotifier: progressNotifier),
    );

    final result = await CourseFolderExportManagerWindows.exportCourse(
      widget.course,
      exportFolderPath,
      progressNotifier,
    );

    if (mounted) {
      context.pop(); // Close progress dialog
      context.pop(); // Close export screen

      UiUtils.showFlushBar(
        context,
        msg: result.isSuccess ? result.data! : 'Error: ${result.message}',
        vibe: result.isSuccess ? FlushbarVibe.success : FlushbarVibe.warning,
      );

      progressNotifier.dispose();
    }

    log(result.isSuccess
        ? '✅ Export completed successfully'
        : '❌ Export failed: ${result.message}');
  }
}

/// Progress dialog for export process
class _ExportProgressDialog extends ConsumerWidget {
  final ValueNotifier<ExportProgress> progressNotifier;

  const _ExportProgressDialog({required this.progressNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.theme;

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<ExportProgress>(
          valueListenable: progressNotifier,
          builder: (context, progress, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, color: theme.primary, size: 48),
                const SizedBox(height: 20),
                CustomText(
                  'Exporting Course',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
                const SizedBox(height: 24),
                CircularProgressIndicator(color: theme.primary),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primary.withValues(alpha: 0.1),
                        theme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (progress.currentCollection != null &&
                          progress.totalCollections != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder, color: theme.primary, size: 20),
                            const SizedBox(width: 8),
                            CustomText(
                              'Collection ${progress.currentCollection} of ${progress.totalCollections}',
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                              fontSize: 16,
                            ),
                          ],
                        ),
                        if (progress.currentCollectionName != null) ...[
                          const SizedBox(height: 8),
                          CustomText(
                            progress.currentCollectionName!,
                            color: theme.onSurface,
                            fontSize: 14,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Divider(color: theme.supportingText.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                      ],
                      CustomText(
                        progress.message,
                        color: theme.supportingText,
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                      if (progress.successCount != null && progress.successCount! > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            CustomText(
                              '${progress.successCount} succeeded',
                              fontSize: 12,
                              color: theme.supportingText,
                            ),
                            if (progress.failCount != null && progress.failCount! > 0) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.error, color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              CustomText(
                                '${progress.failCount} failed',
                                fontSize: 12,
                                color: theme.supportingText,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  'Please do not close the app',
                  color: theme.supportingText,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}