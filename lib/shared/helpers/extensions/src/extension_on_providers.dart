part of '../extensions.dart';

extension ProviderExtension<StateT> on ProviderListenable<StateT> {
  StateT read(WidgetRef ref) => ref.read<StateT>(this);
  StateT watch(WidgetRef ref) => ref.watch<StateT>(this);
}
