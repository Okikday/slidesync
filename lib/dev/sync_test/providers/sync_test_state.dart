import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncTestLog {
  final String id;
  final String message;
  final DateTime timestamp;
  final SyncLogLevel level;

  SyncTestLog({required this.id, required this.message, required this.timestamp, required this.level});
}

enum SyncLogLevel { info, success, warning, error }

class SyncTestState {
  final List<SyncTestLog> logs;
  final bool isSyncing;
  final double? uploadProgress;
  final String? currentOperation;
  final int totalOperations;
  final int completedOperations;

  const SyncTestState({
    this.logs = const [],
    this.isSyncing = false,
    this.uploadProgress,
    this.currentOperation,
    this.totalOperations = 0,
    this.completedOperations = 0,
  });

  SyncTestState copyWith({
    List<SyncTestLog>? logs,
    bool? isSyncing,
    double? uploadProgress,
    String? currentOperation,
    int? totalOperations,
    int? completedOperations,
  }) {
    return SyncTestState(
      logs: logs ?? this.logs,
      isSyncing: isSyncing ?? this.isSyncing,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      currentOperation: currentOperation ?? this.currentOperation,
      totalOperations: totalOperations ?? this.totalOperations,
      completedOperations: completedOperations ?? this.completedOperations,
    );
  }
}

class SyncTestNotifier extends Notifier<SyncTestState> {
  @override
  SyncTestState build() {
    return const SyncTestState();
  }

  void addLog(String message, SyncLogLevel level) {
    final log = SyncTestLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      timestamp: DateTime.now(),
      level: level,
    );
    state = state.copyWith(logs: [...state.logs, log]);
  }

  void info(String message) => addLog(message, SyncLogLevel.info);
  void success(String message) => addLog(message, SyncLogLevel.success);
  void warning(String message) => addLog(message, SyncLogLevel.warning);
  void error(String message) => addLog(message, SyncLogLevel.error);

  void setSyncing(bool value, {String? operation, int? total}) {
    state = state.copyWith(
      isSyncing: value,
      currentOperation: operation ?? state.currentOperation,
      totalOperations: total ?? state.totalOperations,
    );
  }

  void setProgress(double? progress) {
    state = state.copyWith(uploadProgress: progress);
  }

  void incrementCompleted() {
    state = state.copyWith(completedOperations: state.completedOperations + 1);
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  void reset() {
    state = const SyncTestState();
  }
}

class SyncTestProvider {
  static final state = NotifierProvider<SyncTestNotifier, SyncTestState>(SyncTestNotifier.new);
}
