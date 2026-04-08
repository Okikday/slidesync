class MainState {
  final int tabIndex;

  const MainState({this.tabIndex = 0});

  MainState copyWith({int? tabIndex}) {
    return MainState(tabIndex: tabIndex ?? this.tabIndex);
  }

  @override
  bool operator ==(covariant MainState other) {
    if (identical(this, other)) return true;

    return other.tabIndex == tabIndex;
  }

  @override
  int get hashCode => tabIndex.hashCode;
}
