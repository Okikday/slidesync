import 'dart:developer';

/// Desist from using Riverpod Providers in the class extending this
abstract class LeakPrevention {
  static final Finalizer<String> _finalizer = Finalizer<String>(
    (hashCode) => log(' #$hashCode was not disposed!', level: 900),
  );

  LeakPrevention() {
    _finalizer.attach(this, hashCode.toString(), detach: this);
  }

  void dispose() {
    _finalizer.detach(this);
    onDispose();
  }

  void onDispose();
}
