import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/browse/presentation/logic/course_materials_provider.dart';
import 'package:slidesync/features/manage/presentation/contents/logic/src/modify_contents_state.dart';

class ModifyContentsProvider {
  ///|
  ///|
  /// ===================================================================================================
  /// STATE
  /// ===================================================================================================
  static final state = Provider.autoDispose<ModifyContentsState>((ref) {
    final mcs = ModifyContentsState();
    ref.onDispose(mcs.dispose);
    return mcs;
  });

  static FutureProvider<FileDetails> linkPreviewDataProvider(CourseContent content) =>
      CourseMaterialsProvider.linkPreviewDataProvider(content);
}
