import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isScrolled;
  const HomeState({this.isScrolled = false});

  HomeState copyWith({bool? isScrolled}) {
    return HomeState(isScrolled: isScrolled ?? this.isScrolled);
  }

  @override
  List<Object?> get props => [isScrolled];
}
