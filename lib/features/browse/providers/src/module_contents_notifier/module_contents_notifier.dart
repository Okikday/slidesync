import 'dart:collection';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/features/browse/providers/entities/module_contents_state.dart';
import 'package:slidesync/features/browse/providers/src/module_contents_pagination_notifier/module_contents_pagination_notifier.dart';
import 'package:slidesync/shared/global/notifiers/common/card_view_type_notifier.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

part 'ext_module_contents_notifier.dart';

final _moduleContentsPaginationNotifier = NotifierProvider.autoDispose.family(
  (int moduleId) => ModuleContentsPaginationNotifier(moduleId),
);

final _cardViewTypeNotifier = AsyncNotifierProvider.autoDispose(
  () => CardViewTypeNotifier(HiveDataPathKey.moduleContentsCardViewType.name, CardViewType.list),
);

class ModuleContentsNotifier extends Notifier<ModuleContentsState> {
  ///
  ///
  /// ===================================================================================================
  /// DECLARATIONS
  /// ===================================================================================================

  final NotifierProvider<ModuleContentsPaginationNotifier, ModuleContentsPaginationState> contentsPagination;

  final selectedContents = LinkedHashSet<ModuleContent>(
    equals: (a, b) => a.id == b.id && a.uid == b.uid,
    hashCode: (item) => item.id.hashCode ^ item.uid.hashCode,
  );

  ModuleContentsNotifier(int moduleId) : contentsPagination = _moduleContentsPaginationNotifier(moduleId);

  ///
  ///
  /// ===================================================================================================
  /// LIFECYCLE
  /// ===================================================================================================

  @override
  ModuleContentsState build() {
    final cardViewType = _cardViewTypeNotifier.readX(ref).value;

    ref.listen(_cardViewTypeNotifier, (prev, next) {
      next.whenData((newType) {
        state = state.copyWith(cardViewType: newType);
        // Notify the pagination notifier so it refreshes the right controller.
        ref.read(contentsPagination.notifier).refreshForViewType(newType);
      });
    });

    ref.emptyListenMany([contentsPagination]);
    ref.onDispose(() => log('Disposed: $runtimeType'));

    return ModuleContentsState(cardViewType: cardViewType ?? CardViewType.list);
  }

  ///
  ///
  /// ===================================================================================================
  /// PUBLIC API
  /// ===================================================================================================

  /// Cycles: list → grid → organized → list.
  void toggleCardViewType() async {
    final current = await ref.read(_cardViewTypeNotifier.future);
    final next = switch (current) {
      CardViewType.list => CardViewType.grid,
      CardViewType.grid => CardViewType.organized,
      CardViewType.organized || CardViewType.other => CardViewType.list,
    };
    ref.read(_cardViewTypeNotifier.notifier).set(next);
  }

  /// Sets [CardViewType] directly — useful for UI buttons that jump to a
  /// specific view rather than cycling.
  void setCardViewType(CardViewType type) {
    ref.read(_cardViewTypeNotifier.notifier).set(type);
  }

  void signalSelection() => state = state.copyWith(selectedContents: selectedContents.toList());
}
