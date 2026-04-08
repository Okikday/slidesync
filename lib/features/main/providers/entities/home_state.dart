class HomeState {
  final bool isScrolled;
  const HomeState({this.isScrolled = false});

  HomeState copyWith({bool? isScrolled}) {
    return HomeState(isScrolled: isScrolled ?? this.isScrolled);
  }

  @override
  bool operator ==(covariant HomeState other) {
    if (identical(this, other)) return true;

    return other.isScrolled == isScrolled;
  }

  @override
  int get hashCode => isScrolled.hashCode;
}
