// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:slidesync/core/constants/src/enums/enums.dart';

class LibraryState {
  final CardViewType cardViewType;
  final bool isLoading;

  LibraryState({this.cardViewType = CardViewType.list, this.isLoading = false});

  LibraryState copyWith({CardViewType? cardViewType, bool? isLoading}) {
    return LibraryState(cardViewType: cardViewType ?? this.cardViewType, isLoading: isLoading ?? this.isLoading);
  }

  @override
  bool operator ==(covariant LibraryState other) {
    if (identical(this, other)) return true;

    return other.cardViewType == cardViewType && other.isLoading == isLoading;
  }

  @override
  int get hashCode => cardViewType.hashCode ^ isLoading.hashCode;
}
