# Sync Test Suite

A comprehensive dev testing UI for all sync operations, Firestore API methods, and flat collection queries.

## Structure

```
lib/dev/sync_test/
├── providers/
│   ├── sync_test_state.dart          # State management (Riverpod)
│   └── sync_test_coordinator.dart    # All test operations
├── ui/
│   ├── screens/
│   │   └── sync_test_page.dart        # Main UI page
│   └── widgets/
│       ├── sync_test_controls.dart    # Test control buttons
│       ├── sync_test_log_view.dart    # Colored log display
│       └── sync_test_input_dialog.dart # Input dialogs
├── dev_routes.dart                    # Navigation routes
└── README.md                          # This file
```

## Features

### 1. **API Configuration Testing**
- Verify all API paths are correctly configured
- Test: `testApiPaths()`

### 2. **Course Operations**
- **Get Course by ID**: Fetch a single course
- **List All Courses**: Fetch all active courses from Isar
- Test methods: `testGetCourse()`, `testListCourses()`

### 3. **Collection Operations**
- **Get Collection by ID**: Fetch a single collection
- **List Collections by Course**: Uses flat query with `courseId` field
- Test methods: `testGetCollection()`, `testListCollections()`

### 4. **Content Operations**
- **Get Content by ID**: Fetch a single content item
- **List Contents by Collection**: Uses flat query with `collectionId` field
- Test methods: `testGetContent()`, `testListContents()`

### 5. **Vault Operations**
- **List All Vaults**: Fetch vault entities from Firestore
- Test method: `testListVaults()`

### 6. **Query Testing**
- **Test Flat Queries**: Verify flat collection queries work correctly
  - Tests that `courseId` field is stored in collections
  - Tests that `collectionId` field is stored in contents
- Test method: `testFlatCollectionQueries()`

### 7. **Sync Operations**
- **Sync Course**: Full sync operation
  - Fetches course with all collections and contents
  - Uploads files to Google Drive with resumable protocol
  - Tracks progress and logs results
- Test method: `testSyncCourse()`

## State Management

### SyncTestState
```dart
class SyncTestState {
  final List<SyncTestLog> logs;           // All test logs
  final bool isSyncing;                   // Is operation running
  final double? uploadProgress;           // File upload progress
  final String? currentOperation;         // Current operation name
  final int totalOperations;              // Total operations planned
  final int completedOperations;          // Completed operations count
}
```

### Log Levels
- **Info** 🔵: General information
- **Success** 🟢: Operation succeeded
- **Warning** 🟠: Non-fatal issues
- **Error** 🔴: Operation failed

## Usage

### From Code
```dart
// Navigate to sync test page
DevRoutes.navigateToSyncTest(context);

// Or use named route
Navigator.pushNamed(context, DevRoutes.syncTest);
```

### From UI
1. Click any test button to execute
2. For ID-based tests: Enter the ID in the dialog
3. For sync: Enter course ID and comma-separated vault links
4. Watch logs in real-time
5. Clear logs with the "Clear" button

## Key Implementation Details

### Flat Collection Queries
All queries use flat collection structure with `.where()` filtering:

```dart
// Get collections for a course (flat query)
final collections = await isar
    .collection<CourseCollection>()
    .where()
    .parentIdEqualTo(courseId)  // courseId field
    .findAll();

// Get contents for a collection (flat query)
final contents = await isar
    .collection<CourseContent>()
    .where()
    .parentIdEqualTo(collectionId)  // collectionId field
    .findAll();
```

### Upload Progress Tracking
```dart
// Stream-based progress from Google Drive API
await for (final progress in _driveManager.public.upload(...)) {
  if (progress.isDone) {
    // Upload complete, file ID available
    final driveFileId = progress.driveFileId;
  } else if (progress.isFailed) {
    // Handle failure
  } else {
    // Track progress
    emit((progress.bytesTransferred / progress.totalBytes) * 100);
  }
}
```

### Riverpod Pattern
Uses grouped provider architecture:
- `syncTestStateProvider`: Main state (StateNotifier)
- `syncTestCoordinatorProvider`: All operations (Provider)
- State notifier methods for logging, progress, and completion

## Testing Workflow

1. **Verify API Paths** → Run "Test API Paths" to ensure configuration is correct
2. **Test Collections** → Can you fetch courses and collections?
3. **Test Contents** → Can you fetch content items?
4. **Test Queries** → Are flat queries working with parentId fields?
5. **Test Sync** → Full sync with file uploads to Google Drive

## Error Handling

All operations have try-catch blocks that:
- Log errors to the test UI in real-time
- Continue execution for batch operations
- Report which items failed (failed IDs list)

## Performance Notes

- **Isar Queries**: Instant (local database)
- **Firebase Queries**: Network-dependent
- **File Uploads**: Progress tracked via stream
- **Batch Operations**: Can process multiple items

## Integration with SyncCoordinator

This test UI directly calls `SyncCoordinator` methods:

```dart
final coordinator = SyncCoordinator();
final result = await coordinator.syncCourse(
  course: course,
  userId: 'dev-user',
  vaultLinks: vaultLinks,
  onProgress: (bytesTransferred, totalBytes) {
    // Update UI with progress
  },
);
```

Returns `SyncResult` with:
- `uploadedCount`: Files successfully uploaded
- `skippedCount`: Files skipped (not local/link)
- `failedCount`: Files that failed
- `failedContentIds`: IDs of failed items
- `error`: Error message if applicable

## Future Enhancements

- [x] Real-time progress tracking
- [x] Colored log levels
- [x] Batch operation handling
- [x] Input validation dialogs
- [ ] Export logs to file
- [ ] Performance metrics (timing)
- [ ] Retry failed operations
- [ ] Network simulation (throttle/offline)
