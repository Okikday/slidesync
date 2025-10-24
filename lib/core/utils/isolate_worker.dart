// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:worker_manager/worker_manager.dart';

// class IsolateWorker {
//   static IsolateWorker? _instance;
//   static bool _isInitialized = false;

//   int? _totalIsolates;
//   int? _workerIsolates;

//   IsolateWorker._();

//   static IsolateWorker get instance {
//     _instance ??= IsolateWorker._();
//     return _instance!;
//   }

//   static Future<void> init({bool enableLogging = false, bool dynamicSpawn = false}) async {
//     if (_isInitialized) return;

//     final worker = IsolateWorker.instance;

//     int processorCount = 2;
//     try {
//       if (!kIsWeb) {
//         processorCount = Platform.numberOfProcessors;
//       }
//     } catch (_) {}

//     worker._totalIsolates = (processorCount - 1).clamp(1, 2);
//     worker._workerIsolates = worker._totalIsolates! - 1;

//     workerManager.log = enableLogging;
//     await workerManager.init(dynamicSpawning: dynamicSpawn, isolatesCount: worker._totalIsolates);

//     _isInitialized = true;
//   }

//   static Cancelable<T> execute<T>(Execute<T> task, {WorkPriority priority = WorkPriority.regular}) {
//     _ensureInitialized();
//     return workerManager.execute<T>(task, priority: priority);
//   }

//   static Cancelable<T> executeGentle<T>(ExecuteGentle<T> task, {WorkPriority priority = WorkPriority.regular}) {
//     _ensureInitialized();
//     return workerManager.executeGentle<T>(task, priority: priority);
//   }

//   static Cancelable<T> executeWithPort<T, M>(
//     ExecuteWithPort<T> task, {
//     required void Function(M message) onMessage,
//     WorkPriority priority = WorkPriority.regular,
//   }) {
//     _ensureInitialized();
//     return workerManager.executeWithPort<T, M>(task, onMessage: onMessage, priority: priority);
//   }

//   static Cancelable<T> executeGentleWithPort<T, M>(
//     ExecuteGentleWithPort<T> task, {
//     required void Function(M message) onMessage,
//     WorkPriority priority = WorkPriority.regular,
//   }) {
//     _ensureInitialized();
//     return workerManager.executeGentleWithPort<T, M>(task, onMessage: onMessage, priority: priority);
//   }

//   static Cancelable<T> executeOnMainIsolate<T>(Execute<T> task) {
//     _ensureInitialized();
//     return workerManager.execute<T>(task, priority: WorkPriority.immediately);
//   }

//   static IsolateInfo getInfo() {
//     return IsolateInfo(
//       totalIsolates: instance._totalIsolates ?? 0,
//       workerIsolates: instance._workerIsolates ?? 0,
//       artificialMainIsolates: 1,
//       isInitialized: _isInitialized,
//     );
//   }

//   static Future<void> dispose() async {
//     if (!_isInitialized) return;
//     await workerManager.dispose();
//     _isInitialized = false;
//     _instance = null;
//   }

//   static void _ensureInitialized() {
//     if (!_isInitialized) {
//       throw StateError('IsolateWorker not initialized. Call IsolateWorker.init() first.');
//     }
//   }
// }

// class IsolateInfo {
//   final int totalIsolates;
//   final int workerIsolates;
//   final int artificialMainIsolates;
//   final bool isInitialized;

//   IsolateInfo({
//     required this.totalIsolates,
//     required this.workerIsolates,
//     required this.artificialMainIsolates,
//     required this.isInitialized,
//   });

//   @override
//   String toString() {
//     return 'IsolateInfo(total: $totalIsolates, workers: $workerIsolates, artificial: $artificialMainIsolates, initialized: $isInitialized)';
//   }
// }
