import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/features/course_navigation/presentation/actions/content_card_actions.dart';

final AutoDisposeFutureProviderFamily<FileDetails, CourseContent> linkPreviewDataProviderFamily =
    AutoDisposeFutureProviderFamily((ref, content) async {
      return await ContentCardActions.resolvePreviewPath(content);
    });

class ContentCardProviders {
  static AutoDisposeFutureProvider<FileDetails> fetchLinkPreviewDataProvider(CourseContent content) =>
      linkPreviewDataProviderFamily(content);
}
