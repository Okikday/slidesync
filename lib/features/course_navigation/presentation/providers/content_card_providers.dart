import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/features/course_navigation/presentation/actions/content_card_actions.dart';

final linkPreviewDataProviderFamily = FutureProvider.family((ref, CourseContent content) async {
  return await ContentCardActions.resolvePreviewPath(content);
}, isAutoDispose: true);

class ContentCardProviders {
  static FutureProvider<FileDetails> fetchLinkPreviewDataProvider(CourseContent content) =>
      linkPreviewDataProviderFamily(content);
}
