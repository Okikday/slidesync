/// Folder structure on Drive:
///
/// Private (personal backup):
///   MaterialsRepo/
///     private/
///       {uid}/
///         {courseId}/
///           {collectionId}/
///             file.pdf
///
/// Public (admin vault):
///   MaterialsRepo/
///     public/
///       {institutionId}/
///         {courseId}/
///           file.pdf
class GDrivePaths {
  GDrivePaths._();

  static const _appRoot = 'MaterialsRepo';
  static const _privateRoot = 'private';
  static const _publicRoot = 'public';

  // ── Folder name conventions ────────────────────────────────────────────────

  static String privateUserFolder(String uid) => uid;
  static String privateCourseFolder(String courseId) => courseId;
  static String privateCollectionFolder(String collectionId) => collectionId;
  static String publicInstitutionFolder(String institutionId) => institutionId;
  static String publicCourseFolder(String courseId) => courseId;

  // ── Segment lists for path resolution ─────────────────────────────────────
  // GDriveManager uses these to create/resolve folder trees.

  /// Path segments from root to a private collection folder.
  static List<String> privateSegments({required String uid, required String courseId, required String collectionId}) =>
      [_appRoot, _privateRoot, uid, courseId, collectionId];

  /// Path segments from root to a public course folder.
  static List<String> publicSegments({required String institutionId, required String courseId}) => [
    _appRoot,
    _publicRoot,
    institutionId,
    courseId,
  ];

  // ── Link helpers ───────────────────────────────────────────────────────────

  /// Extracts a Drive file/folder ID from any supported Google Drive URL format.
  /// Returns null if no ID could be extracted.
  static String? extractId(String url) {
    if (url.isEmpty) return null;
    final patterns = [
      RegExp(r'/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'folders/([a-zA-Z0-9_-]+)'),
      RegExp(r'[?&]id=([a-zA-Z0-9_-]+)'),
      RegExp(r'/file/d/([a-zA-Z0-9_-]+)'),
    ];
    for (final r in patterns) {
      final m = r.firstMatch(url);
      if (m != null) return m.group(1);
    }
    return null;
  }

  /// Returns true if the URL is a Google Drive link (offline check).
  static bool isDriveLink(String url) {
    if (url.isEmpty) return false;
    String normalized = url.toLowerCase().trim();
    if (!normalized.startsWith('http')) normalized = 'https://$normalized';

    try {
      final uri = Uri.parse(normalized);
      final host = uri.host;
      final validHosts = ['drive.google.com', 'docs.google.com', 'sheets.google.com', 'slides.google.com'];
      if (!validHosts.any((h) => host == h || host.endsWith('.$h'))) {
        return false;
      }
      final drivePatterns = [
        RegExp(r'/(?:file/)?d/[a-zA-Z0-9_-]+'),
        RegExp(r'/(?:drive/)?folders/[a-zA-Z0-9_-]+'),
        RegExp(r'/(?:document|spreadsheets|presentation)/d/[a-zA-Z0-9_-]+'),
        RegExp(r'[?&]id=[a-zA-Z0-9_-]+'),
      ];
      return drivePatterns.any((p) => p.hasMatch('${uri.path}?${uri.query}'));
    } catch (_) {
      return false;
    }
  }

  /// Constructs a webViewLink from a file ID.
  static String fileViewLink(String fileId) => 'https://drive.google.com/file/d/$fileId/view';

  /// Constructs a folder link from a folder ID.
  static String folderLink(String folderId) => 'https://drive.google.com/drive/folders/$folderId';
}
