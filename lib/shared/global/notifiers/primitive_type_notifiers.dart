import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart';

class BoolNotifier extends Notifier<bool> {
  final bool _defaultKey;
  BoolNotifier([this._defaultKey = false]);
  @override
  bool build() {
    return _defaultKey;
  }

  void update(bool Function(bool) cb) {
    final next = cb(state);
    if (next == state) return;
    state = next;
  }

  void set(bool value) => state = value;
  void toggle() => state = !state;
}

class IntNotifier extends Notifier<int> {
  final int _defaultKey;
  IntNotifier([this._defaultKey = 0]);
  @override
  int build() {
    return _defaultKey;
  }

  void update(int Function(int) cb) {
    final next = cb(state);
    if (next == state) return;
    state = next;
  }

  void set(int value) => state = value;
}

class DoubleNotifier extends Notifier<double> {
  final double _defaultKey;
  DoubleNotifier([this._defaultKey = 0.0]);
  @override
  double build() {
    return _defaultKey;
  }

  void update(double Function(double) cb) {
    final next = cb(state);
    if (next == state) return;
    state = next;
  }

  void set(double value) => state = value;
}

// Async Notifier versions

class AsyncBoolNotifier extends AsyncNotifier<bool> {
  final bool _defaultKey;
  AsyncBoolNotifier([this._defaultKey = false]);
  @override
  Future<bool> build() async {
    return _defaultKey;
  }

  void set(bool value) => state = AsyncData(value);

  void toggle() {
    final current = state.value ?? _defaultKey;
    state = AsyncData(!current);
  }
}

class AsyncIntNotifier extends AsyncNotifier<int> {
  final int _defaultKey;
  AsyncIntNotifier([this._defaultKey = 0]);
  @override
  Future<int> build() async {
    return _defaultKey;
  }

  void set(int value) => state = AsyncData(value);
}

class AsyncDoubleNotifier extends AsyncNotifier<double> {
  final double _defaultKey;
  AsyncDoubleNotifier([this._defaultKey = 0.0]);
  @override
  Future<double> build() async {
    return _defaultKey;
  }

  void set(double value) => state = AsyncData(value);
}

class DynamicNotifier extends Notifier<dynamic> {
  final dynamic _defaultKey;
  DynamicNotifier([this._defaultKey]);
  @override
  dynamic build() {
    return _defaultKey;
  }

  void update(dynamic Function(dynamic) cb) {
    final next = cb(state);
    if (next == state) return;
    state = next;
  }

  void set(dynamic value) => state = value;
}

class AsyncDynamicNotifier extends AsyncNotifier<dynamic> {
  final dynamic _defaultKey;
  AsyncDynamicNotifier([this._defaultKey]);
  @override
  Future<dynamic> build() async {
    return _defaultKey;
  }

  void set(dynamic value) => state = AsyncData(value);
}

class ImpliedNotifier<T> extends Notifier<T> {
  final T _defaultKey;
  ImpliedNotifier(this._defaultKey);
  @override
  T build() {
    return _defaultKey;
  }

  void update(T Function(T) cb) {
    final next = cb(state);
    if (next == state) return;
    state = next;
  }

  void set(T value) => state = value;
}

class AsyncImpliedNotifier<T> extends AsyncNotifier<T> {
  final T _defaultKey;
  AsyncImpliedNotifier(this._defaultKey);
  @override
  Future<T> build() async {
    return _defaultKey;
  }

  void set(T value) => state = AsyncData(value);
}

class ImpliedNotifierN<T> extends Notifier<T?> {
  final T? _defaultKey;
  ImpliedNotifierN([this._defaultKey]);
  @override
  T? build() {
    return _defaultKey;
  }

  void update(T? Function(T?) cb) {
    final next = cb(state);
    if (next == state) return;
    state = next;
  }

  void set(T? value) => state = value;
}

class AsyncImpliedNotifierN<T> extends AsyncNotifier<T?> {
  final T? _defaultKey;
  AsyncImpliedNotifierN([this._defaultKey]);
  @override
  Future<T?> build() async {
    return _defaultKey;
  }

  void set(T? value) => state = AsyncData(value);
}
