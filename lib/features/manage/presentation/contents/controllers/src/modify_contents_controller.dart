import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/manage/presentation/contents/controllers/state/modify_contents_state.dart';

final _rawModifyContentsStateProvider = Provider.autoDispose<ModifyContentsState>((ref) {
  final mcs = ModifyContentsState();
  ref.onDispose(mcs.dispose);
  return mcs;
});

class ModifyContentsController {
  static Provider<ModifyContentsState> get modifyContentsStateProvider => _rawModifyContentsStateProvider;
}
