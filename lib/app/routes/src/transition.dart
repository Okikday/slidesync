import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';

const _defaultCurve = Cubic(0.22, 0.25, 0.00, 1.00);
const defaultCurve = _defaultCurve;
dynamic defaultTransition(
  LocalKey pageKey, {
  required Widget child,
  TransitionType defaultIncoming = TransitionType.rightToLeft,
  TransitionType? outgoing,
  Duration incomingDuration = const Duration(milliseconds: 400),
  Duration outgoingDuration = const Duration(milliseconds: 200),
}) {
  return PageAnimation.buildCustomTransitionPage(
    pageKey,
    type: TransitionType.paired(
      incoming: defaultIncoming,
      outgoing: outgoing ?? TransitionType.slide(begin: const Offset(0, 0), end: const Offset(-0.4, 0)),
      outgoingDuration: incomingDuration,
      reverseDuration: outgoingDuration,
      // curve: CustomCurves.defaultIosSpring,
      // reverseCurve: CustomCurves.defaultIosSpring,
      curve: defaultCurve,
      reverseCurve: defaultCurve,
    ),

    // duration: Durations.extralong2,
    // duration: incomingDuration,
    // reverseDuration: outgoingDuration,
    child: child,
  );
}
