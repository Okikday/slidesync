import 'package:flutter/foundation.dart';

import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ModuleContentsState {
  final bool isLoading;
  final CardViewType cardViewType;
  final List<ModuleContent> selectedContents;
  const ModuleContentsState({
    this.isLoading = false,
    this.cardViewType = CardViewType.list,
    this.selectedContents = const [],
  });

  bool get hasSelectedContents => selectedContents.isNotEmpty;

  @override
  bool operator ==(covariant ModuleContentsState other) {
    if (identical(this, other)) return true;

    return other.isLoading == isLoading &&
        other.cardViewType == cardViewType &&
        listEquals(other.selectedContents, selectedContents);
  }

  @override
  int get hashCode => isLoading.hashCode ^ cardViewType.hashCode ^ selectedContents.hashCode;

  ModuleContentsState copyWith({bool? isLoading, CardViewType? cardViewType, List<ModuleContent>? selectedContents}) {
    return ModuleContentsState(
      isLoading: isLoading ?? this.isLoading,
      cardViewType: cardViewType ?? this.cardViewType,
      selectedContents: selectedContents ?? this.selectedContents,
    );
  }
}
