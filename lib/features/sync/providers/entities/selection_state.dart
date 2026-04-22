class SelectionState {
  final Set<String> selectedIds;

  const SelectionState({this.selectedIds = const {}});

  int get count => selectedIds.length;

  bool isSelected(String id) => selectedIds.contains(id);

  SelectionState copyWith({Set<String>? selectedIds}) {
    return SelectionState(selectedIds: selectedIds ?? this.selectedIds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectionState && runtimeType == other.runtimeType && selectedIds == other.selectedIds;

  @override
  int get hashCode => selectedIds.hashCode;
}
