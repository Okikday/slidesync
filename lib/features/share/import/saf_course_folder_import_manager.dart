import 'dart:io';
import 'dart:developer';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/store_contents.dart';
import 'package:slidesync/features/manage/domain/usecases/types/store_content_args.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/theme/src/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

class FolderNode {
  final String name;
  final String uri;
  final List<FolderNode> subfolders;
  final List<SafDocumentFile> files; // Changed to SafDocumentFile
  bool isSelected;

  FolderNode({
    required this.name,
    required this.uri,
    this.subfolders = const [],
    this.files = const [],
    this.isSelected = false,
  });

  FolderNode copyWith({
    String? name,
    String? uri,
    List<FolderNode>? subfolders,
    List<SafDocumentFile>? files,
    bool? isSelected,
  }) {
    return FolderNode(
      name: name ?? this.name,
      uri: uri ?? this.uri,
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
  final String baseFolderUri;
  final bool useAsBaseFolder;
  final String? selectedSubfolderUri;
  final bool includeSubfolders;
  final List<FileTypeFilter> fileFilters;
  final int maxContents;

  FolderImportConfig({
    required this.baseFolderUri,
    this.useAsBaseFolder = true,
    this.selectedSubfolderUri,
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

/// Main class for managing folder imports with SAF
class CourseFolderImportManager {
  static const int kMaxContents = 1000;
  static final SafUtil _safUtil = SafUtil();
  static final SafStream _safStream = SafStream();

  /// Default file type filters (NO audio/video)
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

      // Archives
      FileTypeFilter(extension: '.zip', displayName: 'ZIP Archives', icon: Icons.folder_zip, isEnabled: false),
      FileTypeFilter(extension: '.rar', displayName: 'RAR Archives', icon: Icons.folder_zip, isEnabled: false),
    ];
  }

  /// Pick a folder using SAF
  static Future<String?> pickFolder() async {
    try {
      final String? treeUri = (await _safUtil.pickDirectory())?.uri;

      if (treeUri != null) {
        log('📂 Selected folder URI: $treeUri');
        return treeUri;
      }

      return null;
    } catch (e) {
      log('❌ Error picking folder: $e');
      return null;
    }
  }

  /// Scan a folder and build its structure using SAF
  static Future<Result<FolderNode?>> scanFolder(String folderUri) async {
    return await Result.tryRunAsync(() async {
      log('📂 Scanning folder URI: $folderUri');

      try {
        // Get directory contents using saf_util
        final List<SafDocumentFile> contents = await _safUtil.list(folderUri);

        log('✅ Found ${contents.length} items in folder');

        final List<FolderNode> subfolders = [];
        final List<SafDocumentFile> files = [];

        // Process each item
        for (final item in contents) {
          try {
            if (item.isDir) {
              log('   └─ Is Directory: ${item.name}');
              // Recursively scan subfolder
              final subfolder = await scanFolder(item.uri);
              if (subfolder.isSuccess && subfolder.data != null) {
                subfolders.add(subfolder.data!);
              }
            } else {
              log('   └─ Is File: ${item.name}');
              files.add(item);
            }
          } catch (e) {
            log('⚠️ Error processing item ${item.name}: $e');
            continue;
          }
        }

        // Extract folder name from URI
        String folderName = 'Folder';
        try {
          // SAF URIs typically end with the encoded folder name after the last '/'
          final decodedUri = Uri.decodeComponent(folderUri);
          final lastSlashIndex = decodedUri.lastIndexOf('/');
          if (lastSlashIndex != -1 && lastSlashIndex < decodedUri.length - 1) {
            // Get everything after the last slash
            final afterSlash = decodedUri.substring(lastSlashIndex + 1);
            // If it contains a colon (like "primary:Documents/Year 1/FSC 101"), get after last colon
            final lastColonIndex = afterSlash.lastIndexOf(':');
            if (lastColonIndex != -1) {
              final afterColon = afterSlash.substring(lastColonIndex + 1);
              // Get the last folder name (after last '/')
              final pathParts = afterColon.split('/');
              folderName = pathParts.last.trim();
            } else {
              folderName = afterSlash.trim();
            }
          }

          if (folderName.isEmpty) folderName = 'Folder';
        } catch (e) {
          log('⚠️ Could not extract folder name from URI: $e');
          folderName = 'Folder';
        }

        final node = FolderNode(name: folderName, uri: folderUri, subfolders: subfolders, files: files);

        log('✅ Scanned $folderName: ${files.length} files, ${subfolders.length} subfolders');
        return node;
      } catch (e, stackTrace) {
        log('❌ ERROR during SAF scan: $e');
        log('Stack trace: $stackTrace');
        throw Exception('Failed to scan folder: $e');
      }
    });
  }

  /// Get all files from a folder node based on filters
  static List<SafDocumentFile> getFilteredFiles(FolderNode node, List<FileTypeFilter> filters, bool includeSubfolders) {
    final List<SafDocumentFile> allFiles = [];
    final enabledExtensions = filters.where((f) => f.isEnabled).map((f) => f.extension.toLowerCase()).toSet();

    log('🔍 Getting filtered files from ${node.name}. Enabled extensions: $enabledExtensions');

    if (enabledExtensions.isEmpty) {
      log('⚠️ No file type filters enabled');
      return allFiles;
    }

    // Add files from current folder
    for (final file in node.files) {
      final fileName = file.name;
      final ext = p.extension(fileName).toLowerCase();
      if (enabledExtensions.contains(ext)) {
        allFiles.add(file);
      }
    }

    log('📄 Found ${allFiles.length} matching files in ${node.name}');

    // Add files from subfolders if enabled
    if (includeSubfolders) {
      for (final subfolder in node.subfolders) {
        allFiles.addAll(getFilteredFiles(subfolder, filters, true));
      }
    }

    return allFiles;
  }

  /// Calculate what will actually be imported
  static Map<String, List<SafDocumentFile>> calculateImportStructure(
    FolderNode targetFolder,
    List<FileTypeFilter> filters,
    bool includeSubfolders,
  ) {
    final Map<String, List<SafDocumentFile>> collections = {};
    final hasSubfolders = targetFolder.subfolders.isNotEmpty;

    log('📊 Calculating import structure for ${targetFolder.name}');
    log('   Has subfolders: $hasSubfolders, Include subfolders: $includeSubfolders');

    if (hasSubfolders) {
      // Create collection for each subfolder
      for (final subfolder in targetFolder.subfolders) {
        final files = getFilteredFiles(subfolder, filters, includeSubfolders);
        if (files.isNotEmpty) {
          collections[subfolder.name] = files;
          log('   Collection "${subfolder.name}": ${files.length} files');
        }
      }

      // Add root files as "Base" collection if they exist
      final rootFiles = targetFolder.files.where((file) {
        final fileName = file.name;
        final ext = p.extension(fileName).toLowerCase();
        final enabledExtensions = filters.where((f) => f.isEnabled).map((f) => f.extension.toLowerCase()).toSet();
        return enabledExtensions.contains(ext);
      }).toList();

      if (rootFiles.isNotEmpty) {
        collections['Base'] = rootFiles;
        log('   Collection "Base": ${rootFiles.length} files');
      }
    } else {
      // No subfolders, create single "Materials" collection
      final files = getFilteredFiles(targetFolder, filters, false);
      if (files.isNotEmpty) {
        collections['Materials'] = files;
        log('   Collection "Materials": ${files.length} files');
      }
    }

    final totalFiles = collections.values.fold<int>(0, (sum, files) => sum + files.length);
    log('✅ Total structure: ${collections.length} collections, $totalFiles files');

    return collections;
  }

  /// Show the folder import screen
  static Future<void> showFolderImportScreen(BuildContext context) async {
    final folderUri = await pickFolder();

    if (folderUri == null) {
      log('❌ No folder selected');
      return;
    }

    log('🎯 Selected folder URI: $folderUri');

    // Show loading while scanning
    GlobalNav.withContext((c) => UiUtils.showLoadingDialog(c, message: 'Scanning folder...'));

    // Scan the folder
    final scanResult = await scanFolder(folderUri);

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
      final scanResult = await scanFolder(config.useAsBaseFolder ? config.baseFolderUri : config.selectedSubfolderUri!);

      if (!scanResult.isSuccess || scanResult.data == null) {
        throw Exception('Failed to scan folder: ${scanResult.message}');
      }

      final folderNode = scanResult.data!;
      log('📂 Folder scanned: ${folderNode.name}');

      progressNotifier.value = ImportProgress(message: 'Creating course...');

      // Determine if we have subfolders or just files
      final hasSubfolders = folderNode.subfolders.isNotEmpty;
      final baseCourseName = folderNode.name;

      log('📚 Creating course: $baseCourseName (has subfolders: $hasSubfolders)');

      // Create the Course
      final course = Course.create(
        courseTitle: baseCourseName,
        description: 'Imported from folder: ${folderNode.name}',
      );

      final courseDbId = await CourseRepo.addCourse(course);
      if (courseDbId == -1) {
        throw Exception('Failed to create course');
      }

      log('✅ Course created with ID: ${course.courseId}');

      // Get filtered root files
      final rootFiles = folderNode.files.where((file) {
        final fileName = file.name;
        final ext = p.extension(fileName).toLowerCase();
        final enabledExtensions = config.fileFilters
            .where((f) => f.isEnabled)
            .map((f) => f.extension.toLowerCase())
            .toSet();
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

          final collection = CourseCollection.create(
            parentId: course.courseId,
            collectionTitle: subfolder.name,
            description: 'Collection from folder: ${subfolder.name}',
          );

          final addResult = await CourseCollectionRepo.addCollectionNoDuplicateTitle(collection);
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

          final rootCollection = CourseCollection.create(
            parentId: course.courseId,
            collectionTitle: 'Base',
            description: 'Base folder materials',
          );

          await CourseCollectionRepo.addCollectionNoDuplicateTitle(rootCollection);

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
    CourseCollection collection,
    List<SafDocumentFile> safFiles,
    ValueNotifier<ImportProgress> progressNotifier,
    int currentCollection,
    int totalCollections,
    String collectionName,
  ) async {
    final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw Exception('Unable to process adding content in background');
    }

    final limitedFiles = safFiles.take(kMaxContents).toList();
    final Directory tempDir = await getApplicationCacheDirectory();
    final List<String> copiedFilePaths = [];
    final List<String> uuids = [];
    final List<String> uuidFileNames = [];

    try {
      progressNotifier.value = ImportProgress(
        message: 'Processing files...',
        currentCollection: currentCollection,
        totalCollections: totalCollections,
        currentCollectionName: collectionName,
      );

      for (int i = 0; i < limitedFiles.length; i++) {
        final safFile = limitedFiles[i];

        try {
          // Generate UUID and keep original file name
          final uuid = const Uuid().v4();
          final originalFileName = safFile.name;

          uuids.add(uuid);
          uuidFileNames.add(originalFileName);

          // Write to temp directory with original filename using streaming
          final tempFile = File(p.join(tempDir.path, originalFileName));
          final sink = tempFile.openWrite();

          try {
            // Stream the file in chunks instead of loading all into memory
            final Stream<List<int>> fileStream = await _safStream.readFileStream(safFile.uri);
            await for (final chunk in fileStream) {
              sink.add(chunk);
            }
          } finally {
            await sink.flush();
            await sink.close();
          }

          copiedFilePaths.add(tempFile.path);

          if (i % 5 == 0) {
            progressNotifier.value = ImportProgress(
              message: 'Processing files... ${i + 1}/${limitedFiles.length}',
              currentCollection: currentCollection,
              totalCollections: totalCollections,
              currentCollectionName: collectionName,
            );
          }

          log('✅ Copied file ${i + 1}/${limitedFiles.length}: $originalFileName');
        } catch (e) {
          log('❌ Failed to read file ${safFile.name}: $e');
          // Continue with next file instead of failing entire import
          continue;
        }
      }

      if (copiedFilePaths.isEmpty) {
        throw Exception('No files could be read from the selected folder');
      }

      // Store progress data
      await Result.tryRunAsync(() async {
        await AppHiveData.instance.setData(
          key: HiveDataPathKey.contentsAddingProgressList.name,
          value: <String, dynamic>{
            for (int i = 0; i < uuidFileNames.length; i++) uuidFileNames[i]: copiedFilePaths[i],
            'collectionId': collection.collectionId,
          },
        );
      });

      final args = StoreContentArgs(
        token: rootIsolateToken,
        collectionId: collection.collectionId,
        filePaths: copiedFilePaths,
        uuids: uuids,
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
    includeSubfolders = false;
    fileFilters = CourseFolderImportManager.getDefaultFileFilters();
    log('🎬 Import screen initialized');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Import Course from Folder', fontSize: 18, fontWeight: FontWeight.bold, color: theme.onSurface),
            CustomText('Step ${_currentStep + 1} of 3', fontSize: 12, color: theme.supportingText),
          ],
        ),
      ),
      body: Theme(
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
          child: ListView.separated(
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

    // Use the new calculation method that matches processImport
    final importStructure = CourseFolderImportManager.calculateImportStructure(
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
          child: ListView.separated(
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
      baseFolderUri: widget.folderNode.uri,
      useAsBaseFolder: useAsBaseFolder,
      selectedSubfolderUri: selectedSubfolder?.uri,
      includeSubfolders: includeSubfolders,
      fileFilters: fileFilters,
    );

    final result = await CourseFolderImportManager.processImport(config, progressNotifier);

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
