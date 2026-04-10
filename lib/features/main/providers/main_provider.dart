import 'package:slidesync/features/main/providers/src/home_notifier.dart';
import 'package:slidesync/features/main/providers/src/library_notifier.dart';
import 'package:slidesync/features/main/providers/src/main_notifier.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

final _mainNotifier = NotifierProvider(MainNotifier.new);
final _homeNotifier = NotifierProvider(HomeNotifier.new);
final _libraryNotifier = NotifierProvider(LibraryNotifier.new);

class MainProvider {
  static final state = _mainNotifier;

  static final home = _homeNotifier;
  static final library = _libraryNotifier;
}
