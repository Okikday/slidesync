import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/utils/result.dart';

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

  Future<void> set(dynamic value) async => state = AsyncData(value);
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

// ============================================================================
// HiveAsyncImpliedNotifier - With Hive persistence
// ============================================================================

class HiveAsyncImpliedNotifier<T> extends AsyncNotifier<T> {
  final String _hiveKey;
  final T _defaultKey;
  final bool? isUpdateNotifying;
  final FutureOr<T?> Function(dynamic data)? resolveData;

  final Queue<Completer<void>> _updateQueue = Queue<Completer<void>>();
  bool _isProcessingQueue = false;

  HiveAsyncImpliedNotifier(this._hiveKey, this._defaultKey, [this.isUpdateNotifying, this.resolveData]);

  @override
  Future<T> build() async {
    return (await Result.tryRunAsync(() async {
          final data = await AppHiveData.instance.getData(key: _hiveKey);
          return resolveData != null ? await resolveData!(data) : data as T? ?? _defaultKey;
        })).data ??
        _defaultKey;
  }

  Future<void> set(T value) async {
    state = AsyncData(value);
    await AppHiveData.instance.setData(key: _hiveKey, value: value);
  }

  /// Schedule an update to be processed sequentially
  Future<void> scheduleUpdating(T value) async {
    final completer = Completer<void>();
    _updateQueue.add(completer);

    // Start processing if not already running
    if (!_isProcessingQueue) {
      _processQueue();
    }

    // Update state immediately for UI responsiveness
    state = AsyncData(value);

    // Wait for this update to be processed
    await completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_updateQueue.isNotEmpty) {
      final completer = _updateQueue.removeFirst();

      try {
        // Get current state value
        final currentValue = state.value;
        if (currentValue != null) {
          await AppHiveData.instance.setData(key: _hiveKey, value: currentValue);
        }
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    }

    _isProcessingQueue = false;
  }

  @override
  bool updateShouldNotify(AsyncValue<T> previous, AsyncValue<T> next) =>
      isUpdateNotifying ?? super.updateShouldNotify(previous, next);
}

// ============================================================================
// HiveAsyncImpliedNotifierN - Nullable with Hive persistence
// ============================================================================

class HiveAsyncImpliedNotifierN<T> extends AsyncNotifier<T?> {
  final T? defaultKey;
  final String _hiveKey;
  final FutureOr<T?> Function(dynamic data)? resolveData;
  bool? _isModifying;

  final Queue<Completer<void>> _updateQueue = Queue<Completer<void>>();
  bool _isProcessingQueue = false;

  /// [null] => it's building or refreshing, [true] => Provider value is currently being modified
  bool? get isModifying => _isModifying;

  HiveAsyncImpliedNotifierN(this._hiveKey, {this.defaultKey, this.resolveData});

  @override
  Future<T?> build() async {
    final data =
        (await Result.tryRunAsync(() async {
          final data = await AppHiveData.instance.getData(key: _hiveKey) as T? ?? defaultKey;
          return resolveData != null ? await resolveData!(data) : data ?? defaultKey;
        })).data ??
        defaultKey;
    _isModifying = false;
    return data;
  }

  Future<void> set(T value) async {
    _isModifying = true;
    state = AsyncData(value);
    await AppHiveData.instance.setData(key: _hiveKey, value: value);
    _isModifying = false;
  }

  /// Schedule an update to be processed sequentially
  Future<void> scheduleUpdating(T value) async {
    final completer = Completer<void>();
    _updateQueue.add(completer);

    // Start processing if not already running
    if (!_isProcessingQueue) {
      _processQueue();
    }

    // Update state immediately for UI responsiveness
    _isModifying = true;
    state = AsyncData(value);

    // Wait for this update to be processed
    await completer.future;
    _isModifying = false;
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_updateQueue.isNotEmpty) {
      final completer = _updateQueue.removeFirst();

      try {
        // Get current state value
        final currentValue = state.value;
        if (currentValue != null) {
          await AppHiveData.instance.setData(key: _hiveKey, value: currentValue);
        }
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    }

    _isProcessingQueue = false;
  }
}

// ============================================================================
// AsyncImpliedNotifier - Without Hive (in-memory only)
// ============================================================================

class AsyncImpliedNotifier<T> extends AsyncNotifier<T> {
  final T _defaultValue;
  final bool? isUpdateNotifying;
  final FutureOr<T> Function()? initializer;

  final Queue<Completer<void>> _updateQueue = Queue<Completer<void>>();
  bool _isProcessingQueue = false;

  AsyncImpliedNotifier(this._defaultValue, {this.isUpdateNotifying, this.initializer});

  @override
  Future<T> build() async {
    if (initializer != null) {
      return await initializer!();
    }
    return _defaultValue;
  }

  Future<void> set(T value) async {
    state = AsyncData(value);
  }

  /// Schedule an update to be processed sequentially
  Future<void> scheduleUpdating(T value) async {
    final completer = Completer<void>();
    _updateQueue.add(completer);

    // Start processing if not already running
    if (!_isProcessingQueue) {
      _processQueue();
    }

    // Update state immediately for UI responsiveness
    state = AsyncData(value);

    // Wait for this update to be processed
    await completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_updateQueue.isNotEmpty) {
      final completer = _updateQueue.removeFirst();

      try {
        // For in-memory notifier, we just complete the operation
        // You can add custom logic here if needed (e.g., validation, callbacks)
        await Future.delayed(Duration.zero); // Yield to event loop
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    }

    _isProcessingQueue = false;
  }

  @override
  bool updateShouldNotify(AsyncValue<T> previous, AsyncValue<T> next) =>
      isUpdateNotifying ?? super.updateShouldNotify(previous, next);
}

// ============================================================================
// AsyncImpliedNotifierN - Nullable without Hive (in-memory only)
// ============================================================================

class AsyncImpliedNotifierN<T> extends AsyncNotifier<T?> {
  final T? defaultValue;
  final FutureOr<T?> Function()? initializer;
  bool? _isModifying;

  final Queue<Completer<void>> _updateQueue = Queue<Completer<void>>();
  bool _isProcessingQueue = false;

  /// [null] => it's building or refreshing, [true] => Provider value is currently being modified
  bool? get isModifying => _isModifying;

  AsyncImpliedNotifierN({this.defaultValue, this.initializer});

  @override
  Future<T?> build() async {
    _isModifying = false;
    if (initializer != null) {
      return await initializer!();
    }
    return defaultValue;
  }

  Future<void> set(T? value) async {
    _isModifying = true;
    state = AsyncData(value);
    _isModifying = false;
  }

  /// Schedule an update to be processed sequentially
  Future<void> scheduleUpdating(T? value) async {
    final completer = Completer<void>();
    _updateQueue.add(completer);

    // Start processing if not already running
    if (!_isProcessingQueue) {
      _processQueue();
    }

    // Update state immediately for UI responsiveness
    _isModifying = true;
    state = AsyncData(value);

    // Wait for this update to be processed
    await completer.future;
    _isModifying = false;
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_updateQueue.isNotEmpty) {
      final completer = _updateQueue.removeFirst();

      try {
        // For in-memory notifier, we just complete the operation
        // You can add custom logic here if needed (e.g., validation, callbacks)
        await Future.delayed(Duration.zero); // Yield to event loop
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    }

    _isProcessingQueue = false;
  }
}
