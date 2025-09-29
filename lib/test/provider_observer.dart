// lib/utils/active_provider_observer.dart
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Per-instance info recorded for each provider object.
class ActiveProviderInfo {
  final ProviderBase provider;
  int createCount = 0;
  int disposeCount = 0;
  DateTime? lastAddedAt;
  DateTime? lastDisposedAt;
  Duration cumulativeActiveDuration = Duration.zero;

  ActiveProviderInfo(this.provider);

  bool get isActive => lastAddedAt != null && (lastDisposedAt == null || lastAddedAt!.isAfter(lastDisposedAt!));

  void recordAdd(DateTime at) {
    createCount++;
    lastAddedAt = at;
  }

  void recordDispose(DateTime at) {
    disposeCount++;
    lastDisposedAt = at;
    if (lastAddedAt != null) {
      final dur = at.difference(lastAddedAt!);
      cumulativeActiveDuration += dur.isNegative ? Duration.zero : dur;
    }
  }

  Duration get averageLifetime {
    final events = disposeCount == 0 ? 1 : disposeCount;
    return Duration(milliseconds: (cumulativeActiveDuration.inMilliseconds / events).round());
  }

  @override
  String toString() {
    final name = provider.toString();
    return '$name | active: $isActive | adds: $createCount | disposes: $disposeCount | avgLifetime: ${averageLifetime.inMilliseconds}ms';
  }
}

/// Aggregated stats by provider "key" (usually provider type/name without the instance hash).
class AggregateInfo {
  final String key;
  int adds = 0;
  int disposes = 0;

  AggregateInfo(this.key);

  int get activeInstances => adds - disposes;

  @override
  String toString() => '$key | adds: $adds | disposes: $disposes | active: $activeInstances';
}

/// Observer that tracks active provider instances and global totals.
base class ActiveProvidersObserver extends ProviderObserver {
  final int historyLimit;

  // per-instance data
  final Map<ProviderBase, ActiveProviderInfo> _info = {};
  final LinkedHashSet<ProviderBase> _order = LinkedHashSet();

  // aggregated by provider kind
  final Map<String, AggregateInfo> _aggregates = {};

  // Live notifiers you can bind to UI / debugger
  final ValueNotifier<int> currentActiveInstances = ValueNotifier<int>(0);
  final ValueNotifier<int> cumulativeAdds = ValueNotifier<int>(0);
  final ValueNotifier<int> cumulativeDisposes = ValueNotifier<int>(0);
  final ValueNotifier<List<String>> aggregateSummaries = ValueNotifier<List<String>>([]);

  ActiveProvidersObserver({this.historyLimit = 2000});

  // --- snapshots / helpers ---
  int get activeProvidersCount => _info.values.where((i) => i.isActive).length;
  List<ActiveProviderInfo> get activeProviders => _info.values.where((i) => i.isActive).toList(growable: false);
  List<ActiveProviderInfo> get allTracked => List.unmodifiable(_info.values);
  Map<String, AggregateInfo> get aggregates => Map.unmodifiable(_aggregates);

  int get totalAdds => _aggregates.values.fold(0, (s, a) => s + a.adds);
  int get totalDisposes => _aggregates.values.fold(0, (s, a) => s + a.disposes);
  int get aggregatedActiveCount => _aggregates.values.fold(0, (s, a) => s + a.activeInstances);

  // create a grouping key (strip the trailing '#hash' to group same provider kinds)
  String _providerKey(ProviderBase provider) {
    final name = provider.toString();
    final withoutHash = name.replaceAll(RegExp(r'#([a-f0-9]+)$'), '');
    return withoutHash;
  }

  AggregateInfo _ensureAggregate(String key) => _aggregates.putIfAbsent(key, () => AggregateInfo(key));
  ActiveProviderInfo _ensureInfo(ProviderBase provider) =>
      _info.putIfAbsent(provider, () => ActiveProviderInfo(provider));

  void _touchProvider(ProviderBase provider) {
    _order.remove(provider);
    _order.add(provider);

    if (_order.length > historyLimit) {
      final toRemove = _order.first;
      _order.remove(toRemove);
      _info.remove(toRemove);
    }

    // update notifiers
    currentActiveInstances.value = activeProvidersCount;
    aggregateSummaries.value = _aggregates.values.map((a) => a.toString()).toList(growable: false);
  }

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    final p = context.provider as ProviderBase;
    final info = _ensureInfo(p);

    final wasActiveBefore = info.isActive;
    info.recordAdd(DateTime.now());
    final becameActive = !wasActiveBefore && info.isActive;

    // update aggregate
    final key = _providerKey(p);
    final agg = _ensureAggregate(key);
    agg.adds++;

    // If this instance became active now, increment the global currentActiveInstances and cumulativeAdds
    if (becameActive) {
      // cumulativeAdds is the running count of instance activations
      cumulativeAdds.value = cumulativeAdds.value + 1;
    }

    _touchProvider(p);

    dev.log(
      'Provider ADD: $p  (instance adds: ${info.createCount})  aggregated adds: ${agg.adds}  '
      'currentActiveInstances: ${currentActiveInstances.value}  cumulativeAdds: ${cumulativeAdds.value}',
      name: 'ActiveProvidersObserver',
    );
  }

  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    // Optional: measure size or value changes here if you want
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    final p = context.provider as ProviderBase;
    final info = _ensureInfo(p);

    final wasActiveBefore = info.isActive;
    info.recordDispose(DateTime.now());
    final becameInactive = wasActiveBefore && !info.isActive;

    // update aggregate
    final key = _providerKey(p);
    final agg = _ensureAggregate(key);
    agg.disposes++;

    // If this instance transitioned from active -> inactive, decrement currentActiveInstances and increment cumulative disposes
    if (becameInactive) {
      cumulativeDisposes.value = cumulativeDisposes.value + 1;
    }

    // Recompute currentActiveInstances via notifiers in _touchProvider
    _touchProvider(p);

    dev.log(
      'Provider DISPOSE: $p  (instance disposes: ${info.disposeCount})  aggregated disposes: ${agg.disposes}  '
      'currentActiveInstances: ${currentActiveInstances.value}  cumulativeDisposes: ${cumulativeDisposes.value}',
      name: 'ActiveProvidersObserver',
    );
  }

  /// Clear stored stats (history and aggregates).
  void clearStats() {
    _info.clear();
    _order.clear();
    _aggregates.clear();
    currentActiveInstances.value = 0;
    cumulativeAdds.value = 0;
    cumulativeDisposes.value = 0;
    aggregateSummaries.value = [];
  }

  /// Quick summary for debugging.
  String quickSummary({int topN = 10}) {
    final active = activeProvidersCount;
    final tracked = _info.length;
    final aggActive = aggregatedActiveCount;
    final top = _aggregates.values.toList()..sort((a, b) => b.adds.compareTo(a.adds));
    final topStr = top.take(topN).map((a) => a.toString()).join('\n');
    return 'Instance active: $active | Aggregated active: $aggActive | Tracked instances: $tracked '
        '| cumulativeAdds: ${cumulativeAdds.value} | cumulativeDisposes: ${cumulativeDisposes.value}\nTop aggregates:\n$topStr';
  }
}
