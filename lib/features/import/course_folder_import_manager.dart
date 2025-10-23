import 'dart:io';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/store_contents.dart';
import 'package:slidesync/features/manage/domain/usecases/types/store_content_args.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';
import 'package:uuid/uuid.dart';

/// Model representing a folder structure
class FolderNode {
  final String name;
  final String path;
  final List<FolderNode> subfolders;
  final List<String> files;
  bool isSelected;

  FolderNode({
    required this.name,
    required this.path,
    this.subfolders = const [],
    this.files = const [],
    this.isSelected = false,
  });

  FolderNode copyWith({
    String? name,
    String? path,
    List<FolderNode>? subfolders,
    List<String>? files,
    bool? isSelected,
  }) {
    return FolderNode(
      name: name ?? this.name,
      path: path ?? this.path,
      subfolders: subfolders ?? this.subfolders,
      files: files ?? this.files,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// File type filter options
class FileTypeFilter {
  final String extension;
  final String displayName;
  final IconData icon;
  bool isEnabled;

  FileTypeFilter({required this.extension, required this.displayName, required this.icon, this.isEnabled = false});
}

/// Configuration for folder import
class FolderImportConfig {
  final String baseFolderPath;
  final bool useAsBaseFolder;
  final String? selectedSubfolderPath;
  final bool includeSubfolders;
  final List<FileTypeFilter> fileFilters;
  final int maxContents;

  FolderImportConfig({
    required this.baseFolderPath,
    this.useAsBaseFolder = true,
    this.selectedSubfolderPath,
    this.includeSubfolders = false,
    required this.fileFilters,
    this.maxContents = 1000,
  });
}

/// Import progress state
class ImportProgress {
  final String message;
  final double? progress;
  final int? currentCollection;
  final int? totalCollections;
  final String? currentCollectionName;

  ImportProgress({
    required this.message,
    this.progress,
    this.currentCollection,
    this.totalCollections,
    this.currentCollectionName,
  });

  String get displayMessage {
    if (currentCollection != null && totalCollections != null) {
      return 'Processing collection $currentCollection of $totalCollections\n${currentCollectionName ?? ""}\n$message';
    }
    return message;
  }
}

/// Main class for managing folder imports
class CourseFolderImportManager {
  static const int kMaxContents = 1000;

  /// Default file type filters
  static List<FileTypeFilter> getDefaultFileFilters() {
    return [
      // Documents
      FileTypeFilter(extension: '.pdf', displayName: 'PDF Documents', icon: Icons.picture_as_pdf, isEnabled: true),
      FileTypeFilter(extension: '.docx', displayName: 'Word Documents', icon: Icons.description, isEnabled: false),
      FileTypeFilter(extension: '.doc', displayName: 'Word Documents (Old)', icon: Icons.description, isEnabled: false),
      FileTypeFilter(extension: '.pptx', displayName: 'PowerPoint', icon: Icons.slideshow, isEnabled: false),
      FileTypeFilter(extension: '.ppt', displayName: 'PowerPoint (Old)', icon: Icons.slideshow, isEnabled: false),
      FileTypeFilter(extension: '.xlsx', displayName: 'Excel Spreadsheets', icon: Icons.table_chart, isEnabled: false),
      FileTypeFilter(extension: '.xls', displayName: 'Excel (Old)', icon: Icons.table_chart, isEnabled: false),
      FileTypeFilter(extension: '.txt', displayName: 'Text Files', icon: Icons.text_snippet, isEnabled: false),
      FileTypeFilter(extension: '.rtf', displayName: 'Rich Text Format', icon: Icons.text_fields, isEnabled: false),
      FileTypeFilter(extension: '.odt', displayName: 'OpenDocument Text', icon: Icons.article, isEnabled: false),

      // Images
      FileTypeFilter(extension: '.jpg', displayName: 'JPEG Images', icon: Icons.image, isEnabled: true),
      FileTypeFilter(extension: '.jpeg', displayName: 'JPEG Images', icon: Icons.image, isEnabled: true),
      FileTypeFilter(extension: '.png', displayName: 'PNG Images', icon: Icons.image, isEnabled: true),
      FileTypeFilter(extension: '.gif', displayName: 'GIF Images', icon: Icons.gif, isEnabled: true),
      FileTypeFilter(extension: '.webp', displayName: 'WebP Images', icon: Icons.image, isEnabled: true),
      FileTypeFilter(extension: '.bmp', displayName: 'Bitmap Images', icon: Icons.image, isEnabled: false),
      FileTypeFilter(extension: '.svg', displayName: 'SVG Graphics', icon: Icons.brush, isEnabled: false),

      // Videos
      FileTypeFilter(extension: '.mp4', displayName: 'MP4 Videos', icon: Icons.video_library, isEnabled: false),
      FileTypeFilter(extension: '.mov', displayName: 'MOV Videos', icon: Icons.video_library, isEnabled: false),
      FileTypeFilter(extension: '.avi', displayName: 'AVI Videos', icon: Icons.video_library, isEnabled: false),
      FileTypeFilter(extension: '.mkv', displayName: 'MKV Videos', icon: Icons.video_library, isEnabled: false),
      FileTypeFilter(extension: '.webm', displayName: 'WebM Videos', icon: Icons.video_library, isEnabled: false),

      // Audio
      FileTypeFilter(extension: '.mp3', displayName: 'MP3 Audio', icon: Icons.audiotrack, isEnabled: false),
      FileTypeFilter(extension: '.wav', displayName: 'WAV Audio', icon: Icons.audiotrack, isEnabled: false),
      FileTypeFilter(extension: '.m4a', displayName: 'M4A Audio', icon: Icons.audiotrack, isEnabled: false),

      // Archives
      FileTypeFilter(extension: '.zip', displayName: 'ZIP Archives', icon: Icons.folder_zip, isEnabled: false),
      FileTypeFilter(extension: '.rar', displayName: 'RAR Archives', icon: Icons.folder_zip, isEnabled: false),
    ];
  }

  /// Pick a folder using file_picker
  static Future<String?> pickFolder() async {
    return await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select Course Folder');
  }

  /// Scan a folder and build its structure
  static Future<Result<FolderNode?>> scanFolder(String folderPath) async {
    return await Result.tryRunAsync(() async {
      final directory = Directory(folderPath);
      if (!await directory.exists()) {
        throw Exception('Folder does not exist: $folderPath');
      }

      final List<FolderNode> subfolders = [];
      final List<String> files = [];

      await for (final entity in directory.list()) {
        if (entity is Directory) {
          final subfolder = await scanFolder(entity.path);
          if (subfolder.isSuccess && subfolder.data != null) {
            subfolders.add(subfolder.data!);
          }
        } else if (entity is File) {
          files.add(entity.path);
        }
      }

      return FolderNode(name: p.basename(folderPath), path: folderPath, subfolders: subfolders, files: files);
    });
  }

  /// Get all files from a folder node based on filters
  static List<String> getFilteredFiles(FolderNode node, List<FileTypeFilter> filters, bool includeSubfolders) {
    final List<String> allFiles = [];
    final enabledExtensions = filters.where((f) => f.isEnabled).map((f) => f.extension.toLowerCase()).toSet();

    // Add files from current folder
    for (final file in node.files) {
      final ext = p.extension(file).toLowerCase();
      if (enabledExtensions.isEmpty || enabledExtensions.contains(ext)) {
        allFiles.add(file);
      }
    }

    // Add files from subfolders if enabled
    if (includeSubfolders) {
      for (final subfolder in node.subfolders) {
        allFiles.addAll(getFilteredFiles(subfolder, filters, true));
      }
    }

    return allFiles;
  }

  /// Show the folder import dialog
  static Future<void> showFolderImportDialog(BuildContext context) async {
    final folderPath = await pickFolder();

    if (folderPath == null) return;

    // Scan the folder first
    final scanResult = await scanFolder(folderPath);

    if (!scanResult.isSuccess || scanResult.data == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning folder: ${scanResult.message}')));
      }
      return;
    }

    final folderNode = scanResult.data!;

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _FolderImportDialog(folderNode: folderNode),
      );
    }
  }

  /// Process the import with the given configuration
  static Future<Result<String?>> processImport(
    FolderImportConfig config,
    ValueNotifier<ImportProgress> progressNotifier,
  ) async {
    return await Result.tryRunAsync(() async {
      progressNotifier.value = ImportProgress(message: 'Scanning folder structure...');

      // Scan the folder
      final scanResult = await scanFolder(
        config.useAsBaseFolder ? config.baseFolderPath : config.selectedSubfolderPath!,
      );

      if (!scanResult.isSuccess || scanResult.data == null) {
        throw Exception('Failed to scan folder: ${scanResult.message}');
      }

      final folderNode = scanResult.data!;
      progressNotifier.value = ImportProgress(message: 'Creating course...');

      // Determine if we have subfolders or just files
      final hasSubfolders = folderNode.subfolders.isNotEmpty;
      final courseName = folderNode.name;

      // Create the Course
      final course = Course.create(courseTitle: courseName, description: 'Imported from folder: ${folderNode.path}');

      final courseDbId = await CourseRepo.addCourse(course);
      if (courseDbId == -1) {
        throw Exception('Failed to create course');
      }

      // Calculate total collections to process
      int totalCollections = 0;
      if (hasSubfolders) {
        totalCollections = folderNode.subfolders.length;
        if (folderNode.files.where((file) {
          final ext = p.extension(file).toLowerCase();
          final enabledExtensions = config.fileFilters
              .where((f) => f.isEnabled)
              .map((f) => f.extension.toLowerCase())
              .toSet();
          return enabledExtensions.isEmpty || enabledExtensions.contains(ext);
        }).isNotEmpty) {
          totalCollections++; // Add one for root materials
        }
      } else {
        totalCollections = 1; // Just the Materials collection
      }

      int currentCollectionIndex = 0;

      // Create collections based on folder structure
      if (hasSubfolders) {
        // Create a collection for each subfolder
        for (final subfolder in folderNode.subfolders) {
          currentCollectionIndex++;

          progressNotifier.value = ImportProgress(
            message: 'Creating collection...',
            currentCollection: currentCollectionIndex,
            totalCollections: totalCollections,
            currentCollectionName: subfolder.name,
          );

          final collection = CourseCollection.create(
            parentId: course.courseId,
            collectionTitle: subfolder.name,
            description: 'Collection from folder: ${subfolder.name}',
          );

          final addResult = await CourseCollectionRepo.addCollectionNoDuplicateTitle(collection);
          if (addResult != null) {
            // Collection already exists or error, skip
            continue;
          }

          // Get files for this collection
          final files = getFilteredFiles(subfolder, config.fileFilters, config.includeSubfolders);

          if (files.isNotEmpty) {
            final limitedFiles = files.take(config.maxContents).toList();
            progressNotifier.value = ImportProgress(
              message: 'Adding ${limitedFiles.length} files...',
              currentCollection: currentCollectionIndex,
              totalCollections: totalCollections,
              currentCollectionName: subfolder.name,
            );

            await _addFilesToCollection(
              collection,
              limitedFiles,
              progressNotifier,
              currentCollectionIndex,
              totalCollections,
              subfolder.name,
            );
          }
        }

        // Also add any files in the root folder
        final rootFiles = folderNode.files.where((file) {
          final ext = p.extension(file).toLowerCase();
          final enabledExtensions = config.fileFilters
              .where((f) => f.isEnabled)
              .map((f) => f.extension.toLowerCase())
              .toSet();
          return enabledExtensions.isEmpty || enabledExtensions.contains(ext);
        }).toList();

        if (rootFiles.isNotEmpty) {
          currentCollectionIndex++;

          progressNotifier.value = ImportProgress(
            message: 'Creating root materials collection...',
            currentCollection: currentCollectionIndex,
            totalCollections: totalCollections,
            currentCollectionName: 'Materials',
          );

          final rootCollection = CourseCollection.create(
            parentId: course.courseId,
            collectionTitle: 'Materials',
            description: 'Root folder materials',
          );

          await CourseCollectionRepo.addCollectionNoDuplicateTitle(rootCollection);

          final limitedFiles = rootFiles.take(config.maxContents).toList();
          await _addFilesToCollection(
            rootCollection,
            limitedFiles,
            progressNotifier,
            currentCollectionIndex,
            totalCollections,
            'Materials',
          );
        }
      } else {
        // No subfolders, just files - create a single "Materials" collection
        currentCollectionIndex++;

        progressNotifier.value = ImportProgress(
          message: 'Creating materials collection...',
          currentCollection: currentCollectionIndex,
          totalCollections: totalCollections,
          currentCollectionName: 'Materials',
        );

        final collection = CourseCollection.create(
          parentId: course.courseId,
          collectionTitle: 'Materials',
          description: 'Course materials',
        );

        final addResult = await CourseCollectionRepo.addCollectionNoDuplicateTitle(collection);
        if (addResult != null) {
          throw Exception(addResult);
        }

        final files = getFilteredFiles(folderNode, config.fileFilters, false);
        if (files.isNotEmpty) {
          final limitedFiles = files.take(config.maxContents).toList();
          progressNotifier.value = ImportProgress(
            message: 'Adding ${limitedFiles.length} files...',
            currentCollection: currentCollectionIndex,
            totalCollections: totalCollections,
            currentCollectionName: 'Materials',
          );

          await _addFilesToCollection(
            collection,
            limitedFiles,
            progressNotifier,
            currentCollectionIndex,
            totalCollections,
            'Materials',
          );
        }
      }

      progressNotifier.value = ImportProgress(message: 'Import complete!');
      return 'Successfully imported course: $courseName with $totalCollections collection(s)';
    });
  }

  /// Helper method to add files to a collection using storeContents
  static Future<void> _addFilesToCollection(
    CourseCollection collection,
    List<String> filePaths,
    ValueNotifier<ImportProgress> progressNotifier,
    int currentCollection,
    int totalCollections,
    String collectionName,
  ) async {
    final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw Exception('Unable to process adding content in background');
    }

    // Limit to max contents
    final limitedPaths = filePaths.take(kMaxContents).toList();

    final uuids = [for (int i = 0; i < limitedPaths.length; i++) const Uuid().v4()];
    final uuidFileNames = [
      for (int i = 0; i < limitedPaths.length; i++) p.setExtension(uuids[i], p.extension(limitedPaths[i])),
    ];

    await Result.tryRunAsync(() async {
      await AppHiveData.instance.setData(
        key: HiveDataPathKey.contentsAddingProgressList.name,
        value: <String, dynamic>{
          for (int i = 0; i < uuidFileNames.length; i++) uuidFileNames[i]: limitedPaths[i],
          'collectionId': collection.collectionId,
        },
      );
    });

    final args = StoreContentArgs(
      token: rootIsolateToken,
      collectionId: collection.collectionId,
      filePaths: limitedPaths,
      uuids: uuids,
    ).toMap();

    // Create a wrapper ValueNotifier to update the import progress
    final contentProgressNotifier = ValueNotifier<String>('');
    contentProgressNotifier.addListener(() {
      progressNotifier.value = ImportProgress(
        message: contentProgressNotifier.value,
        currentCollection: currentCollection,
        totalCollections: totalCollections,
        currentCollectionName: collectionName,
      );
    });

    await storeContents(args, contentProgressNotifier);

    await Result.tryRunAsync(() async {
      await AppHiveData.instance.deleteData(key: HiveDataPathKey.contentsAddingProgressList.name);
    });

    contentProgressNotifier.dispose();
  }
}

/// Dialog widget for folder import
class _FolderImportDialog extends ConsumerStatefulWidget {
  final FolderNode folderNode;

  const _FolderImportDialog({required this.folderNode});

  @override
  ConsumerState<_FolderImportDialog> createState() => _FolderImportDialogState();
}

class _FolderImportDialogState extends ConsumerState<_FolderImportDialog> {
  late bool useAsBaseFolder;
  late bool includeSubfolders;
  late List<FileTypeFilter> fileFilters;
  FolderNode? selectedSubfolder;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    useAsBaseFolder = true;
    includeSubfolders = false;
    fileFilters = CourseFolderImportManager.getDefaultFileFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85, maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: theme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Import Course from Folder',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                        ),
                        const SizedBox(height: 4),
                        CustomText('Step ${_currentStep + 1} of 3', fontSize: 14, color: theme.supportingText),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.supportingText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Stepper
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.fromSeed(seedColor: theme.primary, brightness: theme.brightness),
                ),
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          if (_currentStep < 2)
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                foregroundColor: theme.onPrimary,
                              ),
                              child: const Text('Continue'),
                            ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: Text('Back', style: TextStyle(color: theme.supportingText)),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: Text('Select Base Folder', style: TextStyle(color: theme.onSurface)),
                      content: _buildBaseFolderStep(),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    ),
                    Step(
                      title: Text('Configure Options', style: TextStyle(color: theme.onSurface)),
                      content: _buildOptionsStep(),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : _currentStep == 1
                          ? StepState.indexed
                          : StepState.disabled,
                    ),
                    Step(
                      title: Text('Review & Import', style: TextStyle(color: theme.onSurface)),
                      content: _buildPreviewStep(),
                      isActive: _currentStep >= 2,
                      state: _currentStep == 2 ? StepState.indexed : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseFolderStep() {
    final theme = ref;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.altBackgroundPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.folder, color: theme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText('Selected Folder', fontSize: 12, color: theme.supportingText),
                    const SizedBox(height: 4),
                    CustomText(
                      widget.folderNode.name,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
          ),
          child: SwitchListTile(
            title: CustomText('Use as base folder', color: theme.onSurface, fontWeight: FontWeight.w600),
            subtitle: CustomText(
              useAsBaseFolder ? 'Create course from this folder' : 'Select a subfolder to use as course',
              color: theme.supportingText,
              fontSize: 13,
            ),
            value: useAsBaseFolder,
            activeColor: theme.primary,
            onChanged: (value) => setState(() {
              useAsBaseFolder = value;
              if (value) selectedSubfolder = null;
            }),
          ),
        ),

        if (!useAsBaseFolder && widget.folderNode.subfolders.isNotEmpty) ...[
          const SizedBox(height: 20),
          CustomText('Select subfolder:', fontWeight: FontWeight.bold, color: theme.onSurface, fontSize: 16),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.folderNode.subfolders.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: theme.supportingText.withValues(alpha: 0.1)),
              itemBuilder: (context, index) {
                final folder = widget.folderNode.subfolders[index];
                final isSelected = selectedSubfolder == folder;

                return RadioListTile<FolderNode>(
                  title: CustomText(
                    folder.name,
                    color: theme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  subtitle: CustomText(
                    '${folder.files.length} files, ${folder.subfolders.length} subfolders',
                    color: theme.supportingText,
                    fontSize: 12,
                  ),
                  value: folder,
                  groupValue: selectedSubfolder,
                  activeColor: theme.primary,
                  onChanged: (value) => setState(() => selectedSubfolder = value),
                  secondary: Icon(Icons.folder_outlined, color: isSelected ? theme.primary : theme.supportingText),
                );
              },
            ),
          ),
        ] else if (!useAsBaseFolder) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.secondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomText('No subfolders found in this directory', color: theme.onSurface, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsStep() {
    final theme = ref;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
          ),
          child: SwitchListTile(
            title: CustomText('Include subfolders', color: theme.onSurface, fontWeight: FontWeight.w600),
            subtitle: CustomText(
              'Add files from all subfolders recursively',
              color: theme.supportingText,
              fontSize: 13,
            ),
            value: includeSubfolders,
            activeColor: theme.primary,
            secondary: Icon(includeSubfolders ? Icons.account_tree : Icons.folder, color: theme.primary),
            onChanged: (value) => setState(() => includeSubfolders = value),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Icon(Icons.filter_list, color: theme.primary, size: 20),
            const SizedBox(width: 8),
            CustomText('File Types', fontWeight: FontWeight.bold, color: theme.onSurface, fontSize: 18),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  final allEnabled = fileFilters.every((f) => f.isEnabled);
                  for (var filter in fileFilters) {
                    filter.isEnabled = !allEnabled;
                  }
                });
              },
              child: CustomText(
                fileFilters.every((f) => f.isEnabled) ? 'Deselect All' : 'Select All',
                color: theme.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: fileFilters.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: theme.supportingText.withValues(alpha: 0.1)),
            itemBuilder: (context, index) {
              final filter = fileFilters[index];

              return SwitchListTile(
                dense: true,
                title: CustomText(filter.displayName, color: theme.onSurface, fontSize: 14),
                subtitle: CustomText(filter.extension, color: theme.supportingText, fontSize: 12),
                value: filter.isEnabled,
                activeColor: theme.primary,
                secondary: Icon(filter.icon, color: filter.isEnabled ? theme.primary : theme.supportingText, size: 20),
                onChanged: (value) => setState(() => filter.isEnabled = value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    final theme = ref;
    final targetFolder = useAsBaseFolder ? widget.folderNode : selectedSubfolder;

    if (targetFolder == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.secondary, size: 48),
            const SizedBox(height: 16),
            CustomText('Please select a folder', color: theme.onSurface, fontSize: 16, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final files = CourseFolderImportManager.getFilteredFiles(targetFolder, fileFilters, includeSubfolders);

    final hasSubfolders = targetFolder.subfolders.isNotEmpty;
    final enabledFilters = fileFilters.where((f) => f.isEnabled).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primary.withValues(alpha: 0.1), theme.secondary.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: theme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText('Course Name', fontSize: 12, color: theme.supportingText),
                        const SizedBox(height: 4),
                        CustomText(
                          targetFolder.name,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.onSurface,
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
                  _buildStatChip(ref.theme, Icons.insert_drive_file, '${files.length}', 'Files'),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    ref.theme,
                    Icons.folder,
                    hasSubfolders ? '${targetFolder.subfolders.length}' : '1',
                    'Collections',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // File Types Summary
        if (enabledFilters.isNotEmpty) ...[
          CustomText('Enabled File Types:', fontWeight: FontWeight.bold, color: theme.onSurface, fontSize: 16),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: enabledFilters.map((filter) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(filter.icon, size: 16, color: theme.primary),
                    const SizedBox(width: 6),
                    CustomText(filter.extension, fontSize: 12, color: theme.onSurface),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Collections Preview
        CustomText('Collections:', fontWeight: FontWeight.bold, color: theme.onSurface, fontSize: 16),
        const SizedBox(height: 12),

        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: hasSubfolders ? targetFolder.subfolders.length + (targetFolder.files.isNotEmpty ? 1 : 0) : 1,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: theme.supportingText.withValues(alpha: 0.1)),
            itemBuilder: (context, index) {
              if (hasSubfolders) {
                if (index < targetFolder.subfolders.length) {
                  final folder = targetFolder.subfolders[index];
                  final subFiles = CourseFolderImportManager.getFilteredFiles(folder, fileFilters, includeSubfolders);
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.folder, color: theme.primary, size: 20),
                    title: CustomText(folder.name, color: theme.onSurface, fontSize: 14),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomText('${subFiles.length} files', fontSize: 12, color: theme.primary),
                    ),
                  );
                } else {
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.folder_special, color: theme.secondary, size: 20),
                    title: CustomText('Materials', color: theme.onSurface, fontSize: 14),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomText('${targetFolder.files.length} files', fontSize: 12, color: theme.secondary),
                    ),
                  );
                }
              } else {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.folder_special, color: theme.primary, size: 20),
                  title: CustomText('Materials', color: theme.onSurface, fontSize: 14),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomText('${files.length} files', fontSize: 12, color: theme.primary),
                  ),
                );
              }
            },
          ),
        ),

        const SizedBox(height: 24),

        // Import Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: files.isEmpty ? null : _processImport,
            icon: const Icon(Icons.upload_file),
            label: const Text('Start Import'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        if (files.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: theme.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    'No files match the selected file types',
                    color: theme.supportingText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
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
                CustomText(value, fontWeight: FontWeight.bold, fontSize: 16, color: theme.onSurface),
                CustomText(label, fontSize: 11, color: theme.supportingText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (!useAsBaseFolder && selectedSubfolder == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Please select a subfolder'), backgroundColor: ref.secondary));
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  Future<void> _processImport() async {
    final theme = ref;
    final progressNotifier = ValueNotifier<ImportProgress>(ImportProgress(message: 'Starting import...'));

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportProgressDialog(progressNotifier: progressNotifier),
    );

    final config = FolderImportConfig(
      baseFolderPath: widget.folderNode.path,
      useAsBaseFolder: useAsBaseFolder,
      selectedSubfolderPath: selectedSubfolder?.path,
      includeSubfolders: includeSubfolders,
      fileFilters: fileFilters,
    );

    final result = await CourseFolderImportManager.processImport(config, progressNotifier);

    if (mounted) {
      Navigator.of(context).pop(); // Close progress dialog
      Navigator.of(context).pop(); // Close import dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.isSuccess ? result.data! : 'Error: ${result.message}'),
          backgroundColor: result.isSuccess ? Colors.green : theme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    progressNotifier.dispose();
  }
}

/// Progress dialog for import process
class _ImportProgressDialog extends ConsumerWidget {
  final ValueNotifier<ImportProgress> progressNotifier;

  const _ImportProgressDialog({required this.progressNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<ImportProgress>(
          valueListenable: progressNotifier,
          builder: (context, progress, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload, color: theme.primary, size: 48),
                const SizedBox(height: 20),

                CustomText('Importing Course', fontSize: 20, fontWeight: FontWeight.bold, color: theme.onSurface),

                const SizedBox(height: 24),

                CircularProgressIndicator(color: theme.primary),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.altBackgroundPrimary, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      if (progress.currentCollection != null && progress.totalCollections != null) ...[
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
