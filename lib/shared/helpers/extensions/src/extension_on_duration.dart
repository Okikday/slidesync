part of '../extensions.dart';

extension ExtensionOnDuration on Duration {
  Future<void> delay([FutureOr<void> Function()? computation]) => Future.delayed(this, computation);
}
