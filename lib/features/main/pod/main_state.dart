import 'package:equatable/equatable.dart';

class MainState extends Equatable {
  final int tabIndex;

  const MainState({this.tabIndex = 0});

  MainState copyWith({int? tabIndex}) =>
      MainState(tabIndex: tabIndex ?? this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}
