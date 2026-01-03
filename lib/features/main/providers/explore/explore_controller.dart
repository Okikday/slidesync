import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/legacy.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/features/main/ui/models/explore_card_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/features/main/ui/widgets/explore_tab_view/explore_card.dart';
import 'package:slidesync/features/sync/logic/firebase_sync_repository.dart';
import 'package:slidesync/features/sync/logic/models/sync_model.dart';

class ExploreController extends StateNotifier<ExploreState> {
  final FirebaseSyncRepository _firebaseRepo;

  // Pagination controllers with new API
  late final PagingController<int, ExploreCardData> _coursesController;
  late final PagingController<int, ExploreCardData> _collectionsController;
  late final PagingController<int, ExploreCardData> _contentsController;

  // Cache for loaded items
  final Map<ExploreCardType, List<ExploreCardData>> _cache = {};

  // Search debouncer
  Timer? _searchDebouncer;

  static const int _pageSize = 20;

  ExploreController(this._firebaseRepo) : super(ExploreState.initial()) {
    _initControllers();
  }

  // Getters for pagination controllers
  PagingController<int, ExploreCardData> get currentController {
    switch (state.selectedType) {
      case ExploreCardType.course:
        return _coursesController;
      case ExploreCardType.collection:
        return _collectionsController;
      case ExploreCardType.content:
        return _contentsController;
    }
  }

  void _initControllers() {
    // Initialize courses controller
    _coursesController = PagingController<int, ExploreCardData>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (pageKey) async => await _fetchPage(pageKey, ExploreCardType.course),
    );

    // Initialize collections controller
    _collectionsController = PagingController<int, ExploreCardData>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (pageKey) async => await _fetchPage(pageKey, ExploreCardType.collection),
    );

    // Initialize contents controller
    _contentsController = PagingController<int, ExploreCardData>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: (pageKey) async {
        return await _fetchPage(pageKey, ExploreCardType.content);
      },
    );
  }

  Future<List<ExploreCardData>> fetchNextPage() async {
    final controller = _getControllerForType(state.selectedType);
    final nextPageKey = controller.keys?.last;
    if (nextPageKey == null) return [];
    return await _fetchPage(nextPageKey, state.selectedType);
  }

  /// Fetches a page of data
  Future<List<ExploreCardData>> _fetchPage(int pageKey, ExploreCardType type) async {
    try {
      final searchQuery = state.searchQuery.trim();
      final List<ExploreCardData> items;

      // Check cache first if no search
      if (searchQuery.isEmpty && _cache[type] != null && pageKey == 0) {
        items = _cache[type]!;
        log('Using cached data for ${type.name}');
      } else {
        // Fetch from Firebase
        items = await _fetchFromFirebase(type, pageKey, searchQuery);

        // Cache first page if no search
        if (pageKey == 0 && searchQuery.isEmpty) {
          _cache[type] = items;
        }
      }

      final isLastPage = items.length < _pageSize;
      final controller = _getControllerForType(type);

      if (isLastPage) {
        return items;
      } else {
        final nextPageKey = pageKey + items.length;
        return items;
      }
    } catch (e, st) {
      log('Error fetching page: $e\n$st');
      // _getControllerForType(type).value = e;
      return [];
    }
  }

  /// Fetches data from Firebase based on type
  Future<List<ExploreCardData>> _fetchFromFirebase(ExploreCardType type, int pageKey, String searchQuery) async {
    switch (type) {
      case ExploreCardType.course:
        return await _fetchCourses(searchQuery);
      case ExploreCardType.collection:
        return await _fetchCollections(searchQuery);
      case ExploreCardType.content:
        return await _fetchContents(searchQuery);
    }
  }

  /// Fetches courses from Firebase
  Future<List<ExploreCardData>> _fetchCourses(String searchQuery) async {
    final Result<List<RemoteCourse>> result;

    if (searchQuery.isEmpty) {
      result = await _firebaseRepo.listCourses(limit: _pageSize);
    } else {
      result = await _firebaseRepo.searchCourses(searchQuery);
    }

    if (!result.isSuccess) {
      throw Exception(result.message);
    }

    return result.data!.map((course) {
      return ExploreCardData(
        id: course.courseId,
        title: course.courseTitle,
        description: course.description,
        type: ExploreCardType.course,
        tags: _extractTags(course.metadataJson),
        authorName: _extractAuthor(course.metadataJson),
        uploadedAt: course.lastUpdated ?? course.createdAt ?? DateTime.now(),
        viewCount: 0,
        itemCount: course.collectionsCount,
        isFeatured: false,
        thumbnailUrl: _extractThumbnailUrl(course.metadataJson),
      );
    }).toList();
  }

  /// Fetches collections from Firebase
  Future<List<ExploreCardData>> _fetchCollections(String searchQuery) async {
    final result = await _firebaseRepo.listCourses(limit: 100);
    if (!result.isSuccess) {
      throw Exception(result.message);
    }

    final allCollections = <ExploreCardData>[];

    for (final course in result.data!) {
      final collectionsResult = await _firebaseRepo.listCollections(course.courseId);
      if (collectionsResult.isSuccess) {
        final collections = collectionsResult.data!
            .where((c) => searchQuery.isEmpty || c.collectionTitle.toLowerCase().contains(searchQuery.toLowerCase()))
            .map((collection) {
              return ExploreCardData(
                id: collection.collectionId,
                title: collection.collectionTitle,
                description: collection.description,
                type: ExploreCardType.collection,
                tags: _extractTags(collection.metadataJson),
                authorName: _extractAuthor(collection.metadataJson),
                uploadedAt: collection.createdAt ?? DateTime.now(),
                viewCount: 0,
                itemCount: collection.contentsCount,
                thumbnailUrl: _extractThumbnailUrl(collection.metadataJson),
              );
            })
            .toList();

        allCollections.addAll(collections);
      }
    }

    return allCollections.take(_pageSize).toList();
  }

  /// Fetches contents from Firebase
  Future<List<ExploreCardData>> _fetchContents(String searchQuery) async {
    final result = await _firebaseRepo.listCourses(limit: 100);
    if (!result.isSuccess) {
      throw Exception(result.message);
    }

    final allContents = <ExploreCardData>[];

    for (final course in result.data!) {
      final collectionsResult = await _firebaseRepo.listCollections(course.courseId);
      if (collectionsResult.isSuccess) {
        for (final collection in collectionsResult.data!) {
          final contentsResult = await _firebaseRepo.listContents(collection.collectionId);
          if (contentsResult.isSuccess) {
            final contents = contentsResult.data!
                .where((c) => searchQuery.isEmpty || c.title.toLowerCase().contains(searchQuery.toLowerCase()))
                .map((content) {
                  return ExploreCardData(
                    id: content.contentHash,
                    title: content.title,
                    description: content.description,
                    type: ExploreCardType.content,
                    tags: _extractTags(content.metadataJson),
                    authorName: _extractAuthor(content.metadataJson),
                    uploadedAt: content.uploadedAt ?? DateTime.now(),
                    viewCount: 0,
                    itemCount: 0,
                    thumbnailUrl: content.storageUrl,
                  );
                })
                .toList();

            allContents.addAll(contents);
          }
        }
      }
    }

    return allContents.take(_pageSize).toList();
  }

  // Helper methods remain the same
  List<String> _extractTags(String metadataJson) {
    try {
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      return List<String>.from(metadata['tags'] ?? []);
    } catch (_) {
      return [];
    }
  }

  String _extractAuthor(String metadataJson) {
    try {
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      return metadata['author'] ?? 'Anonymous';
    } catch (_) {
      return 'Anonymous';
    }
  }

  String? _extractThumbnailUrl(String metadataJson) {
    try {
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      final thumbnails = metadata['thumbnails'] as Map<String, dynamic>?;
      return thumbnails?['urlPath'] as String?;
    } catch (_) {
      return null;
    }
  }

  PagingController<int, ExploreCardData> _getControllerForType(ExploreCardType type) {
    switch (type) {
      case ExploreCardType.course:
        return _coursesController;
      case ExploreCardType.collection:
        return _collectionsController;
      case ExploreCardType.content:
        return _contentsController;
    }
  }

  /// Changes selected type
  void changeType(ExploreCardType type) {
    state = state.copyWith(selectedType: type);
  }

  /// Updates search query with debouncing
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);

    _searchDebouncer?.cancel();

    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _refreshCurrentPage();
    });
  }

  /// Refreshes current page
  void _refreshCurrentPage() {
    currentController.refresh();
  }

  /// Clears cache and refreshes
  void clearCacheAndRefresh() {
    _cache.clear();
    _refreshCurrentPage();
  }

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _coursesController.dispose();
    _collectionsController.dispose();
    _contentsController.dispose();
    super.dispose();
  }
}

// State class remains the same
class ExploreState {
  final ExploreCardType selectedType;
  final String searchQuery;
  final bool isLoading;

  ExploreState({required this.selectedType, required this.searchQuery, required this.isLoading});

  factory ExploreState.initial() {
    return ExploreState(selectedType: ExploreCardType.course, searchQuery: '', isLoading: false);
  }

  ExploreState copyWith({ExploreCardType? selectedType, String? searchQuery, bool? isLoading}) {
    return ExploreState(
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final exploreControllerProvider = StateNotifierProvider<ExploreController, ExploreState>((ref) {
  return ExploreController(FirebaseSyncRepository());
});
