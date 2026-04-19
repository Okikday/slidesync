# SideSync Core API Architecture & Firebase Rules

## Firebase Security Rules Compliance

All APIs in `core/apis` now follow the Firebase security rules provided:

### Database Collections Structure

```
/admins/{adminId}
/users/{userId}
/institutions/{institutionId}
/catalog/{catalogId}
/courses/{courseId}
  ├── collections/{collectionId}
  │   └── contents/{contentHash}
/privateX/{uid}/courses/{courseId}
  ├── collections/{collectionId}
  │   └── contents/{contentHash}
/courseVotes/{courseId}/votes/{userId}
/courseFlags/{courseId}/flags/{userId}
/content-lookup/{contentHash}
  ├── sources/{userId}
  │   ├── votes/{voterId}
  │   └── flags/{flaggerId}
  └── privateSources/{userId}
/storageVault/{linkId}
  └── uploads/{uploadId}
```

### Implemented Rules

#### Authentication
- **isAuth()**: All operations verify `request.auth != null`
- **isOwner(uid)**: Operations check `request.auth.uid == uid`
- **isAdmin()**: Admin-only ops verify presence in `/admins/{uid}`

#### CRUD Operations

##### Users
- `create`: Only own document, must not exist
- `read/update`: Owner or admin
- `delete`: Owner only

##### Courses (Public)
- `create`: Auth required, must have all required fields, creator must have < 10 courses (or be admin)
- `read`: All authenticated users
- `update`: Creator only (if not verified) or admin
- `delete`: Creator or admin

##### Collections & Contents
- `create`: Auth required, creator matches auth.uid
- `read`: All authenticated users
- `update`: Creator only (if parent course not verified) or admin
- `delete`: Creator or admin
- **Immutability**: Contents cannot be updated after creation

##### Votes & Flags
- `vote/flag`: Only own vote/flag (userId as doc ID)
- `read votes`: Public readable
- `read flags`: Admin only
- Auto-increment counters via Cloud Functions

##### Content Lookup Registry
- **Immutable**: No updates/deletes after creation
- Hash registration is atomic and idempotent

#### Safe Multi-Write Operations

All batch operations use `FirebaseFirestore.instance.batch()`:
1. **Atomic**: All writes succeed or all fail
2. **No race conditions**: All counter increments use `FieldValue.increment()`
3. **Idempotent**: Safe to retry without duplicating

Example: `vault.logUploadWithSource()` atomically writes:
- Vault upload log entry
- Content hash registration (immutable)
- Source entry

---

## New Architecture: Upload & Download Managers

### Overview

Modular managers handle reliable file operations with resumable capability across app kills.

### File Structure

```
core/apis/abstract/
├── firestore_api_base.dart        # Abstract base classes (CRUD patterns)
├── upload_download_base.dart      # Abstract manager interfaces
├── http_upload_manager.dart       # Built-in HTTP upload implementation
├── http_download_manager.dart     # Built-in HTTP download implementation
└── sync_coordinator.dart          # Orchestrates upload-sync workflow
```

### Base Classes

#### FirestoreApiBase
Abstract interface enforcing CRUD consistency:
- `get()`, `stream()`, `list()`: Retrieve data
- `create()`, `update()`, `delete()`: Modify data
- All return `Result<T>` for type-safe error handling

#### NestedFirestoreApiBase
For hierarchical collections (courses → collections → contents)

#### VotableApiBase & FlaggableApiBase
Enforce voting/flagging patterns per Firebase rules

#### ContentLookupApiBase
Immutable registry operations

### Upload Manager

```dart
// Upload with automatic retry (3 random links)
final result = await HttpUploadManager().uploadFile(
  file: File('path/to/file'),
  vaultLinks: ['link1', 'link2', 'link3'],
  operationId: 'unique-id', // For resume support
  onProgress: (bytes, total) { /* Update UI */ },
  maxAttempts: 3,
);

// Resume interrupted upload
final resumed = await HttpUploadManager().resumeUpload(
  operationId: 'unique-id',
  onProgress: (bytes, total) { /* Update UI */ },
);
```

**Features:**
- 200MB file size limit
- Multi-link retry (random selection)
- Session persistence via Hive (survives app kills)
- Progress tracking with `OnUploadProgress` callback
- Atomic logging to Firebase vault

### Download Manager

```dart
// Download with HTTP Range headers (resumable)
final result = await HttpDownloadManager().downloadFile(
  remoteUrl: 'https://...',
  destPath: '/local/path',
  operationId: 'unique-id',
  onProgress: (bytes, total) { /* Update UI */ },
  knownSize: 5000000, // Optional size hint
);

// Resume by operation ID
final resumed = await HttpDownloadManager().resumeDownload(
  operationId: 'unique-id',
  onProgress: (bytes, total) { /* Update UI */ },
);
```

**Features:**
- HTTP Range header support (true resume)
- Session persistence (survives app kills)
- 512KB read buffer (efficient memory)
- Progress tracking
- Automatic retry on partial downloads

### Sync Coordinator

Orchestrates upload workflow with Firebase rules compliance:

```dart
final result = await SyncCoordinator().syncCourse(
  course: course,
  userId: auth.uid,
  vaultLinks: vaultLinksList,
  onProgress: (bytes, total) { /* Update UI */ },
);

// Result contains:
// - totalContents: Count of all contents
// - uploadedCount: Successfully uploaded
// - skippedCount: Skipped (non-file, already exists)
// - failedCount: Failed uploads (user should retry)
// - failedContentIds: List of IDs to retry
```

**Upload Logic:**
1. Validate course not empty (skip if 0 collections)
2. For each collection:
   - Validate not empty (skip if 0 contents)
   - For each content:
     - Check ContentOrigin (skip if not `local`)
     - Check if already in Firebase (skip if exists)
     - Validate file exists
     - Upload with 3-attempt retry
     - **Log to vault only on success** (atomically with source entry)
3. Return summary with failed content IDs
4. User can call again to sync failed items (idempotent)

**Key Behavior:**
- Empty courses/collections are not created in Firebase
- Failed uploads are not written to Firebase (no orphaned entries)
- Resumable by operation ID (same upload called twice = resume)
- `ContentMetadata.contentOrigin` checked before upload:
  - `ContentOrigin.local` → Upload required
  - `ContentOrigin.server` → Skip (already remote)
  - `ContentOrigin.none` → Skip

---

## Logging System

All operations use centralized `SyncLogger` for debugging:

```dart
SyncLogger.info('Message', operation: operationId);
SyncLogger.warn('Warning', operation: operationId);
SyncLogger.error('Error', error, operation: operationId);
SyncLogger.uploadProgress(opId, bytes, total, attempt);
SyncLogger.downloadProgress(opId, bytes, total);
```

Logs include:
- Operation ID (for tracking)
- Progress percentage
- Attempt numbers (for retries)
- Error stack traces

---

## Best Practices

### Content Origin Handling

```dart
class ContentMetadata {
  /// Determines upload behavior
  final ContentOrigin contentOrigin;
}

enum ContentOrigin {
  none,     // Unknown/unset → Skip upload
  local,    // File on device → Must upload to storage vault
  server,   // Remote file (Drive/link) → No upload needed
}
```

Set correctly when adding content:
```dart
// File selected locally
final metadata = ContentMetadata(
  contentOrigin: ContentOrigin.local,
);

// Link pasted from browser
final metadata = ContentMetadata(
  contentOrigin: ContentOrigin.server,
);
```

### Progress Callbacks

All manager operations accept `onProgress` for real-time UX:

```dart
uploadFile(
  // ...
  onProgress: (bytes, total) {
    final percent = (bytes / total * 100).toStringAsFixed(1);
    print('$percent% uploaded');
  },
)
```

### Idempotent Operations

All operations are safe to retry:

```dart
// Call 1: Uploads successfully
await syncCourse(...);

// Call 2 with same operationId: Resumes (or completes immediately)
await syncCourse(...);

// Result: No double-upload, idempotent behavior
```

### Error Handling

```dart
final result = await uploadFile(...);

if (!result.success) {
  final failed = result.failedContentIds;
  // Retry individual items or the whole batch
  print('Failed: $failed');
}
```

---

## Firebase Cloud Functions Integration

The Cloud Functions (Node.js) handle:

1. **Counter increments** (avoid race conditions):
   - Course publication count
   - Vote counts (votes per entity)
   - Flag counts with auto-flagging threshold

2. **Typesense sync** (search index):
   - Indexes new/updated courses
   - Removes deleted courses

All use `FieldValue.increment()` for atomicity (no read-then-write).

---

## Testing Upload/Download

```dart
// Test upload with mock link
await HttpUploadManager().uploadFile(
  file: File('test.pdf'),
  vaultLinks: ['https://example.com/upload'],
  operationId: 'test-1',
  onProgress: print,
);

// Test resume (kills app, then resumes)
// Manager persists session to Hive, survives app kill

// Check session info
final info = await manager.getSessionInfo('test-1');
print('Session: $info');
```

---

## Import Summary

All new managers are accessible from `core/apis`:

```dart
// Managers
import 'package:slidesync/core/apis/abstract/http_upload_manager.dart';
import 'package:slidesync/core/apis/abstract/http_download_manager.dart';

// Coordinator
import 'package:slidesync/core/apis/abstract/sync_coordinator.dart';

// Logging
import 'package:slidesync/core/apis/abstract/upload_download_base.dart'; // SyncLogger

// Abstracts
import 'package:slidesync/core/apis/abstract/firestore_api_base.dart';
```
