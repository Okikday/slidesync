import 'package:slidesync/features/main/providers/src/home_notifier.dart';
import 'package:slidesync/features/main/providers/src/library_notifier.dart';
import 'package:slidesync/features/main/providers/src/main_notifier.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _mainProvider = Provider((ref) => MainProvider());

final _mainNotifier = NotifierProvider(MainNotifier.new);
final _homeNotifier = NotifierProvider(HomeNotifier.new);
final _libraryNotifier = NotifierProvider(LibraryNotifier.new);

class MainProvider {
  static MainProvider of(WidgetRef ref) => ref.read(_mainProvider);
  static MainProvider ofX(Ref ref) => ref.read(_mainProvider);

  // r: provided ref, v: provider class
  static T from<T>(WidgetRef ref, T Function(WidgetRef r, MainProvider v) selector) => selector(ref, of(ref));

  final state = _mainNotifier;

  final home = _homeNotifier;
  final library = _libraryNotifier;
}
