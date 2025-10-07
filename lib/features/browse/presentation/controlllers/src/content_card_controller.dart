import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/presentation/actions/content_card_actions.dart';

final linkPreviewDataProviderFamily = FutureProvider.family((ref, CourseContent content) async {
  return await ContentCardActions.resolvePreviewPath(content);
}, isAutoDispose: true);

class ContentCardController {
  static FutureProvider<FileDetails> fetchLinkPreviewDataProvider(CourseContent content) =>
      linkPreviewDataProviderFamily(content);
}
