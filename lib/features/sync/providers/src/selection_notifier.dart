import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/entities/selection_state.dart';

class SelectionNotifier extends Notifier<SelectionState> {
  @override
  SelectionState build() => const SelectionState();

  void toggleSelect(String id) {
    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(selectedIds: updated);
  }

  void selectAll(List<String> ids) {
    state = state.copyWith(selectedIds: Set<String>.from(ids));
  }

  void clearSelection() {
    state = const SelectionState();
  }

  void deselectIds(List<String> ids) {
    final updated = Set<String>.from(state.selectedIds);
    for (final id in ids) {
      updated.remove(id);
    }
    state = state.copyWith(selectedIds: updated);
  }
}

final uploadSelectionProvider = NotifierProvider<SelectionNotifier, SelectionState>(
  SelectionNotifier.new,
  isAutoDispose: true,
);

final downloadSelectionProvider = NotifierProvider<SelectionNotifier, SelectionState>(
  SelectionNotifier.new,
  isAutoDispose: true,
);

final driveSelectionProvider = NotifierProvider<SelectionNotifier, SelectionState>(
  SelectionNotifier.new,
  isAutoDispose: true,
);
