import 'package:flutter/foundation.dart';

mixin ValueNotifierFactoryMixin {
  final Map<int, ValueNotifier> _notifiers = {};
  int _counter = 0;
  bool _disposed = false;

  @protected
  ValueNotifier<T> useValueNotifier<T>(T initialValue) {
    assert(!_disposed, 'Cannot create notifier after disposal');

    final notifierKey = _counter++;
    final notifier = ValueNotifier<T>(initialValue);
    _notifiers[notifierKey] = notifier;
    return notifier;
  }
  @protected
  void disposeNotifiers() {
    if (_disposed) return;
    _disposed = true;

    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
  }
}
