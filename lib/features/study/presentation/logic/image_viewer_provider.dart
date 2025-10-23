import 'package:slidesync/features/study/presentation/logic/src/image_viewer_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class ImageViewerProvider {
  static final state = Provider.family.autoDispose<ImageViewerState, String>((ref, contentId){
    final ivs = ImageViewerState(ref, contentId);
    ref.onDispose(ivs.dispose);
    return ivs;
  });
}