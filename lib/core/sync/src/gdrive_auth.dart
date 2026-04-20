part of '../gdrive_manager.dart';

/// Manages Google Sign-In and authenticated HTTP client access.
///
/// Private ops use [driveFileScope] — only files the app created.
/// Public/admin ops use [driveScope]  — full drive access (admin-gated by Firestore rules).
class GDriveAuth {
  GDriveAuth._() {
    Future.microtask(() => _initializeGoogleAuth());
  }

  final GoogleSignIn _googleAuth = GoogleSignIn.instance;
  bool isInitialized = false;
  static const _defaultScopes = ['email', 'profile', 'openid'];
  static const _privateSignInScopes = [..._defaultScopes, drive.DriveApi.driveFileScope];

  static const _adminSignInScopes = [..._defaultScopes, drive.DriveApi.driveScope];

  // ── Public read-only API key (browsing public folders, metadata) ───────────
  // Set this once at app startup via GDriveAuth.setApiKey(dotenv.env['DRIVE_API_KEY']!)
  static String _apiKey = '';

  static void setApiKey(String key) => _apiKey = key;
  static String get apiKey => _apiKey;

  Future<void> _initializeGoogleAuth() async {
    if (isInitialized) return;
    await _googleAuth.initialize(serverClientId: dotenv.env['SERVER_CLIENT_ID']);
    isInitialized = true;
  }

  // ── Private sign-in (personal backup, driveFile scope) ────────────────────

  Future<GoogleSignInAccount?> signInPrivate() async {
    try {
      await _initializeGoogleAuth();
      final account = await _googleAuth.authenticate(scopeHint: _privateSignInScopes);
      log('GDriveAuth: signed in as ${account.email}');
      return account;
    } catch (e, st) {
      log('GDriveAuth: private sign-in failed', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleAuth.signOut();
    log('GDriveAuth: signed out');
  }

  Future<void> disconnect() async {
    await _googleAuth.disconnect();
    log('GDriveAuth: disconnected');
  }

  // ── Admin sign-in (public vault uploads, full drive scope) ─────────────────

  Future<GoogleSignInAccount?> signInAdmin() async {
    try {
      await _initializeGoogleAuth();
      final account = await _googleAuth.authenticate(scopeHint: _adminSignInScopes);
      log('GDriveAuth: admin signed in as ${account.email}');
      return account;
    } catch (e, st) {
      log('GDriveAuth: admin sign-in failed', error: e, stackTrace: st);
      return null;
    }
  }

  // ── Authenticated HTTP clients ─────────────────────────────────────────────

  /// Returns an authenticated HTTP client scoped for private file ops.
  /// Returns null if the user is not signed in.
  Future<AuthClient?> privateClient() async {
    _initializeGoogleAuth();
    final account = await _googleAuth.attemptLightweightAuthentication() ?? await signInPrivate();
    if (account == null) return null;
    final authorization = await account.authorizationClient.authorizeScopes(_privateSignInScopes);
    return authorization.authClient(scopes: _privateSignInScopes);
  }

  /// Returns an authenticated HTTP client scoped for admin/full drive ops.
  Future<AuthClient?> adminClient() async {
    _initializeGoogleAuth();
    final account = await _googleAuth.attemptLightweightAuthentication() ?? await signInAdmin();
    if (account == null) return null;
    final authorization = await account.authorizationClient.authorizeScopes(_adminSignInScopes);
    return authorization.authClient(scopes: _adminSignInScopes);
  }

  /// Unauthenticated client — used with API key for public browsing only.
  http.Client publicClient() => http.Client();

  // ── Convenience: get a DriveApi instance ──────────────────────────────────

  Future<drive.DriveApi?> privateDriveApi() async {
    final client = await privateClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  Future<drive.DriveApi?> adminDriveApi() async {
    final client = await adminClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }
}
