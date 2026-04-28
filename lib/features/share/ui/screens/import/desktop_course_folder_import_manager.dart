import 'dart:io';
import 'dart:developer';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'course_folder_import_manager.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/browse/logic/src/contents/add_content/store_contents.dart';
import 'package:slidesync/features/browse/logic/entities/store_content_args.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:uuid/uuid.dart';

class FolderNode {
  final String name;
  final String path; // Changed from uri to path for Windows
  final List<FolderNode> subfolders;
  final List<File> files; // Changed to File for Windows
  bool isSelected;

  FolderNode({
    required this.name,
    required this.path,
    this.subfolders = const [],
    this.files = const [],
    this.isSelected = false,
  });

  FolderNode copyWith({String? name, String? path, List<FolderNode>? subfolders, List<File>? files, bool? isSelected}) {
    return FolderNode(
      name: name ?? this.name,
      path: path ?? this.path,
      subfolders: subfolders ?? this.subfolders,
      files: files ?? this.files,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Configuration for folder import on desktop.
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
    this.includeSubfolders = true,
    required this.fileFilters,
    this.maxContents = 1000,
  });
}

/// Main class for managing folder imports on Windows
class CourseFolderImportManagerWindows {
  static const int kMaxContents = 1000;

  /// Default file type filters (NO audio/video)
  static List<FileTypeFilter> getDefaultFileFilters() {
    return CourseFolderImportManagerCore.getDefaultFileFilters();
  }

  /// Pick a folder using file_picker
  static Future<String?> pickFolder() async {
    try {
      final String? selectedPath = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select Course Folder');

      if (selectedPath != null) {
        log('📂 Selected folder path: $selectedPath');
        return selectedPath;
      }

      return null;
    } catch (e) {
      log('❌ Error picking folder: $e');
      return null;
    }
  }

  /// Scan a folder and build its structure
  static Future<Result<FolderNode?>> scanFolder(String folderPath) async {
    return await Result.tryRunAsync(() async {
      log('📂 Scanning folder path: $folderPath');

      try {
        final directory = Directory(folderPath);

        if (!await directory.exists()) {
          throw Exception('Directory does not exist: $folderPath');
        }

        // Get directory contents
        final List<FileSystemEntity> contents = await directory.list().toList();
        log('✅ Found ${contents.length} items in folder');

        final List<FolderNode> subfolders = [];
        final List<File> files = [];
        final directories = <Directory>[];

        // Split directories and files first so subfolder scans can run in parallel.
        for (final item in contents) {
          try {
            if (item is Directory) {
              final dirName = p.basename(item.path);
              log('   └─ Is Directory: $dirName');
              directories.add(item);
            } else if (item is File) {
              final fileName = p.basename(item.path);
              log('   └─ Is File: $fileName');
              files.add(item);
            }
          } catch (e) {
            log('⚠️ Error processing item ${p.basename(item.path)}: $e');
            continue;
          }
        }

        if (directories.isNotEmpty) {
          await CourseFolderImportManagerCore.runInBatches<Directory>(directories, 5, (directory) async {
            final subfolder = await scanFolder(directory.path);
            if (subfolder.isSuccess && subfolder.data != null) {
              subfolders.add(subfolder.data!);
            }
          });
        }

        // Extract folder name from path
        final folderName = p.basename(folderPath);
        final node = FolderNode(name: folderName, path: folderPath, subfolders: subfolders, files: files);

        log('✅ Scanned $folderName: ${files.length} files, ${subfolders.length} subfolders');
        return node;
      } catch (e, stackTrace) {
        log('❌ ERROR during folder scan: $e');
        log('Stack trace: $stackTrace');
        throw Exception('Failed to scan folder: $e');
      }
    });
  }

  /// Get all files from a folder node based on filters
  static List<File> getFilteredFiles(FolderNode node, List<FileTypeFilter> filters, bool includeSubfolders) {
    return CourseFolderImportManagerCore.getFilteredFiles<FolderNode, File>(
      folder: node,
      filters: filters,
      includeSubfolders: includeSubfolders,
      getFiles: (folder) => folder.files,
      getSubfolders: (folder) => folder.subfolders,
      getFileExtension: (file) => p.extension(file.path),
    );
  }

  /// Calculate what will actually be imported
  static Map<String, List<File>> calculateImportStructure(
    FolderNode targetFolder,
    List<FileTypeFilter> filters,
    bool includeSubfolders,
  ) {
    return CourseFolderImportManagerCore.calculateImportStructure<FolderNode, File>(
      targetFolder: targetFolder,
      filters: filters,
      includeSubfolders: includeSubfolders,
      getFiles: (folder) => folder.files,
      getSubfolders: (folder) => folder.subfolders,
      getFolderName: (folder) => folder.name,
      getFileExtension: (file) => p.extension(file.path),
    );
  }

  /// Show the folder import screen
  static Future<void> showFolderImportScreen(BuildContext context) async {
    final folderPath = await pickFolder();

    if (folderPath == null) {
      log('❌ No folder selected');
      return;
    }

    log('🎯 Selected folder path: $folderPath');

    // Show loading while scanning
    GlobalNav.withContext((c) => UiUtils.showLoadingDialog(c, message: 'Scanning folder...'));

    // Scan the folder
    final scanResult = await scanFolder(folderPath);

    // Hide loading
    GlobalNav.popGlobal();

    if (!scanResult.isSuccess || scanResult.data == null) {
      log('❌ Scan failed: ${scanResult.message}');
      if (context.mounted) {
        UiUtils.showFlushBar(context, msg: 'Error scanning folder: ${scanResult.message}', vibe: FlushbarVibe.error);
      }
      return;
    }

    final folderNode = scanResult.data!;
    log('✅ Scan complete. Opening import screen...');

    if (context.mounted) {
      await Navigator.of(context).push(
        PageAnimation.pageRouteBuilder(_FolderImportScreen(folderNode: folderNode), type: TransitionType.rightToLeft),
      );
    }
  }

  /// Process the import with the given configuration
  static Future<Result<String?>> processImport(
    FolderImportConfig config,
    ValueNotifier<ImportProgress> progressNotifier,
  ) async {
    return await Result.tryRunAsync(() async {
      log('🚀 Starting import process...');
      progressNotifier.value = ImportProgress(message: 'Scanning folder structure...');

      // Scan the folder
      final scanResult = await scanFolder(
        config.useAsBaseFolder ? config.baseFolderPath : config.selectedSubfolderPath!,
      );

      if (!scanResult.isSuccess || scanResult.data == null) {
        throw Exception('Failed to scan folder: ${scanResult.message}');
      }

      final folderNode = scanResult.data!;
      log('📂 Folder scanned: ${folderNode.name}');

      final enabledExtensions = CourseFolderImportManagerCore.getEnabledExtensions(config.fileFilters);

      progressNotifier.value = ImportProgress(message: 'Creating course...');

      // Determine if we have subfolders or just files
      final hasSubfolders = folderNode.subfolders.isNotEmpty;
      final baseCourseName = folderNode.name;

      log('📚 Creating course: $baseCourseName (has subfolders: $hasSubfolders)');

      // Create the Course
      final course = Course.create(title: baseCourseName, description: 'Imported from folder: ${folderNode.name}');

      final courseDbId = await CourseRepo.addCourse(course);
      if (courseDbId == -1) {
        throw Exception('Failed to create course');
      }

      log('✅ Course created with ID: ${course.uid}');

      // Get filtered root files
      final rootFiles = folderNode.files.where((file) {
        final ext = p.extension(file.path).toLowerCase();
        return enabledExtensions.contains(ext);
      }).toList();

      log('📄 Root files: ${rootFiles.length}');

      // Calculate total collections to process
      int totalCollections = 0;
      if (hasSubfolders) {
        totalCollections = folderNode.subfolders.length;
        if (rootFiles.isNotEmpty) {
          totalCollections++;
        }
      } else {
        totalCollections = 1;
      }

      log('📦 Will create $totalCollections collection(s)');

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

          log('📁 Processing subfolder: ${subfolder.name}');

          final collection = Module.create(
            parentId: course.uid,
            title: subfolder.name,
            description: 'Collection from folder: ${subfolder.name}',
          );

          final addResult = await ModuleRepo.addCollectionNoDuplicateTitle(collection);
          if (addResult != null) {
            log('⚠️ Collection "${subfolder.name}" already exists or error: $addResult');
            continue;
          }

          // Get files for this collection
          final files = getFilteredFiles(subfolder, config.fileFilters, config.includeSubfolders);

          if (files.isNotEmpty) {
            final limitedFiles = files.take(config.maxContents).toList();
            log('📤 Adding ${limitedFiles.length} files to ${subfolder.name}');

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

            log('✅ Files added to ${subfolder.name}');
          }
        }

        // Handle root files - create "Base" collection
        if (rootFiles.isNotEmpty) {
          currentCollectionIndex++;

          progressNotifier.value = ImportProgress(
            message: 'Creating base collection...',
            currentCollection: currentCollectionIndex,
            totalCollections: totalCollections,
            currentCollectionName: 'Base',
          );

          log('📁 Creating Base collection for root files');

          final rootCollection = Module.create(
            parentId: course.uid,
            title: 'Base',
            description: 'Base folder materials',
          );

          await ModuleRepo.addCollectionNoDuplicateTitle(rootCollection);

          final limitedFiles = rootFiles.take(config.maxContents).toList();
          log('📤 Adding ${limitedFiles.length} files to Base');

          await _addFilesToCollection(
            rootCollection,
            limitedFiles,
            progressNotifier,
            currentCollectionIndex,
            totalCollections,
            'Base',
          );

          log('✅ Base collection created');
        }
      } else {
        // No subfolders, just files
        currentCollectionIndex++;

        progressNotifier.value = ImportProgress(
          message: 'Creating materials collection...',
          currentCollection: currentCollectionIndex,
          totalCollections: totalCollections,
          currentCollectionName: 'Materials',
        );

        log('📁 Creating Materials collection (no subfolders)');

        final collection = Module.create(parentId: course.uid, title: 'Materials', description: 'Course materials');

        final addResult = await ModuleRepo.addCollectionNoDuplicateTitle(collection);
        if (addResult != null) {
          throw Exception(addResult);
        }

        final files = getFilteredFiles(folderNode, config.fileFilters, false);
        if (files.isNotEmpty) {
          final limitedFiles = files.take(config.maxContents).toList();
          log('📤 Adding ${limitedFiles.length} files to Materials');

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

          log('✅ Materials collection created');
        }
      }

      progressNotifier.value = ImportProgress(message: 'Import complete!');
      log('🎉 Import complete: $baseCourseName');

      return 'Successfully imported course: $baseCourseName with $totalCollections collection(s)';
    });
  }

  static Future<void> _addFilesToCollection(
    Module collection,
    List<File> files,
    ValueNotifier<ImportProgress> progressNotifier,
    int currentCollection,
    int totalCollections,
    String collectionName,
  ) async {
    final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw Exception('Unable to process adding content in background');
    }

    final limitedFiles = files.take(kMaxContents).toList();
    final Directory tempDir = await getApplicationCacheDirectory();
    final List<String?> copiedFilePaths = List<String?>.filled(limitedFiles.length, null);
    final List<String?> uuids = List<String?>.filled(limitedFiles.length, null);
    final List<String?> uuidFileNames = List<String?>.filled(limitedFiles.length, null);
    final indexedFiles = [for (int i = 0; i < limitedFiles.length; i++) (index: i, file: limitedFiles[i])];
    int processedCount = 0;
    DateTime? lastProgressUpdate;

    try {
      progressNotifier.value = ImportProgress(
        message: 'Processing files...',
        currentCollection: currentCollection,
        totalCollections: totalCollections,
        currentCollectionName: collectionName,
      );

      await CourseFolderImportManagerCore.runInBatches<({int index, File file})>(indexedFiles, 4, (entry) async {
        final file = entry.file;

        try {
          final uuid = const Uuid().v4();
          final originalFileName = p.basename(file.path);
          final tempFile = File(p.join(tempDir.path, originalFileName));

          await file.copy(tempFile.path);

          uuids[entry.index] = uuid;
          uuidFileNames[entry.index] = originalFileName;
          copiedFilePaths[entry.index] = tempFile.path;

          processedCount++;
          if (CourseFolderImportManagerCore.shouldThrottleProgressUpdate(
            processedCount: processedCount,
            totalCount: limitedFiles.length,
            lastUpdate: lastProgressUpdate,
          )) {
            lastProgressUpdate = DateTime.now();
            progressNotifier.value = ImportProgress(
              message: 'Processing files... $processedCount/${limitedFiles.length}',
              currentCollection: currentCollection,
              totalCollections: totalCollections,
              currentCollectionName: collectionName,
            );
          }

          log('✅ Copied file ${entry.index + 1}/${limitedFiles.length}: $originalFileName');
        } catch (e) {
          processedCount++;
          log('❌ Failed to copy file ${p.basename(file.path)}: $e');
        }
      });

      final successfulFilePaths = copiedFilePaths.whereType<String>().toList();
      final successfulUuids = uuids.whereType<String>().toList();
      final successfulFileNames = uuidFileNames.whereType<String>().toList();

      if (successfulFilePaths.isEmpty) {
        throw Exception('No files could be copied from the selected folder');
      }

      // Store progress data
      await Result.tryRunAsync(() async {
        await AppHiveData.instance.setData(
          key: HiveDataPathKey.contentsAddingProgressList.name,
          value: <String, dynamic>{
            for (int i = 0; i < successfulFileNames.length; i++) successfulFileNames[i]: successfulFilePaths[i],
            'collectionId': collection.uid,
          },
        );
      });

      final args = StoreContentArgs(
        token: rootIsolateToken,
        collectionId: collection.uid,
        filePaths: successfulFilePaths,
        uuids: successfulUuids,
        deleteCache: true,
      ).toMap();

      // Create progress notifier wrapper
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
    } catch (e, stackTrace) {
      log('❌ Error adding files to collection: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

/// Full screen widget for folder import
class _FolderImportScreen extends ConsumerStatefulWidget {
  final FolderNode folderNode;

  const _FolderImportScreen({required this.folderNode});

  @override
  ConsumerState<_FolderImportScreen> createState() => _FolderImportScreenState();
}

class _FolderImportScreenState extends ConsumerState<_FolderImportScreen> {
  late bool useAsBaseFolder;
  late bool includeSubfolders;
  late List<FileTypeFilter> fileFilters;
  FolderNode? selectedSubfolder;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    useAsBaseFolder = true;
    includeSubfolders = true;
    fileFilters = CourseFolderImportManagerWindows.getDefaultFileFilters();
    log('Import screen initialized');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;

    return AppScaffold(
      title: "",
      backgroundColor: theme.background,
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          context.isDarkMode,
          title: "Import Course from Folder",
          subtitle: 'Step ${_currentStep + 1} of 3',
        ),
      ),
      body: SingleChildScrollView(
        child: TopPadding(
          withHeight: kToolbarHeight,
          child: BottomPadding(
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ),
    );
  }

  Widget _buildBaseFolderStep() {
    final theme = ref.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primary.withValues(alpha: 0.15), theme.secondary.withValues(alpha: 0.15)],
            ),
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
            activeThumbColor: theme.primary,
            onChanged: (value) => setState(() {
              useAsBaseFolder = value;
              if (value) selectedSubfolder = null;
              log('🔄 Use as base folder: $value');
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
            child: SmoothListView.separated(
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
                  onChanged: (value) => setState(() {
                    selectedSubfolder = value;
                    log('📁 Selected subfolder: ${value?.name}');
                  }),
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
    final theme = ref.theme;

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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: CustomText('Include subfolders', color: theme.onSurface, fontWeight: FontWeight.w600),
            subtitle: CustomText(
              'Add files from all subfolders recursively',
              color: theme.supportingText,
              fontSize: 13,
            ),
            value: includeSubfolders,
            activeThumbColor: theme.primary,
            secondary: Icon(includeSubfolders ? Icons.account_tree : Icons.folder, color: theme.primary),
            onChanged: (value) => setState(() {
              includeSubfolders = value;
              log('🔄 Include subfolders: $value');
            }),
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
                  log('🔄 ${allEnabled ? "Deselected" : "Selected"} all filters');
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
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.supportingText.withValues(alpha: 0.2)),
          ),
          child: SmoothListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: fileFilters.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final filter = fileFilters[index];

              return SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                dense: true,
                title: CustomText(filter.displayName, color: theme.onSurface, fontSize: 14),
                subtitle: CustomText(filter.extension, color: theme.supportingText, fontSize: 12),
                shape: const RoundedRectangleBorder(),
                value: filter.isEnabled,
                activeThumbColor: theme.primary,
                secondary: Icon(filter.icon, color: filter.isEnabled ? theme.primary : theme.supportingText, size: 20),
                onChanged: (value) => setState(() {
                  filter.isEnabled = value;
                  log('🔄 ${filter.extension} ${value ? "enabled" : "disabled"}');
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    final theme = ref.theme;
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

    final importStructure = CourseFolderImportManagerWindows.calculateImportStructure(
      targetFolder,
      fileFilters,
      includeSubfolders,
    );
    final totalFiles = importStructure.values.fold<int>(0, (sum, files) => sum + files.length);
    final enabledFilters = fileFilters.where((f) => f.isEnabled).toList();

    log('📊 Preview: ${importStructure.length} collections, $totalFiles files');

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
                  _buildStatChip(theme, Icons.insert_drive_file, '$totalFiles', 'Files'),
                  const SizedBox(width: 12),
                  _buildStatChip(theme, Icons.folder, '${importStructure.length}', 'Collections'),
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
          child: SmoothListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: importStructure.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final entry = importStructure.entries.elementAt(index);
              final collectionName = entry.key;
              final files = entry.value;
              final isBase = collectionName == 'Base';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                dense: true,
                shape: const RoundedRectangleBorder(),
                leading: Icon(
                  isBase ? Icons.folder_special : Icons.folder,
                  color: isBase ? theme.secondary : theme.primary,
                  size: 20,
                ),
                title: CustomText(collectionName, color: theme.onSurface, fontSize: 14),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isBase ? theme.secondary : theme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    '${files.length} files',
                    fontSize: 12,
                    color: isBase ? theme.secondary : theme.primary,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Import Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: totalFiles == 0 ? null : _processImport,
            icon: const Icon(Icons.upload_file),
            label: const Text('Start Import'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              disabledBackgroundColor: theme.supportingText.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (totalFiles == 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: theme.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    enabledFilters.isEmpty
                        ? 'Please enable at least one file type'
                        : 'No files match the selected file types in this folder',
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
        UiUtils.showFlushBar(context, msg: 'Please select a subfolder', vibe: FlushbarVibe.warning);
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  Future<void> _processImport() async {
    log('🚀 Starting import...');
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

    final result = await CourseFolderImportManagerWindows.processImport(config, progressNotifier);

    if (mounted) {
      context.pop(); // Close progress dialog
      context.pop(); // Close import screen

      UiUtils.showFlushBar(
        context,
        msg: result.isSuccess ? result.data! : 'Error: ${result.message}',
        vibe: result.isSuccess ? FlushbarVibe.success : FlushbarVibe.warning,
      );

      progressNotifier.dispose();
    }

    log(result.isSuccess ? '✅ Import completed successfully' : '❌ Import failed: ${result.message}');
  }
}

/// Progress dialog for import process
class _ImportProgressDialog extends ConsumerWidget {
  final ValueNotifier<ImportProgress> progressNotifier;

  const _ImportProgressDialog({required this.progressNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.theme;

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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primary.withValues(alpha: 0.1), theme.secondary.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
