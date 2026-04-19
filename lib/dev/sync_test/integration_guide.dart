/// Integration Guide: How to Add Sync Test Suite to Your App
///
/// This guide shows how to integrate the dev sync test suite into your existing app.
///
/// ## Step 1: Update Your Router
///
/// If you're using named routes, add the dev routes to your router:
///
/// ```dart
/// // In your main app router or route handler
/// import 'package:slidesync/dev/sync_test/dev_routes.dart';
///
/// // In MaterialApp or GoRouter configuration:
/// routes: {
///   ...DevRoutes.routes,
///   // ... other routes
/// }
/// ```
///
/// ## Step 2: Create a Dev Menu (Optional)
///
/// Add a quick access button in your debug/dev environments:
///
/// ```dart
/// // In your settings page or debug drawer
/// import 'package:slidesync/dev/sync_test/dev_routes.dart';
///
/// ListTile(
///   title: const Text('🧪 Sync Test Suite'),
///   onTap: () => DevRoutes.navigateToSyncTest(context),
/// ),
/// ```
///
/// ## Step 3: Nothing Else!
///
/// The test suite is completely self-contained and doesn't require any additional setup.
/// It uses your existing:
/// - API instance (Api.instance)
/// - Firestore setup
/// - Isar database
/// - GDrive manager
///
/// ## Usage
///
/// Navigate to the test page and start testing:
///
/// ```dart
/// // Option 1: Using named route
/// Navigator.pushNamed(context, DevRoutes.syncTest);
///
/// // Option 2: Direct navigation
/// DevRoutes.navigateToSyncTest(context);
///
/// // Option 3: Direct widget
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const SyncTestPage()),
/// );
/// ```
///
/// ## Test Categories at a Glance
///
/// ### API Configuration
/// - Test API Paths → Verify all Firebase paths are set correctly
///
/// ### Courses
/// - Get Course by ID → Fetch single course from Firebase
/// - List All Courses → Fetch all courses from local Isar
///
/// ### Collections
/// - Get Collection by ID → Fetch single collection
/// - List Collections by Course → Uses flat query with courseId field
///
/// ### Contents
/// - Get Content by ID → Fetch single content item
/// - List Contents by Collection → Uses flat query with collectionId field
///
/// ### Vault
/// - List All Vaults → Fetch vault links from Firebase
///
/// ### Query Testing
/// - Test Flat Queries → Verify flat collection structure is working
///
/// ### Sync Operations
/// - Sync Course → Full sync with file uploads to Google Drive
///
/// ## Output Format
///
/// All logs are displayed with:
/// - **Timestamp:** HH:mm:ss format
/// - **Level:** Color-coded (Blue/Green/Orange/Red)
/// - **Message:** Human-readable text
/// - **Progress:** Real-time upload progress bar
/// - **Stats:** Total logs, operation count, current status
///
/// ## Example Test Flow
///
/// 1. Start with "Test API Paths" → Verify configuration
/// 2. Run "List All Courses" → Ensure data is loaded
/// 3. Pick a courseId from logs
/// 4. Run "List Collections by Course" with that courseId
/// 5. Pick a collectionId from logs
/// 6. Run "List Contents by Collection" with that collectionId
/// 7. Run "Test Flat Queries" to verify queries work
/// 8. Run "Sync Course" with that courseId to test full sync
///
/// ## Logs are Persistent During Session
///
/// All logs remain visible until you:
/// - Click "Clear" button in the top right
/// - Navigate away and back
/// - Clear app data
///
/// ## Real-Time Progress
///
/// During file uploads:
/// - Circular progress indicator appears
/// - Progress percentage shown
/// - Download speed visible in logs
/// - Automatic completion notification
///
/// ## Error Handling
///
/// All errors are logged with:
/// - Full exception message
/// - Stack trace in console (if needed)
/// - Automatic recovery (doesn't crash app)
/// - Logged as SyncLogLevel.error (red color)
///
/// ## Performance Expectations
///
/// | Operation | Time | Notes |
/// |-----------|------|-------|
/// | Get Course | 100-200ms | Firebase query |
/// | List Courses | 50-100ms | Local Isar query |
/// | List Collections | 20-50ms | Isar with filter |
/// | List Contents | 20-50ms | Isar with filter |
/// | List Vaults | 100-300ms | Firebase query |
/// | Sync Course | Varies | Depends on file sizes |
/// | Test Queries | 10-30ms | Local Isar queries |
///
/// ## Troubleshooting
///
/// **Issue:** "No logs appearing"
/// - Check: Is the page rendering?
/// - Check: Did you click a button?
/// - Fix: Rebuild and try again
///
/// **Issue:** "Sync failed with permission error"
/// - Check: Are you logged in as admin?
/// - Check: Is the vaultLinks list populated?
/// - Fix: Run "List All Vaults" first
///
/// **Issue:** "Flat queries returning empty"
/// - Check: Did you load data first with "List All Courses"?
/// - Check: Does the course have collections?
/// - Fix: Ensure courseId field exists in collections
///
/// **Issue:** "Progress bar not updating"
/// - Check: Is file size > 5MB?
/// - Check: Is network connection stable?
/// - Fix: Try with a smaller file first
///
/// ## Next Steps
///
/// 1. Navigate to sync test page
/// 2. Run "Test API Paths" → Should pass
/// 3. Run "List All Courses" → Should show your courses
/// 4. Pick a course and test queries
/// 5. Try a full sync if you have test data
///
/// ## File Structure
///
/// ```
/// lib/dev/sync_test/
/// ├── providers/
/// │   ├── sync_test_state.dart       # State management
/// │   └── sync_test_coordinator.dart # Test operations
/// ├── ui/
/// │   ├── screens/
/// │   │   └── sync_test_page.dart    # Main UI
/// │   └── widgets/
/// │       ├── sync_test_controls.dart         # Buttons
/// │       ├── sync_test_log_view.dart         # Logs display
/// │       └── sync_test_input_dialog.dart     # Input dialogs
/// ├── dev_routes.dart                # Navigation
/// ├── index.dart                      # Quick reference
/// ├── integration_guide.dart          # This file
/// └── README.md                       # Full docs
/// ```
///
/// ## Support
///
/// If something isn't working:
/// 1. Check the logs (bottom of the screen)
/// 2. Look for error messages (red color)
/// 3. Try running "Test API Paths" first
/// 4. Ensure you have internet connection for Firebase queries
/// 5. Check that you're logged in with admin privileges
