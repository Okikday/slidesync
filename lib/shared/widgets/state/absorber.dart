import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

typedef AbsorberBuilder<OutT> = Widget Function(BuildContext context, OutT value, WidgetRef ref, Widget? _);

class Absorber {
  static Widget watch<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required AbsorberBuilder<OutT> builder,
    Widget? child,
  }) => AbsorberWatch(key: key, listenable: listenable, builder: builder, child: child);

  static Widget read<OutT>(
    ProviderListenable<OutT> listenable, {
    Key? key,
    required AbsorberBuilder<OutT> builder,
    Widget? child,
  }) => AbsorberRead(key: key, listenable: listenable, builder: builder, child: child);

  static Widget readValueNotifier<OutT>(
    ProviderListenable<ValueNotifier<OutT>> listenable, {
    Key? key,
    required AbsorberBuilder<OutT> builder,
    Widget? innerChild,
    Widget? outerChild,
  }) {
    return AbsorberValueNotifier<OutT>(
      key: key,
      listenable: listenable,
      builder: builder,
      outerChild: outerChild,
      innerChild: innerChild,
      watchNotRead: false,
    );
  }

  static Widget watchValueNotifier<OutT>(
    ProviderListenable<ValueNotifier<OutT>> listenable, {
    Key? key,
    required AbsorberBuilder<OutT> builder,
    Widget? innerChild,
    Widget? outerChild,
  }) {
    return AbsorberValueNotifier<OutT>(
      key: key,
      listenable: listenable,
      builder: builder,
      outerChild: outerChild,
      innerChild: innerChild,
      watchNotRead: true,
    );
  }
}

/// Watches the Provider supplied
class AbsorberWatch<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final AbsorberBuilder<OutT> builder;
  final Widget? child;
  const AbsorberWatch({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(listenable);
    return builder(context, value, ref, child);
  }
}

/// Reads the Provider supplied
class AbsorberRead<OutT> extends ConsumerWidget {
  final ProviderListenable<OutT> listenable;
  final AbsorberBuilder<OutT> builder;
  final Widget? child;
  const AbsorberRead({super.key, required this.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.read(listenable);
    return builder(context, value, ref, child);
  }
}

/// Reads or watches the Provider as ValueNotifier when supplied
class AbsorberValueNotifier<OutT> extends ConsumerWidget {
  final ProviderListenable<ValueNotifier<OutT>> listenable;
  final AbsorberBuilder<OutT> builder;
  final Widget? innerChild;
  final Widget? outerChild;

  /// Will [watch] when true, [read] when false
  final bool watchNotRead;
  const AbsorberValueNotifier({
    super.key,
    required this.listenable,
    required this.builder,
    this.innerChild,
    this.outerChild,
    this.watchNotRead = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (watchNotRead) {
      return AbsorberWatch<ValueNotifier<OutT>>(
        listenable: listenable,
        builder: (context, valueListenable, ref, child) => ValueListenableBuilder<OutT>(
          valueListenable: valueListenable,
          builder: (c, v, i) => builder(c, v, ref, i),
          child: innerChild,
        ),
        child: outerChild,
      );
    }
    return AbsorberRead<ValueNotifier<OutT>>(
      listenable: listenable,
      builder: (context, valueListenable, ref, child) => ValueListenableBuilder<OutT>(
        valueListenable: valueListenable,
        builder: (c, v, i) => builder(c, v, ref, i),
        child: innerChild,
      ),
      child: outerChild,
    );
  }
}
