import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/manage/presentation/collections/controllers/state/modify_collections_state.dart';

final _modifyCollectionStateProvider = Provider<ModifyCollectionsState>((ref) {
  final mcs = ModifyCollectionsState();
  ref.onDispose(mcs.dispose);
  return mcs;
}, isAutoDispose: true);

class ModifyCollectionsController {
  static Provider<ModifyCollectionsState> get modifyCollectionStateProvider => _modifyCollectionStateProvider;
}
