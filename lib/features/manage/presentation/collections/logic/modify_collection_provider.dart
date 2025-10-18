import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/manage/presentation/collections/logic/src/modify_collections_state.dart';

class ModifyCollectionProvider {
  ///|
  ///|
  /// ===================================================================================================
  /// STATE
  /// ===================================================================================================
  static final state = Provider.autoDispose<ModifyCollectionsState>((ref) {
    final mcs = ModifyCollectionsState();
    ref.onDispose(mcs.dispose);
    return mcs;
  });

  ///|
  ///|
  /// ===================================================================================================
  ///
  /// ===================================================================================================
}
