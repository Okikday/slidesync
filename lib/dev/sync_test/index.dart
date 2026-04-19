/// Dev Sync Test Suite - Quick Access
///
/// This module provides a comprehensive testing UI for all sync operations,
/// Firestore queries, and file uploads.
///
/// ## Quick Start
///
/// Navigate to the test page:
/// ```dart
/// import 'package:slidesync/dev/sync_test/dev_routes.dart';
///
/// DevRoutes.navigateToSyncTest(context);
/// ```
///
/// Or use the named route in your MaterialApp:
/// ```dart
/// onGenerateRoute: (settings) {
///   return _getRoute(settings);
/// },
///
/// Route _getRoute(RouteSettings settings) {
///   return MaterialPageRoute(
///     builder: (context) => _buildRoute(settings.name ?? '/'),
///     settings: settings,
///   );
/// }
///
/// Widget _buildRoute(String route) {
///   if (route.startsWith(DevRoutes.syncTest)) {
///     return const SyncTestPage();
///   }
///   // ... other routes
/// }
/// ```
///
/// ## File Organization
///
/// - **providers/**
///   - `sync_test_state.dart`: Riverpod state & notifier (SyncTestState, SyncTestLog)
///   - `sync_test_coordinator.dart`: All test operations (SyncTestCoordinator)
///
/// - **ui/screens/**
///   - `sync_test_page.dart`: Main page with layout & stats bar
///
/// - **ui/widgets/**
///   - `sync_test_log_view.dart`: Scrollable log display with colors
///   - `sync_test_controls.dart`: Grouped test buttons (6 sections)
///   - `sync_test_input_dialog.dart`: ID input & sync parameter dialogs
///
/// - **dev_routes.dart**: Navigation helper
/// - **README.md**: Full documentation
///
/// ## Test Categories
///
/// 1. **API Configuration** (1 test)
///    - Verify all API paths
///
/// 2. **Courses** (2 tests)
///    - Get by ID, List all
///
/// 3. **Collections** (2 tests)
///    - Get by ID, List by course (flat query)
///
/// 4. **Contents** (2 tests)
///    - Get by ID, List by collection (flat query)
///
/// 5. **Vault** (1 test)
///    - List all vault links
///
/// 6. **Query Testing** (1 test)
///    - Verify flat collection queries work
///
/// 7. **Sync** (1 test)
///    - Full course sync with file uploads
///
/// **Total: 10 test operations**
///
/// ## Key Features
///
/// ✅ Real-time progress tracking (file uploads)
/// ✅ Colored log levels (Info/Success/Warning/Error)
/// ✅ Stats bar (log count, operation progress, status)
/// ✅ Batch operation support (collections, contents)
/// ✅ Input validation & error handling
/// ✅ Proper Riverpod grouped-provider architecture
/// ✅ No dialogs for state changes (logs update in real-time)
///
/// ## Riverpod Providers
///
/// - `syncTestStateProvider`: StateNotifierProvider<SyncTestNotifier, SyncTestState>
/// - `syncTestCoordinatorProvider`: Provider<SyncTestCoordinator>
///
/// ## Log System
///
/// Every operation logs to `SyncTestState.logs` with:
/// - Message text
/// - Timestamp (HH:mm:ss)
/// - Log level (Info/Success/Warning/Error)
/// - Automatic color coding in UI
///
/// ## State Tracking
///
/// ```dart
/// class SyncTestState {
///   final List<SyncTestLog> logs;           // All logs (newest last)
///   final bool isSyncing;                   // Currently running?
///   final double? uploadProgress;           // 0.0 - 1.0
///   final String? currentOperation;         // What's running
///   final int totalOperations;              // Planned count
///   final int completedOperations;          // Finished count
/// }
/// ```
///
/// ## Example: Adding a New Test
///
/// ```dart
/// // 1. Add method to SyncTestCoordinator
/// Future<void> testMyOperation() async {
///   try {
///     _log('Starting my operation...', SyncLogLevel.info);
///     _setSyncing(true, operation: 'My Op');
///
///     // Do work
///
///     _log('✓ Operation complete', SyncLogLevel.success);
///   } catch (e) {
///     _log('✗ Error: $e', SyncLogLevel.error);
///   } finally {
///     _setSyncing(false);
///   }
/// }
///
/// // 2. Add button to SyncTestControls.build()
/// _buildButton(
///   theme: theme,
///   label: 'Test My Operation',
///   icon: Icons.star,
///   onPressed: () => coordinator.testMyOperation(),
/// ),
/// ```
///
/// ## Performance
///
/// - Isar queries: ~1-10ms (local)
/// - Firebase queries: ~100-500ms (network)
/// - File uploads: Stream-based with 10% increments
/// - UI updates: Change detection via Riverpod watch
///
/// ## Troubleshooting
///
/// **No logs appearing?**
/// - Check if provider is initialized
/// - Verify coordinator is being watched
///
/// **Progress not updating?**
/// - Check if _setProgress() is being called
/// - Watch uploadProgress in StreamBuilder if needed
///
/// **Sync failing with "No vaults"?**
/// - Ensure user is admin (can access /admin collection)
/// - Vault links need to be fetched first via "List All Vaults"
///
export 'providers/sync_test_state.dart';
export 'providers/sync_test_coordinator.dart';
export 'ui/screens/sync_test_page.dart';
export 'dev_routes.dart';
