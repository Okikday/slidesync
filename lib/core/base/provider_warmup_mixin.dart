import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

mixin ProviderWarmupMixin {
  /// The Hub using this mixin must provide its Ref
  Ref get ref;

  final Map<ProviderListenable, ProviderSubscription> _subscriptions = {};
  final Map<ProviderListenable, Timer> _timers = {};

  /// Warms up a provider. If already warming, it resets the expiration timer.
  void warmUp(ProviderListenable provider, {Duration? duration}) {
    // 1. Ensure the provider is subscribed to (keeps it alive)
    _subscriptions.putIfAbsent(provider, () => ref.listen(provider, (_, _) {}));

    // 2. Handle the timer logic (The "Heartbeat" update)
    _timers[provider]?.cancel(); // Cancel existing timer if any

    if (duration != null) {
      _timers[provider] = Timer(duration, () => clearWarmUp(provider));
    } else {
      _timers.remove(provider); // Make it permanent if duration is null
    }
  }

  /// Forces the provider to follow its standard autoDispose rules again
  void clearWarmUp(ProviderListenable provider) {
    _timers.remove(provider)?.cancel();
    _subscriptions.remove(provider)?.close();
  }

  /// Clean up everything (useful for Hub disposal or Logout)
  void clearAllWarmUps() {
    for (final p in _subscriptions.keys.toList()) {
      clearWarmUp(p);
    }
  }
}
