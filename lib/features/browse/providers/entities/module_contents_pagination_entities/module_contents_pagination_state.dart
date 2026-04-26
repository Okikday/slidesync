// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:slidesync/core/constants/src/enums/enums.dart';

class ModuleContentsPaginationState {
  final EntityOrdering contentsOrdering;
  final bool isLoading;

  const ModuleContentsPaginationState({this.contentsOrdering = EntityOrdering.dateModifiedAsc, this.isLoading = false});

  @override
  bool operator ==(covariant ModuleContentsPaginationState other) {
    if (identical(this, other)) return true;

    return other.contentsOrdering == contentsOrdering && other.isLoading == isLoading;
  }

  @override
  int get hashCode => contentsOrdering.hashCode ^ isLoading.hashCode;

  ModuleContentsPaginationState copyWith({EntityOrdering? sortOption, bool? isLoading}) {
    return ModuleContentsPaginationState(
      contentsOrdering: sortOption ?? this.contentsOrdering,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
