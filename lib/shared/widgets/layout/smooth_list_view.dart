// ============================================================================
// src/smooth_list_view_base.dart
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

/// Defines when smooth scrolling should be applied
enum SmoothScrollMode {
  /// Automatically enable smooth scroll on desktop platforms only
  auto,

  /// Disable smooth scroll on all platforms (use native scrolling)
  disabled,
}

/// Defines the intensity/feel of the smooth scrolling
enum ScrollIntensity {
  /// Smooth, longer momentum (macOS-like feel)
  slow,

  /// Balanced momentum (Windows-like feel)
  medium,

  /// Snappier, shorter momentum
  fast,
}

/// A ListView that provides buttery-smooth scrolling on desktop platforms
/// while maintaining native scroll behavior on mobile.
///
/// This widget wraps Flutter's standard ListView and adds:
/// - Continuous frame-by-frame scroll updates (no lag/freeze)
/// - Platform-tuned momentum physics
/// - Immediate response to scroll input
///
/// On mobile platforms, it behaves exactly like a standard ListView with
/// zero performance overhead.
///
/// Example:
/// ```dart
/// SmoothListView.builder(
///   itemCount: 100,
///   itemBuilder: (context, index) => ListTile(
///     title: Text('Item $index'),
///   ),
/// )
/// ```
class SmoothListView extends StatelessWidget {
  /// The mode determining when smooth scroll is applied
  final SmoothScrollMode mode;

  /// The intensity/feel of the scrolling
  final ScrollIntensity intensity;

  /// Custom physics for power users (overrides intensity)
  final SmoothScrollPhysics? customPhysics;

  // Standard ListView parameters
  final List<Widget> children;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final Clip clipBehavior;
  final ScrollController? controller;
  final DragStartBehavior dragStartBehavior;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget? prototypeItem;
  final String? restorationId;
  final bool reverse;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;

  const SmoothListView({
    super.key,
    required this.children,
    this.mode = SmoothScrollMode.auto,
    this.intensity = ScrollIntensity.slow,
    this.customPhysics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.itemExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.padding,
    this.physics,
    this.primary,
    this.prototypeItem,
    this.restorationId,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.semanticChildCount,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final shouldApplySmooth = _shouldApplySmoothScroll();

    if (!shouldApplySmooth) {
      // Mobile or disabled: return plain ListView with zero overhead
      return ListView(
        key: key,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: cacheExtent,
        clipBehavior: clipBehavior,
        controller: controller,
        dragStartBehavior: dragStartBehavior,
        itemExtent: itemExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        padding: padding,
        physics: physics,
        primary: primary,
        prototypeItem: prototypeItem,
        restorationId: restorationId,
        reverse: reverse,
        scrollDirection: scrollDirection,
        semanticChildCount: semanticChildCount,
        shrinkWrap: shrinkWrap,
        children: children,
      );
    }

    // Desktop: apply smooth scroll
    return _SmoothListViewWrapper(
      key: key,
      mode: mode,
      intensity: intensity,
      customPhysics: customPhysics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      itemExtent: itemExtent,
      keyboardDismissBehavior: keyboardDismissBehavior,
      padding: padding,
      physics: physics,
      primary: primary,
      prototypeItem: prototypeItem,
      restorationId: restorationId,
      reverse: reverse,
      scrollDirection: scrollDirection,
      semanticChildCount: semanticChildCount,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }

  /// Builder constructor for dynamic lists
  static Widget builder({
    Key? key,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    SmoothScrollMode mode = SmoothScrollMode.auto,
    ScrollIntensity intensity = ScrollIntensity.slow,
    SmoothScrollPhysics? customPhysics,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ChildIndexGetter? findChildIndexCallback,
    double? itemExtent,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool? primary,
    Widget? prototypeItem,
    String? restorationId,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    int? semanticChildCount,
    bool shrinkWrap = false,
  }) {
    final shouldApplySmooth = _shouldApplySmoothScrollStatic(mode);

    if (!shouldApplySmooth) {
      return ListView.builder(
        key: key,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: cacheExtent,
        clipBehavior: clipBehavior,
        controller: controller,
        dragStartBehavior: dragStartBehavior,
        findChildIndexCallback: findChildIndexCallback,
        itemExtent: itemExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        padding: padding,
        physics: physics,
        primary: primary,
        prototypeItem: prototypeItem,
        restorationId: restorationId,
        reverse: reverse,
        scrollDirection: scrollDirection,
        semanticChildCount: semanticChildCount,
        shrinkWrap: shrinkWrap,
      );
    }

    return _SmoothListViewBuilder(
      key: key,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      mode: mode,
      intensity: intensity,
      customPhysics: customPhysics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      findChildIndexCallback: findChildIndexCallback,
      itemExtent: itemExtent,
      keyboardDismissBehavior: keyboardDismissBehavior,
      padding: padding,
      physics: physics,
      primary: primary,
      prototypeItem: prototypeItem,
      restorationId: restorationId,
      reverse: reverse,
      scrollDirection: scrollDirection,
      semanticChildCount: semanticChildCount,
      shrinkWrap: shrinkWrap,
    );
  }

  /// Separated constructor for lists with separators
  static Widget separated({
    Key? key,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    SmoothScrollMode mode = SmoothScrollMode.auto,
    ScrollIntensity intensity = ScrollIntensity.slow,
    SmoothScrollPhysics? customPhysics,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ChildIndexGetter? findChildIndexCallback,
    double? itemExtent,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool? primary,
    Widget? prototypeItem,
    String? restorationId,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    int? semanticChildCount,
    bool shrinkWrap = false,
  }) {
    final shouldApplySmooth = _shouldApplySmoothScrollStatic(mode);

    if (!shouldApplySmooth) {
      return ListView.separated(
        key: key,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        itemCount: itemCount,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: cacheExtent,
        clipBehavior: clipBehavior,
        controller: controller,
        dragStartBehavior: dragStartBehavior,
        findChildIndexCallback: findChildIndexCallback,
        keyboardDismissBehavior: keyboardDismissBehavior,
        padding: padding,
        physics: physics,
        primary: primary,
        restorationId: restorationId,
        reverse: reverse,
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
      );
    }

    return _SmoothListViewSeparated(
      key: key,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      itemCount: itemCount,
      mode: mode,
      intensity: intensity,
      customPhysics: customPhysics,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      findChildIndexCallback: findChildIndexCallback,
      itemExtent: itemExtent,
      keyboardDismissBehavior: keyboardDismissBehavior,
      padding: padding,
      physics: physics,
      primary: primary,
      prototypeItem: prototypeItem,
      restorationId: restorationId,
      reverse: reverse,
      scrollDirection: scrollDirection,
      semanticChildCount: semanticChildCount,
      shrinkWrap: shrinkWrap,
    );
  }

  /// Custom constructor for advanced use cases
  static Widget custom({
    Key? key,
    required SliverChildDelegate childrenDelegate,
    SmoothScrollMode mode = SmoothScrollMode.auto,
    ScrollIntensity intensity = ScrollIntensity.slow,
    SmoothScrollPhysics? customPhysics,
    double? cacheExtent,
    Clip clipBehavior = Clip.hardEdge,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double? itemExtent,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool? primary,
    Widget? prototypeItem,
    String? restorationId,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    int? semanticChildCount,
    bool shrinkWrap = false,
  }) {
    final shouldApplySmooth = _shouldApplySmoothScrollStatic(mode);

    if (!shouldApplySmooth) {
      return ListView.custom(
        key: key,
        childrenDelegate: childrenDelegate,
        cacheExtent: cacheExtent,
        clipBehavior: clipBehavior,
        controller: controller,
        dragStartBehavior: dragStartBehavior,
        itemExtent: itemExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        padding: padding,
        physics: physics,
        primary: primary,
        prototypeItem: prototypeItem,
        restorationId: restorationId,
        reverse: reverse,
        scrollDirection: scrollDirection,
        semanticChildCount: semanticChildCount,
        shrinkWrap: shrinkWrap,
      );
    }

    return _SmoothListViewCustom(
      key: key,
      childrenDelegate: childrenDelegate,
      mode: mode,
      intensity: intensity,
      customPhysics: customPhysics,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      itemExtent: itemExtent,
      keyboardDismissBehavior: keyboardDismissBehavior,
      padding: padding,
      physics: physics,
      primary: primary,
      prototypeItem: prototypeItem,
      restorationId: restorationId,
      reverse: reverse,
      scrollDirection: scrollDirection,
      semanticChildCount: semanticChildCount,
      shrinkWrap: shrinkWrap,
    );
  }

  bool _shouldApplySmoothScroll() {
    return _shouldApplySmoothScrollStatic(mode);
  }

  static bool _shouldApplySmoothScrollStatic(SmoothScrollMode mode) {
    if (mode == SmoothScrollMode.disabled) return false;

    return defaultTargetPlatform == TargetPlatform.windows;
  }
}

// ============================================================================
// Internal Wrapper Widgets
// ============================================================================

class _SmoothListViewWrapper extends StatefulWidget {
  final SmoothScrollMode mode;
  final ScrollIntensity intensity;
  final SmoothScrollPhysics? customPhysics;
  final List<Widget> children;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final Clip clipBehavior;
  final ScrollController? controller;
  final DragStartBehavior dragStartBehavior;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget? prototypeItem;
  final String? restorationId;
  final bool reverse;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;

  const _SmoothListViewWrapper({
    super.key,
    required this.mode,
    required this.intensity,
    required this.customPhysics,
    required this.children,
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.addSemanticIndexes,
    required this.cacheExtent,
    required this.clipBehavior,
    required this.controller,
    required this.dragStartBehavior,
    required this.itemExtent,
    required this.keyboardDismissBehavior,
    required this.padding,
    required this.physics,
    required this.primary,
    required this.prototypeItem,
    required this.restorationId,
    required this.reverse,
    required this.scrollDirection,
    required this.semanticChildCount,
    required this.shrinkWrap,
  });

  @override
  State<_SmoothListViewWrapper> createState() => _SmoothListViewWrapperState();
}

class _SmoothListViewWrapperState extends State<_SmoothListViewWrapper> with SingleTickerProviderStateMixin {
  late SmoothScrollController _smoothController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _smoothController = SmoothScrollController(
      scrollController: _scrollController,
      intensity: widget.intensity,
      customPhysics: widget.customPhysics,
      reverse: widget.reverse,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_SmoothListViewWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intensity != oldWidget.intensity ||
        widget.customPhysics != oldWidget.customPhysics ||
        widget.reverse != oldWidget.reverse) {
      _smoothController.updateConfig(
        intensity: widget.intensity,
        customPhysics: widget.customPhysics,
        reverse: widget.reverse,
      );
    }
  }

  @override
  void dispose() {
    _smoothController.dispose();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.customPhysics ?? SmoothScrollPhysics.fromIntensity(widget.intensity, widget.physics);

    return Listener(
      onPointerSignal: _smoothController.handlePointerSignal,
      child: ListView(
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        controller: _scrollController,
        dragStartBehavior: widget.dragStartBehavior,
        itemExtent: widget.itemExtent,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        padding: widget.padding,
        physics: physics,
        primary: widget.primary,
        prototypeItem: widget.prototypeItem,
        restorationId: widget.restorationId,
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        semanticChildCount: widget.semanticChildCount,
        shrinkWrap: widget.shrinkWrap,
        children: widget.children,
      ),
    );
  }
}

class _SmoothListViewBuilder extends StatefulWidget {
  final SmoothScrollMode mode;
  final ScrollIntensity intensity;
  final SmoothScrollPhysics? customPhysics;
  final IndexedWidgetBuilder itemBuilder;
  final int? itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final Clip clipBehavior;
  final ScrollController? controller;
  final DragStartBehavior dragStartBehavior;
  final ChildIndexGetter? findChildIndexCallback;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget? prototypeItem;
  final String? restorationId;
  final bool reverse;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;

  const _SmoothListViewBuilder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.mode,
    required this.intensity,
    required this.customPhysics,
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.addSemanticIndexes,
    required this.cacheExtent,
    required this.clipBehavior,
    required this.controller,
    required this.dragStartBehavior,
    required this.findChildIndexCallback,
    required this.itemExtent,
    required this.keyboardDismissBehavior,
    required this.padding,
    required this.physics,
    required this.primary,
    required this.prototypeItem,
    required this.restorationId,
    required this.reverse,
    required this.scrollDirection,
    required this.semanticChildCount,
    required this.shrinkWrap,
  });

  @override
  State<_SmoothListViewBuilder> createState() => _SmoothListViewBuilderState();
}

class _SmoothListViewBuilderState extends State<_SmoothListViewBuilder> with SingleTickerProviderStateMixin {
  late SmoothScrollController _smoothController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _smoothController = SmoothScrollController(
      scrollController: _scrollController,
      intensity: widget.intensity,
      customPhysics: widget.customPhysics,
      reverse: widget.reverse,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_SmoothListViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intensity != oldWidget.intensity ||
        widget.customPhysics != oldWidget.customPhysics ||
        widget.reverse != oldWidget.reverse) {
      _smoothController.updateConfig(
        intensity: widget.intensity,
        customPhysics: widget.customPhysics,
        reverse: widget.reverse,
      );
    }
  }

  @override
  void dispose() {
    _smoothController.dispose();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.customPhysics ?? SmoothScrollPhysics.fromIntensity(widget.intensity, widget.physics);

    return Listener(
      onPointerSignal: _smoothController.handlePointerSignal,
      child: ListView.builder(
        itemBuilder: widget.itemBuilder,
        itemCount: widget.itemCount,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        controller: _scrollController,
        dragStartBehavior: widget.dragStartBehavior,
        findChildIndexCallback: widget.findChildIndexCallback,
        itemExtent: widget.itemExtent,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        padding: widget.padding,
        physics: physics,
        primary: widget.primary,
        prototypeItem: widget.prototypeItem,
        restorationId: widget.restorationId,
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        semanticChildCount: widget.semanticChildCount,
        shrinkWrap: widget.shrinkWrap,
      ),
    );
  }
}

class _SmoothListViewSeparated extends StatefulWidget {
  final SmoothScrollMode mode;
  final ScrollIntensity intensity;
  final SmoothScrollPhysics? customPhysics;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final int itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final Clip clipBehavior;
  final ScrollController? controller;
  final DragStartBehavior dragStartBehavior;
  final ChildIndexGetter? findChildIndexCallback;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget? prototypeItem;
  final String? restorationId;
  final bool reverse;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;

  const _SmoothListViewSeparated({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.itemCount,
    required this.mode,
    required this.intensity,
    required this.customPhysics,
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.addSemanticIndexes,
    required this.cacheExtent,
    required this.clipBehavior,
    required this.controller,
    required this.dragStartBehavior,
    required this.findChildIndexCallback,
    required this.itemExtent,
    required this.keyboardDismissBehavior,
    required this.padding,
    required this.physics,
    required this.primary,
    required this.prototypeItem,
    required this.restorationId,
    required this.reverse,
    required this.scrollDirection,
    required this.semanticChildCount,
    required this.shrinkWrap,
  });

  @override
  State<_SmoothListViewSeparated> createState() => _SmoothListViewSeparatedState();
}

class _SmoothListViewSeparatedState extends State<_SmoothListViewSeparated> with SingleTickerProviderStateMixin {
  late SmoothScrollController _smoothController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _smoothController = SmoothScrollController(
      scrollController: _scrollController,
      intensity: widget.intensity,
      customPhysics: widget.customPhysics,
      reverse: widget.reverse,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_SmoothListViewSeparated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intensity != oldWidget.intensity ||
        widget.customPhysics != oldWidget.customPhysics ||
        widget.reverse != oldWidget.reverse) {
      _smoothController.updateConfig(
        intensity: widget.intensity,
        customPhysics: widget.customPhysics,
        reverse: widget.reverse,
      );
    }
  }

  @override
  void dispose() {
    _smoothController.dispose();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.customPhysics ?? SmoothScrollPhysics.fromIntensity(widget.intensity, widget.physics);

    return Listener(
      onPointerSignal: _smoothController.handlePointerSignal,
      child: ListView.separated(
        itemBuilder: widget.itemBuilder,
        separatorBuilder: widget.separatorBuilder,
        itemCount: widget.itemCount,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        controller: _scrollController,
        dragStartBehavior: widget.dragStartBehavior,
        findChildIndexCallback: widget.findChildIndexCallback,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        padding: widget.padding,
        physics: physics,
        primary: widget.primary,
        restorationId: widget.restorationId,
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
      ),
    );
  }
}

class _SmoothListViewCustom extends StatefulWidget {
  final SmoothScrollMode mode;
  final ScrollIntensity intensity;
  final SmoothScrollPhysics? customPhysics;
  final SliverChildDelegate childrenDelegate;
  final double? cacheExtent;
  final Clip clipBehavior;
  final ScrollController? controller;
  final DragStartBehavior dragStartBehavior;
  final double? itemExtent;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final Widget? prototypeItem;
  final String? restorationId;
  final bool reverse;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool shrinkWrap;

  const _SmoothListViewCustom({
    super.key,
    required this.childrenDelegate,
    required this.mode,
    required this.intensity,
    required this.customPhysics,
    required this.cacheExtent,
    required this.clipBehavior,
    required this.controller,
    required this.dragStartBehavior,
    required this.itemExtent,
    required this.keyboardDismissBehavior,
    required this.padding,
    required this.physics,
    required this.primary,
    required this.prototypeItem,
    required this.restorationId,
    required this.reverse,
    required this.scrollDirection,
    required this.semanticChildCount,
    required this.shrinkWrap,
  });

  @override
  State<_SmoothListViewCustom> createState() => _SmoothListViewCustomState();
}

class _SmoothListViewCustomState extends State<_SmoothListViewCustom> with SingleTickerProviderStateMixin {
  late SmoothScrollController _smoothController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _smoothController = SmoothScrollController(
      scrollController: _scrollController,
      intensity: widget.intensity,
      customPhysics: widget.customPhysics,
      reverse: widget.reverse,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_SmoothListViewCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intensity != oldWidget.intensity ||
        widget.customPhysics != oldWidget.customPhysics ||
        widget.reverse != oldWidget.reverse) {
      _smoothController.updateConfig(
        intensity: widget.intensity,
        customPhysics: widget.customPhysics,
        reverse: widget.reverse,
      );
    }
  }

  @override
  void dispose() {
    _smoothController.dispose();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.customPhysics ?? SmoothScrollPhysics.fromIntensity(widget.intensity, widget.physics);

    return Listener(
      onPointerSignal: _smoothController.handlePointerSignal,
      child: ListView.custom(
        childrenDelegate: widget.childrenDelegate,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        controller: _scrollController,
        dragStartBehavior: widget.dragStartBehavior,
        itemExtent: widget.itemExtent,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        padding: widget.padding,
        physics: physics,
        primary: widget.primary,
        prototypeItem: widget.prototypeItem,
        restorationId: widget.restorationId,
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        semanticChildCount: widget.semanticChildCount,
        shrinkWrap: widget.shrinkWrap,
      ),
    );
  }
}

// ============================================================================
// src/smooth_custom_scroll_view.dart
// ============================================================================

/// A CustomScrollView that provides buttery-smooth scrolling on desktop platforms
/// while maintaining native scroll behavior on mobile.
///
/// This widget wraps Flutter's standard CustomScrollView and adds the same
/// smooth scrolling capabilities as SmoothListView.
///
/// Perfect for complex scrollable layouts with multiple sliver types.
///
/// Example:
/// ```dart
/// SmoothCustomScrollView(
///   slivers: [
///     SliverAppBar(title: Text('Title')),
///     SliverList(delegate: SliverChildBuilderDelegate(...)),
///     SliverGrid(delegate: SliverChildBuilderDelegate(...)),
///   ],
/// )
/// ```
class SmoothCustomScrollView extends StatelessWidget {
  /// The mode determining when smooth scroll is applied
  final SmoothScrollMode mode;

  /// The intensity/feel of the scrolling
  final ScrollIntensity intensity;

  /// Custom physics for power users (overrides intensity)
  final SmoothScrollPhysics? customPhysics;

  // Standard CustomScrollView parameters
  final List<Widget> slivers;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const SmoothCustomScrollView({
    super.key,
    this.mode = SmoothScrollMode.auto,
    this.intensity = ScrollIntensity.slow,
    this.customPhysics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.slivers = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final shouldApplySmooth = _shouldApplySmoothScroll();

    if (!shouldApplySmooth) {
      // Mobile or disabled: return plain CustomScrollView with zero overhead
      return CustomScrollView(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        scrollBehavior: scrollBehavior,
        shrinkWrap: shrinkWrap,
        center: center,
        anchor: anchor,
        cacheExtent: cacheExtent,
        slivers: slivers,
        semanticChildCount: semanticChildCount,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
      );
    }

    // Desktop: apply smooth scroll
    return _SmoothCustomScrollViewWrapper(
      key: key,
      mode: mode,
      intensity: intensity,
      customPhysics: customPhysics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      scrollBehavior: scrollBehavior,
      shrinkWrap: shrinkWrap,
      center: center,
      anchor: anchor,
      cacheExtent: cacheExtent,
      slivers: slivers,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
    );
  }

  bool _shouldApplySmoothScroll() {
    if (mode == SmoothScrollMode.disabled) return false;

    // Auto mode: only enable on desktop
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.fuchsia;

    return isDesktop;
  }
}

/// Internal wrapper for smooth CustomScrollView
class _SmoothCustomScrollViewWrapper extends StatefulWidget {
  final SmoothScrollMode mode;
  final ScrollIntensity intensity;
  final SmoothScrollPhysics? customPhysics;
  final List<Widget> slivers;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const _SmoothCustomScrollViewWrapper({
    super.key,
    required this.mode,
    required this.intensity,
    required this.customPhysics,
    required this.slivers,
    required this.scrollDirection,
    required this.reverse,
    required this.controller,
    required this.primary,
    required this.physics,
    required this.scrollBehavior,
    required this.shrinkWrap,
    required this.center,
    required this.anchor,
    required this.cacheExtent,
    required this.semanticChildCount,
    required this.dragStartBehavior,
    required this.keyboardDismissBehavior,
    required this.restorationId,
    required this.clipBehavior,
  });

  @override
  State<_SmoothCustomScrollViewWrapper> createState() => _SmoothCustomScrollViewWrapperState();
}

class _SmoothCustomScrollViewWrapperState extends State<_SmoothCustomScrollViewWrapper>
    with SingleTickerProviderStateMixin {
  late SmoothScrollController _smoothController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _smoothController = SmoothScrollController(
      scrollController: _scrollController,
      intensity: widget.intensity,
      customPhysics: widget.customPhysics,
      reverse: widget.reverse,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_SmoothCustomScrollViewWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.intensity != oldWidget.intensity ||
        widget.customPhysics != oldWidget.customPhysics ||
        widget.reverse != oldWidget.reverse) {
      _smoothController.updateConfig(
        intensity: widget.intensity,
        customPhysics: widget.customPhysics,
        reverse: widget.reverse,
      );
    }
  }

  @override
  void dispose() {
    _smoothController.dispose();
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.customPhysics ?? SmoothScrollPhysics.fromIntensity(widget.intensity, widget.physics);

    return Listener(
      onPointerSignal: _smoothController.handlePointerSignal,
      child: CustomScrollView(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: _scrollController,
        primary: widget.primary,
        physics: physics,
        scrollBehavior: widget.scrollBehavior,
        shrinkWrap: widget.shrinkWrap,
        center: widget.center,
        anchor: widget.anchor,
        cacheExtent: widget.cacheExtent,
        slivers: widget.slivers,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      ),
    );
  }
}

// ============================================================================
// src/smooth_scroll_controller.dart
// ============================================================================

/// Manages smooth scroll state and handles pointer events.
///
/// This controller intercepts scroll events and drives continuous
/// frame-by-frame updates for smooth, responsive scrolling.
class SmoothScrollController {
  final ScrollController scrollController;
  final TickerProvider vsync;

  ScrollIntensity _intensity;
  SmoothScrollPhysics? _customPhysics;
  bool _reverse;

  // Scroll state
  double _targetPosition = 0.0;
  double _currentPosition = 0.0;
  double _velocity = 0.0;
  bool _isAnimating = false;
  DateTime? _lastEventTime;
  Ticker? _ticker;

  // Configuration
  late ScrollIntensityConfig _config;

  SmoothScrollController({
    required this.scrollController,
    required ScrollIntensity intensity,
    required SmoothScrollPhysics? customPhysics,
    required bool reverse,
    required this.vsync,
  }) : _intensity = intensity,
       _customPhysics = customPhysics,
       _reverse = reverse {
    _updateConfig();
    _currentPosition = scrollController.hasClients ? scrollController.offset : scrollController.initialScrollOffset;
    _targetPosition = _currentPosition;
  }

  void _updateConfig() {
    _config = _customPhysics?.config ?? ScrollIntensityConfig.fromIntensity(_intensity);
  }

  void updateConfig({
    required ScrollIntensity intensity,
    required SmoothScrollPhysics? customPhysics,
    required bool reverse,
  }) {
    _intensity = intensity;
    _customPhysics = customPhysics;
    _reverse = reverse;
    _updateConfig();
  }

  /// Handles pointer scroll events from the Listener widget
  void handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!scrollController.hasClients) return;

    // Calculate scroll delta with multiplier and direction
    final scrollDelta = event.scrollDelta.dy * _config.scrollMultiplier;
    final adjustedDelta = _reverse ? -scrollDelta : scrollDelta;

    // Update target position (bounded by scroll extent)
    final maxExtent = scrollController.position.maxScrollExtent;
    final newTarget = (_targetPosition + adjustedDelta).clamp(0.0, maxExtent);

    // Calculate velocity for momentum phase
    final now = DateTime.now();
    if (_lastEventTime != null) {
      final timeDelta = now.difference(_lastEventTime!).inMicroseconds / 1e6;
      if (timeDelta > 0 && timeDelta < 0.1) {
        // Ignore if too much time passed
        // Accumulate velocity with exponential smoothing for natural feel
        final instantVelocity = adjustedDelta / timeDelta;
        _velocity = _velocity * 0.7 + instantVelocity * 0.3;
      }
    } else {
      // First event - set initial velocity
      _velocity = adjustedDelta * 10; // Rough estimate
    }

    _lastEventTime = now;
    _targetPosition = newTarget;

    // Start animation if not already running
    if (!_isAnimating) {
      _currentPosition = scrollController.offset;
      _startAnimation();
    }
  }

  void _startAnimation() {
    _isAnimating = true;

    // Reuse existing ticker if available, only create once
    _ticker ??= vsync.createTicker(_onTick);

    // Only start if not already running
    if (!_ticker!.isActive) {
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (!scrollController.hasClients) {
      _stopAnimation();
      return;
    }

    final now = DateTime.now();
    final timeSinceLastEvent = _lastEventTime != null ? now.difference(_lastEventTime!).inMilliseconds : 0;

    // Check if user has stopped scrolling (no events for 80ms)
    if (timeSinceLastEvent > 80 && _velocity.abs() > 50.0) {
      // Transition to momentum phase - let physics take over
      _currentPosition = scrollController.offset;
      _stopAnimation();

      // Trigger momentum by simulating a fling
      final position = scrollController.position;
      if (position is ScrollPositionWithSingleContext) {
        position.goBallistic(_velocity);
      }
      return;
    }

    // Active scrolling phase - check if we've reached the target
    final distance = (_targetPosition - _currentPosition).abs();
    if (distance < 0.5) {
      _currentPosition = _targetPosition;
      scrollController.jumpTo(_currentPosition);

      // If no new events for a while, stop (but no momentum if velocity is low)
      if (timeSinceLastEvent > 80) {
        _stopAnimation();
      }
      return;
    }

    // Interpolate position using the configured curve
    // Use adaptive lerp factor based on distance
    final baseLerpFactor = distance < 100 ? 0.3 : 0.2;
    final curveT = _config.activeCurve.transform(baseLerpFactor);

    _currentPosition = _currentPosition + (_targetPosition - _currentPosition) * curveT;

    // Apply position (using jumpTo for immediate response)
    scrollController.jumpTo(_currentPosition);
  }

  void _stopAnimation() {
    _isAnimating = false;
    // Stop the ticker but don't dispose it - we'll reuse it
    _ticker?.stop();
    _lastEventTime = null;
    _velocity = 0.0;
  }

  void dispose() {
    _ticker?.dispose();
  }
}

// ============================================================================
// src/smooth_scroll_physics.dart
// ============================================================================

/// Custom scroll physics for smooth desktop scrolling.
///
/// This physics provides natural momentum and deceleration after
/// the user stops actively scrolling.
class SmoothScrollPhysics extends ScrollPhysics {
  final ScrollIntensityConfig config;

  const SmoothScrollPhysics({required this.config, super.parent});

  /// Creates physics from a scroll intensity preset
  factory SmoothScrollPhysics.fromIntensity(ScrollIntensity intensity, ScrollPhysics? parent) {
    return SmoothScrollPhysics(config: ScrollIntensityConfig.fromIntensity(intensity), parent: parent);
  }

  /// Creates custom physics for power users
  factory SmoothScrollPhysics.custom({
    required double friction,
    required double decelerationRate,
    required double scrollMultiplier,
    required Curve activeCurve,
    ScrollPhysics? parent,
  }) {
    return SmoothScrollPhysics(
      config: ScrollIntensityConfig(
        friction: friction,
        decelerationRate: decelerationRate,
        scrollMultiplier: scrollMultiplier,
        activeCurve: activeCurve,
      ),
      parent: parent,
    );
  }

  @override
  SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothScrollPhysics(config: config, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    // If velocity is too small, don't create momentum
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    // Use friction simulation for natural deceleration
    return FrictionSimulation(config.friction, position.pixels, velocity, tolerance: tolerance);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // During active scrolling, apply the offset directly
    // This ensures immediate response
    return offset;
  }

  @override
  bool get allowImplicitScrolling => false;

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;

  @override
  double carriedMomentum(double existingVelocity) {
    // Apply deceleration rate to carried momentum
    return existingVelocity * config.decelerationRate;
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(mass: 0.5, stiffness: 100.0, ratio: 1.1);
}

// ============================================================================
// src/scroll_intensity_config.dart
// ============================================================================

/// Configuration for scroll intensity/feel
///
/// Defines the physics parameters that control how scrolling feels,
/// including friction, deceleration, and animation curves.
class ScrollIntensityConfig {
  /// Friction coefficient for momentum phase (lower = longer glide)
  final double friction;

  /// Rate at which momentum decreases (0-1, higher = longer momentum)
  final double decelerationRate;

  /// Multiplier for scroll events (higher = faster scroll per tick)
  final double scrollMultiplier;

  /// Curve used for interpolation during active scrolling
  final Curve activeCurve;

  const ScrollIntensityConfig({
    required this.friction,
    required this.decelerationRate,
    required this.scrollMultiplier,
    required this.activeCurve,
  });

  /// Slow intensity - macOS-like feel with smooth, long momentum
  static const slow = ScrollIntensityConfig(
    friction: 0.001, // Lower = longer glide
    decelerationRate: 0.97, // Higher = longer momentum
    scrollMultiplier: 0.15,
    activeCurve: Curves.easeOutCubic,
  );

  /// Medium intensity - Windows-like feel with balanced momentum
  static const medium = ScrollIntensityConfig(
    friction: 0.015, // Balanced friction
    decelerationRate: 0.95, // Balanced momentum
    scrollMultiplier: 1.0,
    activeCurve: Curves.easeOutQuad,
  );

  /// Fast intensity - snappier with shorter momentum
  static const fast = ScrollIntensityConfig(
    friction: 0.025, // Higher = quicker stop
    decelerationRate: 0.93, // Lower = shorter momentum
    scrollMultiplier: 1.5,
    activeCurve: Curves.easeOut,
  );

  /// Creates config from intensity enum
  factory ScrollIntensityConfig.fromIntensity(ScrollIntensity intensity) {
    switch (intensity) {
      case ScrollIntensity.slow:
        return slow;
      case ScrollIntensity.medium:
        return medium;
      case ScrollIntensity.fast:
        return fast;
    }
  }
}
