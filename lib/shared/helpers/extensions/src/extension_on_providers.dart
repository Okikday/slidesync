part of '../extensions.dart';

extension ProviderExtension<StateT> on ProviderListenable<StateT> {
  StateT read(WidgetRef ref) => ref.read<StateT>(this);
  StateT watch(WidgetRef ref) => ref.watch<StateT>(this);
  StateT readX(Ref ref) => ref.read<StateT>(this);
  StateT watchX(Ref ref) => ref.watch<StateT>(this);
}

extension AsyncProviderExtension<StateT> on AsyncProviderListenable<StateT> {
  AsyncValue<StateT> watch(WidgetRef ref) => ref.watch<AsyncValue<StateT>>(this);
  AsyncValue<StateT> read(WidgetRef ref) => ref.read<AsyncValue<StateT>>(this);
  AsyncValue<StateT> watchX(Ref ref) => ref.watch<AsyncValue<StateT>>(this);
  AsyncValue<StateT> readX(Ref ref) => ref.read<AsyncValue<StateT>>(this);
}

extension RefExtensions on Ref {
  void emptyListenMany(List<ProviderListenable> providers) {
    for (final p in providers) {
      listen(p, (_, __) {});
    }
  }

  void keepAliveFor(Duration duration) {
    final link = keepAlive();
    Timer? timer;

    onCancel(() => timer = Timer(duration, () => link.close()));
    onResume(() => timer?.cancel());
    onDispose(() => timer?.cancel());
  }
}

extension NotifierX<N extends Notifier<S>, S> on NotifierProvider<N, S> {
  N act(WidgetRef ref) => ref.read(notifier);
  N actX(Ref ref) => ref.read(notifier);

  N link(WidgetRef ref) => ref.watch(notifier);
  N linkX(Ref ref) => ref.watch(notifier);
}

extension AsyncNotifierX<N extends AsyncNotifier<S>, S> on AsyncNotifierProvider<N, S> {
  N act(WidgetRef ref) => ref.read(notifier);
  N actX(Ref ref) => ref.read(notifier);

  N link(WidgetRef ref) => ref.watch(notifier);
  N linkX(Ref ref) => ref.watch(notifier);
}
