import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_state.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_pagination_notifier/module_contents_pagination_notifier.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

part 'ext_module_contents_notifier.dart';

final _moduleContentsPaginationNotifier = NotifierProvider.family.autoDispose(
  (Module module) => ModuleContentsPaginationNotifier(module),
);

final _cardViewTypeNotifier = AsyncNotifierProvider.autoDispose(
  () => CardViewTypeNotifier(HiveDataPathKey.moduleContentsCardViewType.name, CardViewType.grid),
);

class ModuleContentsNotifier extends Notifier<ModuleContentsState> {
  ///
  ///
  /// ===================================================================================================
  /// DECLARATIONS
  /// ===================================================================================================
  final Module module;
  final NotifierProvider<ModuleContentsPaginationNotifier, ModuleContentsPaginationState> contentsPagination;

  final selectedContents = LinkedHashSet<ModuleContent>(equals: (a, b) => a.uid == b.uid);

  ModuleContentsNotifier(this.module) : contentsPagination = _moduleContentsPaginationNotifier(module);

  ///
  ///
  /// ===================================================================================================
  /// LIFECYCLE
  /// ===================================================================================================
  @override
  ModuleContentsState build() {
    ref.listen(_cardViewTypeNotifier, (p, n) => n.whenData((cb) => state.copyWith(cardViewType: cb)));
    ref.emptyListenMany([contentsPagination]);
    return ModuleContentsState();
  }

  void toggleCardViewType() async {
    final value = await ref.read(_cardViewTypeNotifier.future);
    ref.read(_cardViewTypeNotifier.notifier).set(value == CardViewType.list ? CardViewType.grid : CardViewType.list);
  }

  void signalSelection() => state = state.copyWith(selectedContents: selectedContents.toList());
}
