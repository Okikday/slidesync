import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/sync/entities/drive_file_entity.dart';
import 'package:slidesync/data/models/course_content/content_metadata.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';

extension DriveFileEntityCourseContentMapper on DriveFileEntity {
  bool get isUnsupportedForCourseContent => isFolder || mimeType == 'application/vnd.google-apps.shortcut';

  String get driveUrl => webViewLink ?? 'https://drive.google.com/file/d/$id/view';

  String get contentHashKey => md5Checksum ?? id;

  int get sizeInBytes => int.tryParse(size ?? '') ?? 0;

  CourseContentType inferCourseContentType() {
    final mt = mimeType.toLowerCase();

    if (mt.contains('image')) return CourseContentType.image;
    if (mt.contains('pdf') || mt.contains('document') || mt.contains('word') || mt.contains('text')) {
      return CourseContentType.document;
    }
    if (mt.contains('presentation') || mt.contains('powerpoint') || mt.contains('slides')) {
      return CourseContentType.document;
    }
    if (mt.contains('spreadsheet') || mt.contains('excel') || mt.contains('sheet')) {
      return CourseContentType.document;
    }
    return CourseContentType.link;
  }

  String resolvedTitle({bool useDisplayName = true}) {
    if (!useDisplayName) return name;
    return displayName;
  }

  FileDetails toFileDetails() => FileDetails(urlPath: driveUrl);

  ContentMetadata toContentMetadata({
    ContentOrigin contentOrigin = ContentOrigin.server,
    String? originalFileName,
    String? author,
    Map<String, dynamic>? extraFields,
  }) {
    final fields = <String, dynamic>{
      'driveId': id,
      'mimeType': mimeType,
      if (size != null) 'size': size,
      if (webViewLink != null) 'webViewLink': webViewLink,
      if (webContentLink != null) 'webContentLink': webContentLink,
      if (modifiedTime != null) 'modifiedTime': modifiedTime,
      if (createdTime != null) 'createdTime': createdTime,
      'isGoogleNative': isGoogleNative,
      if (md5Checksum != null) 'md5Checksum': md5Checksum,
      if (iconLink != null) 'iconLink': iconLink,
      if (thumbnailLink != null) 'thumbnailLink': thumbnailLink,
      if (ownerDisplayName != null) 'ownerDisplayName': ownerDisplayName,
      if (ownerEmail != null) 'ownerEmail': ownerEmail,
      if (lastModifyingUserDisplayName != null) 'lastModifyingUserDisplayName': lastModifyingUserDisplayName,
      if (lastModifyingUserEmail != null) 'lastModifyingUserEmail': lastModifyingUserEmail,
      if (version != null) 'version': version,
      if (hasAugmentedPermissions != null) 'hasAugmentedPermissions': hasAugmentedPermissions,
      if (isAppAuthorized != null) 'isAppAuthorized': isAppAuthorized,
      'previewUrl': thumbnailLink ?? webViewLink ?? '',
      'resolved': true,
      if (extraFields != null) ...extraFields,
    };

    return ContentMetadata(
      originalFileName: originalFileName ?? originalFilename ?? name,
      thumbnails: thumbnailLink != null ? FileDetails(urlPath: thumbnailLink!) : null,
      contentOrigin: contentOrigin,
      author: author ?? ownerDisplayName ?? ownerEmail,
      fields: fields.isEmpty ? null : fields,
    );
  }

  CourseContent? toCourseContent({
    required String parentId,
    String? contentId,
    String? title,
    CourseContentType? courseContentType,
    ContentOrigin contentOrigin = ContentOrigin.server,
    bool useDisplayName = true,
    String? descriptionOverride,
    Map<String, dynamic>? extraFields,
  }) {
    if (isUnsupportedForCourseContent) return null;

    final resolvedTitle = title ?? this.resolvedTitle(useDisplayName: useDisplayName);
    final resolvedType = courseContentType ?? inferCourseContentType();

    return CourseContent.create(
      contentHash: contentHashKey,
      contentId: contentId ?? id,
      parentId: parentId,
      title: resolvedTitle,
      path: toFileDetails(),
      createdAt: createdAt != null ? DateTime.tryParse(createdTime ?? '') : null,
      lastModified: modifiedTime != null ? DateTime.tryParse(modifiedTime ?? '') : null,
      courseContentType: resolvedType,
      fileSize: sizeInBytes,
      description: descriptionOverride ?? description ?? '',
      metadata: toContentMetadata(
        contentOrigin: contentOrigin,
        originalFileName: originalFilename ?? name,
        author: ownerDisplayName ?? ownerEmail,
        extraFields: extraFields,
      ),
    );
  }
}

extension DriveFileEntityCollectionMapper on Iterable<DriveFileEntity> {
  List<CourseContent> toCourseContents({
    required String parentId,
    String? contentIdPrefix,
    CourseContentType? courseContentType,
    ContentOrigin contentOrigin = ContentOrigin.server,
    bool useDisplayName = true,
    Map<String, dynamic>? extraFields,
  }) {
    return map(
      (file) => file.toCourseContent(
        parentId: parentId,
        contentId: contentIdPrefix == null ? null : '${contentIdPrefix}_${file.id}',
        courseContentType: courseContentType,
        contentOrigin: contentOrigin,
        useDisplayName: useDisplayName,
        extraFields: extraFields,
      ),
    ).whereType<CourseContent>().toList();
  }
}

extension DrivePageCourseContentMapper on DrivePage {
  List<CourseContent> toCourseContents({
    required String parentId,
    String? contentIdPrefix,
    CourseContentType? courseContentType,
    ContentOrigin contentOrigin = ContentOrigin.server,
    bool useDisplayName = true,
    Map<String, dynamic>? extraFields,
  }) {
    return files.toCourseContents(
      parentId: parentId,
      contentIdPrefix: contentIdPrefix,
      courseContentType: courseContentType,
      contentOrigin: contentOrigin,
      useDisplayName: useDisplayName,
      extraFields: extraFields,
    );
  }
}
