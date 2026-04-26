import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SERIALIZATION CONTRACT
//
// Every function or closure passed into this library crosses an isolate
// boundary. Dart can send closures since 2.15, but only if every captured
// value is itself sendable. The following types are NOT sendable and will cause
// a runtime SendPortError:
//
//   ✗  ChangeNotifier / any Listenable
//   ✗  BuildContext
//   ✗  TextEditingController (or any class backed by a platform channel)
//   ✗  Isolate handles
//   ✗  dart:ffi pointers
//   ✗  'this' inside a non-sendable class (use top-level or static functions
//      to avoid implicitly capturing the enclosing instance)
//
// Safe patterns:
//
//   // Top-level or static function — always safe:
//   Future<int> _work(String arg, void Function(int) emit) async { ... }
//   isolateRun(_work, 'hello');
//
//   // Closure capturing only plain Dart values — safe:
//   final int timeout = prefs.getInt('timeout') ?? 30;
//   isolateRun((arg, emit) async => fetchWithTimeout(arg, timeout), 'url');
//
//   // Closure capturing a non-sendable — WILL CRASH at runtime:
//   isolateRun((arg, emit) async => controller.text, arg); // ✗
//
// ─────────────────────────────────────────────────────────────────────────────

/// Priority levels for [SmartIsolateContinuous] task scheduling.
enum WorkPriority { low, medium, high }

/// Default maximum queued tasks before [SmartIsolateContinuous.execute] throws.
const int kDefaultMaxQueueSize = 512;

// ─── SmartIsolate ─────────────────────────────────────────────────────────────

/// Runs a single async task in a dedicated isolate with progress reporting.
///
/// Prefer the built-in [Isolate.run] when you do not need progress callbacks.
/// This class adds the overhead of a [ReceivePort] loop solely for that feature.
///
/// See [SmartIsolateAccess] for convenient mixin-based access.
class SmartIsolate<TArg, TProgress, TResult> {
  SmartIsolate._();

  Isolate? _isolate;
  ReceivePort? _port;
  StreamSubscription<dynamic>? _sub;
  StreamController<TProgress>? _progressCtrl;
  bool _started = false;
  bool _cleaned = false;

  /// Spawns an isolate, runs [task], and returns its result.
  ///
  /// [onProgress] fires on the calling isolate each time the task calls its
  /// `emit` callback. Throws [SmartIsolateException] on spawn failure or an
  /// uncaught exception inside [task].
  static Future<TResult> run<TArg, TProgress, TResult>(
    Future<TResult> Function(TArg arg, void Function(TProgress) emit) task,
    TArg arg, {
    void Function(TProgress)? onProgress,
  }) => SmartIsolate<TArg, TProgress, TResult>._()._execute(task, arg, onProgress: onProgress);

  Future<TResult> _execute(
    Future<TResult> Function(TArg, void Function(TProgress)) task,
    TArg arg, {
    void Function(TProgress)? onProgress,
  }) async {
    assert(!_started, 'SmartIsolate instances are single-use; use SmartIsolate.run().');
    _started = true;

    final port = ReceivePort();
    _port = port;

    final ctrl = StreamController<TProgress>.broadcast();
    _progressCtrl = ctrl;

    StreamSubscription<TProgress>? progressSub;
    if (onProgress != null) progressSub = ctrl.stream.listen(onProgress);

    final result = Completer<TResult>();

    _sub = port.listen((msg) {
      if (msg is _Progress<TProgress>) {
        if (!ctrl.isClosed) ctrl.add(msg.value);
      } else if (msg is _Result<TResult>) {
        if (!result.isCompleted) result.complete(msg.value);
      } else if (msg is _Failure) {
        if (!result.isCompleted) {
          result.completeError(SmartIsolateException(msg.error.toString(), msg.stack), msg.stack);
        }
      }
    });

    try {
      _isolate = await Isolate.spawn(
        _entry<TArg, TProgress, TResult>,
        _OneShotPayload<TArg, TProgress, TResult>(arg: arg, task: task, port: port.sendPort),
      );
    } catch (e, st) {
      _cleanup();
      throw SmartIsolateException(
        'Isolate failed to spawn: $e\n'
        'Verify the task closure does not capture non-sendable objects '
        '(see serialization contract at the top of smart_isolate.dart).',
        st,
      );
    }

    try {
      return await result.future;
    } finally {
      await progressSub?.cancel();
      _cleanup();
    }
  }

  void _cleanup() {
    if (_cleaned) return;
    _cleaned = true;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sub?.cancel();
    _sub = null;
    if (!(_progressCtrl?.isClosed ?? true)) _progressCtrl!.close();
    _progressCtrl = null;
    _port?.close();
    _port = null;
  }

  static void _entry<TArg, TProgress, TResult>(_OneShotPayload<TArg, TProgress, TResult> p) async {
    try {
      final value = await p.task(p.arg, (TProgress v) => p.port.send(_Progress<TProgress>(v)));
      p.port.send(_Result<TResult>(value));
    } catch (e, st) {
      p.port.send(_Failure(e, st));
    }
  }
}

// ─── SmartIsolateContinuous ───────────────────────────────────────────────────

/// A persistent isolate that processes tasks sequentially with priority queuing.
///
/// Tasks run one at a time inside a single long-lived isolate, avoiding
/// repeated spawn overhead. This is the right tool when initialisation cost is
/// high (e.g. loading an ML model or opening a database connection).
///
/// **Priority and starvation prevention:**
/// Tasks are dispatched high → medium → low. Every [agingThreshold] non-low
/// dispatches, the oldest queued low-priority task is forcibly promoted so it
/// cannot wait indefinitely.
///
/// **Backpressure:**
/// [execute] throws immediately when queued tasks reach [maxQueueSize], rather
/// than growing memory without bound.
///
/// **Isolate-to-main thread safety:**
/// The `_dispatching` flag is set and cleared only inside port-listener
/// callbacks, which always run on the main isolate's event loop — no concurrent
/// mutation possible.
///
/// See [SmartIsolateAccess] for convenient mixin-based access.
class SmartIsolateContinuous<TArg, TResult> {
  SmartIsolateContinuous._({required this.maxQueueSize, required this.agingThreshold});

  /// Spawns and initialises a persistent isolate worker.
  ///
  /// [initialize] runs inside the new isolate. It **must** call
  /// [registerHandler] exactly once before returning. Any Flutter
  /// platform-channel access inside [initialize] requires [rootIsolateToken].
  ///
  /// Note: avoid calling `rootBundle` or platform channels in [initialize]
  /// before [rootIsolateToken] has been applied — the entry point applies the
  /// token as the very first step before invoking [initialize].
  static Future<SmartIsolateContinuous<TArg, TResult>> spawn<TArg, TResult>(
    Future<void> Function(void Function(void Function(TArg arg, void Function(TResult) respond)) registerHandler)
    initialize, {
    RootIsolateToken? rootIsolateToken,
    int maxQueueSize = kDefaultMaxQueueSize,
    int agingThreshold = 10,
  }) async {
    final inst = SmartIsolateContinuous<TArg, TResult>._(maxQueueSize: maxQueueSize, agingThreshold: agingThreshold);
    await inst._init(initialize, rootIsolateToken: rootIsolateToken);
    return inst;
  }

  final int maxQueueSize;
  final int agingThreshold;

  Isolate? _isolate;
  ReceivePort? _port;
  SendPort? _workerPort;
  StreamSubscription<dynamic>? _sub;
  bool _running = false;

  final Map<int, Completer<TResult>> _pending = {};
  int _nextId = 0;
  static const int _maxId = 0x7FFFFFFFFFFFFFFF;

  final Queue<_Queued<TArg>> _high = Queue();
  final Queue<_Queued<TArg>> _med = Queue();
  final Queue<_Queued<TArg>> _low = Queue();

  bool _dispatching = false;
  int _nonLowSincePromotion = 0;

  bool get isRunning => _running;

  /// Total tasks waiting across all priority queues.
  int get pendingCount => _high.length + _med.length + _low.length;

  Future<void> _init(
    Future<void> Function(void Function(void Function(TArg, void Function(TResult))) registerHandler) initialize, {
    RootIsolateToken? rootIsolateToken,
  }) async {
    final port = ReceivePort();
    _port = port;
    final ready = Completer<SendPort>();

    _sub = port.listen((msg) {
      if (msg is SendPort) {
        if (!ready.isCompleted) ready.complete(msg);
      } else if (msg is _ContResult<TResult>) {
        final c = _pending.remove(msg.taskId);
        c?.complete(msg.value);
        _dispatching = false;
        _next();
      } else if (msg is _ContFailure) {
        final c = _pending.remove(msg.taskId);
        c?.completeError(SmartIsolateException(msg.error.toString(), msg.stack), msg.stack);
        _dispatching = false;
        _next();
      }
    });

    try {
      _isolate = await Isolate.spawn(
        _workerEntry<TArg, TResult>,
        _ContinuousPayload<TArg, TResult>(
          mainPort: port.sendPort,
          initialize: initialize,
          rootIsolateToken: rootIsolateToken,
        ),
      );
      _workerPort = await ready.future;
      _running = true;
    } catch (e, st) {
      _teardown(kill: false);
      throw SmartIsolateException('Failed to spawn continuous isolate: $e', st);
    }
  }

  /// Enqueues [arg] for execution at the given [priority].
  ///
  /// Throws [SmartIsolateException] if the isolate is not running or the
  /// queue is full.
  Future<TResult> execute(TArg arg, {WorkPriority priority = WorkPriority.medium}) {
    if (!_running) throw const SmartIsolateException('Isolate is not running.');
    if (pendingCount >= maxQueueSize) {
      throw SmartIsolateException('Task queue is full ($maxQueueSize). Apply backpressure or raise maxQueueSize.');
    }

    final id = _nextId;
    _nextId = _nextId >= _maxId ? 0 : _nextId + 1;

    final completer = Completer<TResult>();
    _pending[id] = completer;

    final task = _Queued<TArg>(id, arg);
    switch (priority) {
      case WorkPriority.high:
        _high.add(task);
      case WorkPriority.medium:
        _med.add(task);
      case WorkPriority.low:
        _low.add(task);
    }

    _next();
    return completer.future;
  }

  void _next() {
    if (_dispatching || _workerPort == null) return;

    _Queued<TArg>? task;

    if (_low.isNotEmpty && _nonLowSincePromotion >= agingThreshold) {
      task = _low.removeFirst();
      _nonLowSincePromotion = 0;
    } else if (_high.isNotEmpty) {
      task = _high.removeFirst();
      _nonLowSincePromotion++;
    } else if (_med.isNotEmpty) {
      task = _med.removeFirst();
      _nonLowSincePromotion++;
    } else if (_low.isNotEmpty) {
      task = _low.removeFirst();
      _nonLowSincePromotion = 0;
    }

    if (task == null) return;
    _dispatching = true;
    _workerPort!.send(_ContTask<TArg>(task.id, task.arg));
  }

  /// Kills the isolate. All pending tasks fail with [SmartIsolateException].
  void dispose() => _teardown(kill: true);

  void _teardown({required bool kill}) {
    if (!_running && _pending.isEmpty) return;
    _running = false;

    if (kill) _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sub?.cancel();
    _sub = null;
    _port?.close();
    _port = null;
    _workerPort = null;

    _high.clear();
    _med.clear();
    _low.clear();

    for (final c in _pending.values) {
      if (!c.isCompleted) c.completeError(const SmartIsolateException('Isolate disposed.'));
    }
    _pending.clear();
    _dispatching = false;
    _nonLowSincePromotion = 0;
  }

  static void _workerEntry<TArg, TResult>(_ContinuousPayload<TArg, TResult> p) async {
    if (p.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(p.rootIsolateToken!);
    }

    final port = ReceivePort();
    p.mainPort.send(port.sendPort);

    void Function(TArg, void Function(TResult))? handler;

    try {
      await p.initialize((h) => handler = h);
      if (handler == null) throw StateError('registerHandler() was never called.');
    } catch (e, st) {
      p.mainPort.send(_ContFailure(-1, e, st));
      return;
    }

    await for (final msg in port) {
      if (msg is _ContTask<TArg>) {
        try {
          final result = Completer<TResult>();
          handler!(msg.arg, (v) {
            if (!result.isCompleted) result.complete(v);
          });
          p.mainPort.send(_ContResult<TResult>(msg.taskId, await result.future));
        } catch (e, st) {
          p.mainPort.send(_ContFailure(msg.taskId, e, st));
        }
      }
    }
  }
}

// ─── SmartIsolateAccess mixin ─────────────────────────────────────────────────

/// Mixin that gives any class convenient, named access to isolate operations.
///
/// Mix this into any class — a service, a controller, a repository — and
/// call [isolateRun] or [isolateSpawn] directly without importing or
/// referencing [SmartIsolate] or [SmartIsolateContinuous] at the call site.
///
/// ```dart
/// class ImageProcessor with SmartIsolateAccess {
///   Future<Uint8List> compress(Uint8List bytes) async {
///     return isolateRun<Uint8List, double, Uint8List>(
///       (data, emit) async {
///         emit(0.5);
///         return _doCompress(data);
///       },
///       bytes,
///       onProgress: (pct) => print('${(pct * 100).round()}%'),
///     );
///   }
/// }
///
/// class HeavySearchService with SmartIsolateAccess {
///   late final SmartIsolateContinuous<String, List<String>> _worker;
///
///   Future<void> init() async {
///     _worker = await isolateSpawn(
///       (register) async {
///         final index = await buildIndex(); // heavy init, runs once
///         register((query, respond) => respond(index.search(query)));
///       },
///     );
///   }
///
///   Future<List<String>> search(String q) => _worker.execute(q);
///   void dispose() => _worker.dispose();
/// }
/// ```
mixin SmartIsolateAccess {
  /// Runs a one-shot task in a new isolate. Equivalent to [SmartIsolate.run].
  Future<TResult> isolateRun<TArg, TProgress, TResult>(
    Future<TResult> Function(TArg arg, void Function(TProgress) emit) task,
    TArg arg, {
    void Function(TProgress)? onProgress,
  }) => SmartIsolate.run<TArg, TProgress, TResult>(task, arg, onProgress: onProgress);

  /// Spawns a persistent isolate worker. Equivalent to [SmartIsolateContinuous.spawn].
  Future<SmartIsolateContinuous<TArg, TResult>> isolateSpawn<TArg, TResult>(
    Future<void> Function(void Function(void Function(TArg, void Function(TResult))) registerHandler) initialize, {
    RootIsolateToken? rootIsolateToken,
    int maxQueueSize = kDefaultMaxQueueSize,
    int agingThreshold = 10,
  }) => SmartIsolateContinuous.spawn<TArg, TResult>(
    initialize,
    rootIsolateToken: rootIsolateToken,
    maxQueueSize: maxQueueSize,
    agingThreshold: agingThreshold,
  );
}

// ─── Exception ────────────────────────────────────────────────────────────────

class SmartIsolateException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const SmartIsolateException(this.message, [this.stackTrace]);

  @override
  String toString() => 'SmartIsolateException: $message';
}

// ─── Internal DTOs ────────────────────────────────────────────────────────────

class _OneShotPayload<TArg, TProgress, TResult> {
  final TArg arg;
  final Future<TResult> Function(TArg, void Function(TProgress)) task;
  final SendPort port;
  const _OneShotPayload({required this.arg, required this.task, required this.port});
}

class _Progress<T> {
  final T value;
  const _Progress(this.value);
}

class _Result<T> {
  final T value;
  const _Result(this.value);
}

class _Failure {
  final Object error;
  final StackTrace? stack;
  const _Failure(this.error, [this.stack]);
}

class _ContinuousPayload<TArg, TResult> {
  final SendPort mainPort;
  final Future<void> Function(void Function(void Function(TArg, void Function(TResult))) registerHandler) initialize;
  final RootIsolateToken? rootIsolateToken;
  const _ContinuousPayload({required this.mainPort, required this.initialize, this.rootIsolateToken});
}

class _Queued<TArg> {
  final int id;
  final TArg arg;
  const _Queued(this.id, this.arg);
}

class _ContTask<TArg> {
  final int taskId;
  final TArg arg;
  const _ContTask(this.taskId, this.arg);
}

class _ContResult<TResult> {
  final int taskId;
  final TResult value;
  const _ContResult(this.taskId, this.value);
}

class _ContFailure {
  final int taskId;
  final Object error;
  final StackTrace? stack;
  const _ContFailure(this.taskId, this.error, [this.stack]);
}
