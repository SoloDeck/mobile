import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps a subpage with a left-edge swipe-to-pop gesture.
///
/// A custom gesture recognizer intercepts horizontal drags that START within
/// [edgeWidth] pixels of the left screen edge.  This means the recognizer
/// never competes with scrollables in the rest of the screen.
///
/// Usage: wrap the `child` inside `_slidePage` (app_router.dart).  Every
/// route built through that helper automatically gets swipe-back.
class SwipeBackWrapper extends StatefulWidget {
  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.edgeWidth = 40.0,
    this.popThreshold = 0.35,
    this.velocityThreshold = 500.0,
  });

  final Widget child;

  /// How many logical pixels from the left edge activate the gesture.
  final double edgeWidth;

  /// Fraction of screen width that triggers a pop on release.
  final double popThreshold;

  /// Horizontal velocity (px/s) that triggers a pop regardless of distance.
  final double velocityThreshold;

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spring;

  double _offset = 0;
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 0,
    );
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  void _onStart(DragStartDetails _) {
    if (!context.canPop()) return;
    _tracking = true;
    _spring.stop();
    setState(() => _offset = 0);
  }

  void _onUpdate(DragUpdateDetails details) {
    if (!_tracking) return;
    setState(() {
      final w = MediaQuery.sizeOf(context).width;
      _offset = (_offset + details.delta.dx).clamp(0.0, w);
    });
  }

  void _onEnd(DragEndDetails details) {
    if (!_tracking) return;
    _tracking = false;

    final w = MediaQuery.sizeOf(context).width;
    final velocity = details.primaryVelocity ?? 0;

    if (_offset > w * widget.popThreshold || velocity > widget.velocityThreshold) {
      context.pop();
      return;
    }

    // Spring back to origin.
    final startOffset = _offset;
    _spring.value = 0;
    _spring.forward();
    _spring.addListener(() {
      if (!mounted) return;
      setState(() => _offset = startOffset * (1 - _spring.value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _LeftEdgeDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_LeftEdgeDragRecognizer>(
          () => _LeftEdgeDragRecognizer(edgeWidth: widget.edgeWidth),
          (r) {
            r
              ..onStart = _onStart
              ..onUpdate = _onUpdate
              ..onEnd = _onEnd;
          },
        ),
      },
      child: Transform.translate(
        offset: Offset(_offset, 0),
        child: widget.child,
      ),
    );
  }
}

/// A [HorizontalDragGestureRecognizer] that only enters the gesture arena when
/// the pointer-down event starts within [edgeWidth] of the left edge.
class _LeftEdgeDragRecognizer extends HorizontalDragGestureRecognizer {
  _LeftEdgeDragRecognizer({required this.edgeWidth});

  final double edgeWidth;

  @override
  void addPointer(PointerDownEvent event) {
    if (event.localPosition.dx <= edgeWidth) {
      super.addPointer(event);
    }
  }
}
