import 'package:flutter/material.dart';

class FadeForwardsPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Constructs a page transition animation that matches the transition used on
  /// Android U.
  const FadeForwardsPageTransitionsBuilder({this.backgroundColor});

  /// The background color during transition between two routes.
  ///
  /// When a new page fades in and the old page fades out, this background color
  /// helps avoid a black background between two page.
  ///
  /// Defaults to [ColorScheme.surface]
  final Color? backgroundColor;

  /// The value of [transitionDuration] in milliseconds.
  ///
  /// Eyeballed on a physical Pixel 9 running Android 16. This does not match
  /// the actual value used by native Android, which is 800ms, because native
  /// Android is using Material 3 Expressive springs that are not currently
  /// supported by Flutter. So for now at least, this is an approximation.
  static const int kTransitionMilliseconds = 450;

  @override
  Duration get transitionDuration => const Duration(milliseconds: kTransitionMilliseconds);

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        bool allowSnapshotting,
        Widget? child,
      ) => _delegatedTransition(context, secondaryAnimation, backgroundColor, child);

  // Used by all of the sliding transition animations.
  static const Curve _transitionCurve = Curves.easeInOutCubicEmphasized;

  // The previous page slides from right to left as the current page appears.
  static final Animatable<Offset> _secondaryBackwardTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.25, 0.0),
  ).chain(CurveTween(curve: _transitionCurve));

  // The previous page slides from left to right as the current page disappears.
  static final Animatable<Offset> _secondaryForwardTranslationTween = Tween<Offset>(
    begin: const Offset(-0.25, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: _transitionCurve));

  // The fade in transition when the new page appears.
  static final Animatable<double> _fadeInTransition = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: const Interval(0.0, 0.75)));

  // The fade out transition of the old page when the new page appears.
  static final Animatable<double> _fadeOutTransition = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).chain(CurveTween(curve: const Interval(0.0, 0.25)));

  static Widget _delegatedTransition(
    BuildContext context,
    Animation<double> secondaryAnimation,
    Color? backgroundColor,
    Widget? child,
  ) {
    final Widget builder = DualTransitionBuilder(
      animation: ReverseAnimation(secondaryAnimation),
      forwardBuilder: (BuildContext context, Animation<double> animation, Widget? child) {
        return FadeTransition(
          opacity: _fadeInTransition.animate(animation),
          child: SlideTransition(position: _secondaryForwardTranslationTween.animate(animation), child: child),
        );
      },
      reverseBuilder: (BuildContext context, Animation<double> animation, Widget? child) {
        return FadeTransition(
          opacity: _fadeOutTransition.animate(animation),
          child: SlideTransition(position: _secondaryBackwardTranslationTween.animate(animation), child: child),
        );
      },
      child: child,
    );

    final bool isOpaque = ModalRoute.opaqueOf(context) ?? true;

    if (!isOpaque) {
      return builder;
    }

    return ColoredBox(
      color: secondaryAnimation.isAnimating ? backgroundColor ?? ColorScheme.of(context).surface : Colors.transparent,
      child: builder,
    );
  }

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _FadeForwardsPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}

// This transition slides a new page in from right to left while fading it in,
// and simultaneously slides the previous page out to the left while fading it out.
// This transition is designed to match the Android U activity transition.
class _FadeForwardsPageTransition extends StatelessWidget {
  const _FadeForwardsPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    this.backgroundColor,
    this.child,
  });

  final Animation<double> animation;

  final Animation<double> secondaryAnimation;

  final Color? backgroundColor;

  final Widget? child;

  // The new page slides in from right to left.
  static final Animatable<Offset> _forwardTranslationTween = Tween<Offset>(
    begin: const Offset(0.25, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: FadeForwardsPageTransitionsBuilder._transitionCurve));

  // The old page slides back from left to right.
  static final Animatable<Offset> _backwardTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.25, 0.0),
  ).chain(CurveTween(curve: FadeForwardsPageTransitionsBuilder._transitionCurve));

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (BuildContext context, Animation<double> animation, Widget? child) {
        return FadeTransition(
          opacity: FadeForwardsPageTransitionsBuilder._fadeInTransition.animate(animation),
          child: SlideTransition(position: _forwardTranslationTween.animate(animation), child: child),
        );
      },
      reverseBuilder: (BuildContext context, Animation<double> animation, Widget? child) {
        return IgnorePointer(
          ignoring: animation.status == AnimationStatus.forward,
          child: FadeTransition(
            opacity: FadeForwardsPageTransitionsBuilder._fadeOutTransition.animate(animation),
            child: SlideTransition(position: _backwardTranslationTween.animate(animation), child: child),
          ),
        );
      },
      child: FadeForwardsPageTransitionsBuilder._delegatedTransition(
        context,
        secondaryAnimation,
        backgroundColor,
        child,
      ),
    );
  }
}
