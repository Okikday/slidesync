import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

/// Priority levels for task execution
enum WorkPriority { low, medium, high }

/// Example usage with progress and priority:
/// ```dart
/// final result = await SmartIsolate.run<String, int, int>(
///   (arg, progress) async {
///     for (int i = 1; i <= 5; i++) {
///       await Future.delayed(Duration(seconds: 1));
///       progress(i);
///       if (i == 5) return 42;
///     }
///     return 0;
///   },
///   "test",
///   priority: WorkPriority.high,
///   onProgress: (p) => print("Progress: $p"),
/// );
/// print("Final result: $result");
/// ```

class SmartIsolate<TArg, TProgress, TResult> {
  late final Isolate _isolate;
  final ReceivePort _receivePort = ReceivePort();
  late final StreamController<TProgress> _progressController;
  StreamSubscription? _portSubscription;
  bool _isRunning = false;

  SmartIsolate() {
    _progressController = StreamController<TProgress>.broadcast();
  }

  bool get isRunning => _isRunning;

  static Future<TResult> run<TArg, TProgress, TResult>(
    Future<TResult> Function(TArg arg, void Function(TProgress) emitProgress) task,
    TArg arg, {
    WorkPriority priority = WorkPriority.medium,
    void Function(TProgress)? onProgress,
  }) async {
    final instance = SmartIsolate<TArg, TProgress, TResult>();

    if (onProgress != null) {
      instance.progressStream.listen(onProgress);
    }

    try {
      return await instance.runWithProgress(task, arg, priority: priority);
    } finally {
      instance.dispose();
    }
  }

  static Future<SmartIsolateContinuous<TArg, TResult>> runContinuous<TArg, TResult>(
    Future<void> Function(void Function(TArg, void Function(TResult))) initialize,
  ) async {
    final instance = SmartIsolateContinuous<TArg, TResult>();
    await instance._initialize(initialize);
    return instance;
  }

  Future<TResult> runWithProgress(
    Future<TResult> Function(TArg arg, void Function(TProgress) emitProgress) task,
    TArg arg, {
    WorkPriority priority = WorkPriority.medium,
  }) async {
    if (_isRunning) {
      throw StateError('SmartIsolate is already running. Create a new instance or wait for completion.');
    }

    _isRunning = true;
    final completer = Completer<TResult>();

    _portSubscription = _receivePort.listen((dynamic message) {
      if (message is _SmartIsolateProgress<TProgress>) {
        if (!_progressController.isClosed) {
          _progressController.add(message.data);
        }
      } else if (message is _SmartIsolateResult<TResult>) {
        if (!completer.isCompleted) {
          completer.complete(message.data);
          _tearDown();
        }
      } else if (message is _SmartIsolateError) {
        if (!completer.isCompleted) {
          completer.completeError(SmartIsolateException(message.error.toString(), message.stack), message.stack);
          _tearDown();
        }
      }
    });

    try {
      _isolate = await Isolate.spawn<_SmartIsolatePayload<TArg, TProgress, TResult>>(
        _entryPoint,
        _SmartIsolatePayload<TArg, TProgress, TResult>(arg: arg, task: task, mainSendPort: _receivePort.sendPort),
      );
    } catch (e, stackTrace) {
      _tearDown();
      throw SmartIsolateException('Failed to spawn isolate: $e', stackTrace);
    }

    return completer.future;
  }

  Stream<TProgress> get progressStream => _progressController.stream;

  void cancel() {
    if (_isRunning) {
      _isolate.kill(priority: Isolate.immediate);
      _tearDown();
    }
  }

  void dispose() {
    cancel();
  }

  void _tearDown() {
    _isRunning = false;
    _portSubscription?.cancel();
    if (!_progressController.isClosed) _progressController.close();
    _receivePort.close();
  }

  static void _entryPoint<TArg, TProgress, TResult>(_SmartIsolatePayload<TArg, TProgress, TResult> payload) async {
    try {
      void emitProgress(TProgress data) {
        payload.mainSendPort.send(_SmartIsolateProgress<TProgress>(data));
      }

      final result = await payload.task(payload.arg, emitProgress);
      payload.mainSendPort.send(_SmartIsolateResult<TResult>(result));
    } catch (e, st) {
      payload.mainSendPort.send(_SmartIsolateError(e, st));
    }
  }
}

class SmartIsolateContinuous<TArg, TResult> {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _isolateSendPort;
  StreamSubscription? _portSubscription;
  bool _isRunning = false;
  final Map<int, Completer<TResult>> _pendingTasks = {};
  int _taskIdCounter = 0;

  // Priority queues
  final Queue<_QueuedTask<TArg>> _highPriorityQueue = Queue();
  final Queue<_QueuedTask<TArg>> _mediumPriorityQueue = Queue();
  final Queue<_QueuedTask<TArg>> _lowPriorityQueue = Queue();
  bool _isProcessingQueue = false;

  bool get isRunning => _isRunning;

  Future<void> _initialize(Future<void> Function(void Function(TArg, void Function(TResult))) initialize) async {
    if (_isRunning) {
      throw StateError('SmartIsolateContinuous is already running');
    }

    _receivePort = ReceivePort();
    final readyCompleter = Completer<SendPort>();

    _portSubscription = _receivePort!.listen((dynamic message) {
      if (message is SendPort) {
        readyCompleter.complete(message);
      } else if (message is _ContinuousIsolateResult<TResult>) {
        final completer = _pendingTasks.remove(message.taskId);
        completer?.complete(message.data);
        _processNextTask();
      } else if (message is _ContinuousIsolateError) {
        final completer = _pendingTasks.remove(message.taskId);
        completer?.completeError(SmartIsolateException(message.error.toString(), message.stack), message.stack);
        _processNextTask();
      }
    });

    try {
      _isolate = await Isolate.spawn<_ContinuousIsolatePayload<TArg, TResult>>(
        _continuousEntryPoint,
        _ContinuousIsolatePayload<TArg, TResult>(mainSendPort: _receivePort!.sendPort, initialize: initialize),
      );

      _isolateSendPort = await readyCompleter.future;
      _isRunning = true;
    } catch (e, stackTrace) {
      _tearDown();
      throw SmartIsolateException('Failed to spawn continuous isolate: $e', stackTrace);
    }
  }

  Future<TResult> execute(TArg arg, {WorkPriority priority = WorkPriority.medium}) async {
    if (!_isRunning || _isolateSendPort == null) {
      throw StateError('SmartIsolateContinuous is not running');
    }

    final taskId = _taskIdCounter++;
    final completer = Completer<TResult>();
    _pendingTasks[taskId] = completer;

    final queuedTask = _QueuedTask<TArg>(taskId, arg);

    // Add to appropriate priority queue
    switch (priority) {
      case WorkPriority.high:
        _highPriorityQueue.add(queuedTask);
        break;
      case WorkPriority.medium:
        _mediumPriorityQueue.add(queuedTask);
        break;
      case WorkPriority.low:
        _lowPriorityQueue.add(queuedTask);
        break;
    }

    _processNextTask();

    return completer.future;
  }

  void _processNextTask() {
    if (_isProcessingQueue || _isolateSendPort == null) return;

    _QueuedTask<TArg>? nextTask;

    // Process in priority order: high -> medium -> low
    if (_highPriorityQueue.isNotEmpty) {
      nextTask = _highPriorityQueue.removeFirst();
    } else if (_mediumPriorityQueue.isNotEmpty) {
      nextTask = _mediumPriorityQueue.removeFirst();
    } else if (_lowPriorityQueue.isNotEmpty) {
      nextTask = _lowPriorityQueue.removeFirst();
    }

    if (nextTask != null) {
      _isProcessingQueue = true;
      _isolateSendPort!.send(_ContinuousIsolateTask<TArg>(nextTask.taskId, nextTask.arg));
    } else {
      _isProcessingQueue = false;
    }
  }

  void kill() {
    if (_isRunning && _isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _tearDown();
    }
  }

  void dispose() {
    kill();
  }

  void _tearDown() {
    _isRunning = false;
    _portSubscription?.cancel();
    _receivePort?.close();
    _receivePort = null;
    _isolateSendPort = null;

    // Clear all queues
    _highPriorityQueue.clear();
    _mediumPriorityQueue.clear();
    _lowPriorityQueue.clear();

    for (final completer in _pendingTasks.values) {
      if (!completer.isCompleted) {
        completer.completeError(SmartIsolateException('Isolate was killed', null));
      }
    }
    _pendingTasks.clear();
  }

  static void _continuousEntryPoint<TArg, TResult>(_ContinuousIsolatePayload<TArg, TResult> payload) async {
    final receivePort = ReceivePort();
    payload.mainSendPort.send(receivePort.sendPort);

    late final void Function(TArg, void Function(TResult)) handler;

    try {
      await payload.initialize((TArg arg, void Function(TResult) respond) {
        handler = (TArg a, void Function(TResult) r) async {
          respond(r as TResult);
        };
      });
    } catch (e, st) {
      payload.mainSendPort.send(_ContinuousIsolateError(-1, e, st));
      return;
    }

    await for (final message in receivePort) {
      if (message is _ContinuousIsolateTask<TArg>) {
        try {
          final completer = Completer<TResult>();

          handler(message.arg, (TResult result) {
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          });

          final result = await completer.future;
          payload.mainSendPort.send(_ContinuousIsolateResult<TResult>(message.taskId, result));
        } catch (e, st) {
          payload.mainSendPort.send(_ContinuousIsolateError(message.taskId, e, st));
        }
      }
    }
  }
}

class SmartIsolateException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  SmartIsolateException(this.message, [this.stackTrace]);

  @override
  String toString() => 'SmartIsolateException: $message';
}

class _QueuedTask<TArg> {
  final int taskId;
  final TArg arg;

  _QueuedTask(this.taskId, this.arg);
}

class _SmartIsolatePayload<TArg, TProgress, TResult> {
  final TArg arg;
  final Future<TResult> Function(TArg arg, void Function(TProgress) emitProgress) task;
  final SendPort mainSendPort;

  _SmartIsolatePayload({required this.arg, required this.task, required this.mainSendPort});
}

class _SmartIsolateProgress<TProgress> {
  final TProgress data;
  _SmartIsolateProgress(this.data);
}

class _SmartIsolateResult<TResult> {
  final TResult data;
  _SmartIsolateResult(this.data);
}

class _SmartIsolateError {
  final Object error;
  final StackTrace stack;
  _SmartIsolateError(this.error, this.stack);
}

class _ContinuousIsolatePayload<TArg, TResult> {
  final SendPort mainSendPort;
  final Future<void> Function(void Function(TArg, void Function(TResult))) initialize;

  _ContinuousIsolatePayload({required this.mainSendPort, required this.initialize});
}

class _ContinuousIsolateTask<TArg> {
  final int taskId;
  final TArg arg;
  _ContinuousIsolateTask(this.taskId, this.arg);
}

class _ContinuousIsolateResult<TResult> {
  final int taskId;
  final TResult data;
  _ContinuousIsolateResult(this.taskId, this.data);
}

class _ContinuousIsolateError {
  final int taskId;
  final Object error;
  final StackTrace stack;
  _ContinuousIsolateError(this.taskId, this.error, this.stack);
}
