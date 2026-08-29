import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickin_storage/kickin_storage.dart';
import 'package:kickin_utilities/kickin_utilities.dart';

// export 'package:flutter_riverpod/flutter_riverpod.dart';

//=============================================
// BASE NOTIFIER
//=============================================
abstract class _BaseNotifier<T> extends Notifier<T> {
  final T _defaultKey;
  _BaseNotifier(this._defaultKey);
  @override
  T build() => _defaultKey;

  void update(T Function(T) cb) {
    final next = cb(state);
    if (next != state) state = next;
  }

  void set(T value) => state = value;
}

//=============================================
// PRIMITIVE TYPE NOTIFIERS
//=============================================
/// A simple `int` notifier with convenience defaults.
class KIntNotifier extends _BaseNotifier<int> {
  KIntNotifier([super._defaultKey = 0]);
}

/// A simple `double` notifier with convenience defaults.
class KDoubleNotifier extends _BaseNotifier<double> {
  KDoubleNotifier([super._defaultKey = 0.0]);
}

/// A simple `String` notifier with convenience defaults.
class KStringNotifier extends _BaseNotifier<String> {
  KStringNotifier([super._defaultKey = '']);
}

/// A boolean notifier with a `toggle()` helper.
class KBoolNotifier extends _BaseNotifier<bool> {
  KBoolNotifier([super._defaultKey = false]);
  void toggle() => state = !state;
}

/// Generic notifier for arbitrary types with simple `set`/`update` helpers.
class KSomeNotifier<T> extends _BaseNotifier<T> {
  KSomeNotifier(super._defaultKey);
}

//=============================================
// ASYNC* BASE NOTIFIER
//=============================================
/// A notifier backed by a [Stream].
class KWatchNotifier<T> extends StreamNotifier<T> {
  final Stream<T> Function() _streamFactory;
  KWatchNotifier(this._streamFactory);
  @override
  Stream<T> build() => _streamFactory();
}

//=============================================
// ASYNC BASE NOTIFIER
//=============================================

abstract class _AsyncBaseNotifier<T> extends AsyncNotifier<T> {
  final T _defaultKey;
  _AsyncBaseNotifier(this._defaultKey);

  @override
  FutureOr<T> build() => _defaultKey;

  void set(T value) => state = AsyncData(value);
}

/// Async notifier that exposes an initial default value and can be set later.
class KSomeAsyncNotifier<T> extends _AsyncBaseNotifier<T> {
  KSomeAsyncNotifier(super._defaultKey);
}

// ============================================================================
// PersistentNotifier - With Hive persistence
// ============================================================================

/// [In] is how the data get's stored
/// [Out] is how the data is output
class KCachedNotifier<In, Out> extends AsyncNotifier<Out> {
  static final _hive = AppHive(boxName: "kRiverpodCacheBoxName");
  final String _key;
  final Out _defaultValue;
  final bool? isUpdateNotifying;
  final FutureOr<Out> Function(In? data)? decode;
  final FutureOr<In> Function(Out raw)? encode;
  final bool autoClearOnTypeError;

  static Future<void>? _hiveInitLock;

  String get key => _key;
  Out get defaultValue => _defaultValue;

  Future<void> _writeLock = Future.value();

  KCachedNotifier(
    this._key,
    this._defaultValue, {
    this.isUpdateNotifying,
    this.decode,
    this.encode,
    this.autoClearOnTypeError = true,
  });

  @override
  Future<Out> build() async {
    return (await KResult.tryRunAsync<Out>(() async {
          await _ensureHiveInitialized();
          final data = await _hive.getData(key: _key);

          if (decode != null) return await decode!(data as In?);
          return data as Out;
        }, logError: false)).onError((e, [st]) {
          if (e is TypeError &&
              autoClearOnTypeError &&
              decode != null &&
              encode != null) {
            log("Data type mismatch detected for key: $_key. Clearing cache.");
            _hive.deleteData(key: _key);
          }
          throw Exception(
            "$e \nTry using decode params to properly decode data",
          );
        }).data ??
        _defaultValue;
  }

  /// Ensures Hive is initialized exactly once, even if 10 Notifiers ask at once
  static Future<void> _ensureHiveInitialized() async {
    if (_hive.isInitialized) return;
    _hiveInitLock ??= _hive.initialize();
    await _hiveInitLock;
  }

  Future<void> set(Out value) async {
    state = AsyncData(value);
    await _ensureHiveInitialized();
    await _scheduleWrite(value);
  }

  Future<void> setRaw(In value) async {
    await _ensureHiveInitialized();
    await _scheduleWrite(value);
  }

  Future<Out> updateIfNotEqual(
    Out Function(Out cb) cb, {
    FutureOr<Out> Function(Object err, StackTrace stackTrace)? onError,
  }) async {
    final newState = await future.then(cb, onError: onError);
    state = AsyncData<Out>(newState);
    return newState;
  }

  Future<void> _scheduleWrite(dynamic value) async {
    _writeLock = _writeLock.then((_) async {
      try {
        final encoded = value is In
            ? value
            : (encode != null ? await encode!(value as Out) : value);
        if (encoded == null) return;

        await _hive.setData(key: _key, value: encoded);
      } catch (e, st) {
        log('Cache write failed for key $_key: $e', stackTrace: st);
      }
    });
    await _writeLock;
  }

  @override
  bool updateShouldNotify(AsyncValue<Out> previous, AsyncValue<Out> next) =>
      isUpdateNotifying ?? super.updateShouldNotify(previous, next);
}
