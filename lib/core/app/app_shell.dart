import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goToTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      // navigationShell renders as SwipeableTabBody (wired in app_router.dart
      // via navigatorContainerBuilder) — no extra wrapper needed here.
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push(RouteNames.voiceCapture),
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_rounded,
                label: 'Trang chủ',
                selected: location == RouteNames.home || location == '/',
                onTap: () => _goToTab(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.view_kanban_outlined,
                label: 'Pipeline',
                selected: location.startsWith(RouteNames.deals),
                onTap: () => _goToTab(1),
              ),
            ),
            const SizedBox(width: 58),
            Expanded(
              child: _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Khách hàng',
                selected: location.startsWith(RouteNames.clients),
                onTap: () => _goToTab(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Hóa đơn',
                selected: location.startsWith(RouteNames.invoices),
                onTap: () => _goToTab(4),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Báo cáo',
                selected: location.startsWith(RouteNames.analytics),
                onTap: () => _goToTab(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive tab container placed in [StatefulShellRoute.navigatorContainerBuilder].
///
/// During a left-edge swipe the current tab slides right and the previous tab
/// slides in from the left simultaneously — exactly like a push-navigation
/// swipe-back.  Tapping the bottom nav switches tabs instantly via [IndexedStack].
class SwipeableTabBody extends StatefulWidget {
  const SwipeableTabBody({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<SwipeableTabBody> createState() => _SwipeableTabBodyState();
}

class _SwipeableTabBodyState extends State<SwipeableTabBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final CurvedAnimation _curve;

  // Ordered list of previously visited tab indices.
  final List<int> _history = [];

  double _offset = 0;
  bool _tracking = false;

  // Index of the tab that started sliding out when the drag began.
  int? _draggingIndex;

  // True while animating the swipe all the way to completion.
  bool _completingForward = false;

  // Suppresses the automatic history push in didUpdateWidget when we call
  // goBranch() programmatically to finish a swipe-back.
  bool _suppressHistoryPush = false;

  // Range for the current animation segment.
  double _animFrom = 0;
  double _animTo = 0;

  static const double _edgeWidth = 40.0;
  static const double _popThreshold = 0.35;
  static const double _velocityThreshold = 500.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _curve = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.addListener(_onAnimTick);
    _anim.addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeableTabBody old) {
    super.didUpdateWidget(old);
    final curr = widget.navigationShell.currentIndex;
    final prev = old.navigationShell.currentIndex;
    if (curr != prev) {
      if (!_suppressHistoryPush) {
        _history.add(prev);
      }
      _suppressHistoryPush = false;
    }
  }

  // Tab swipe is allowed only when there is history to return to AND no
  // subpage is pushed on top (the subpage's SwipeBackWrapper handles that).
  bool get _canSwipeBack =>
      _history.isNotEmpty && !GoRouter.of(context).canPop();

  void _onAnimTick() {
    setState(() {
      _offset = _animFrom + (_animTo - _animFrom) * _curve.value;
    });
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_completingForward) {
      _completingForward = false;
      _suppressHistoryPush = true;
      final prevIdx = _history.removeLast();
      widget.navigationShell.goBranch(prevIdx, initialLocation: false);
    }
    if (mounted) {
      setState(() {
        _offset = 0;
        _draggingIndex = null;
      });
    }
  }

  void _onDragStart(DragStartDetails _) {
    if (!_canSwipeBack) return;
    _tracking = true;
    _draggingIndex = widget.navigationShell.currentIndex;
    _anim.stop();
    setState(() => _offset = 0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_tracking) return;
    setState(() {
      final w = MediaQuery.sizeOf(context).width;
      _offset = (_offset + details.delta.dx).clamp(0.0, w);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_tracking) return;
    _tracking = false;
    final w = MediaQuery.sizeOf(context).width;
    final velocity = details.primaryVelocity ?? 0;

    _animFrom = _offset;
    if (_offset > w * _popThreshold || velocity > _velocityThreshold) {
      _completingForward = true;
      _animTo = w;
      _anim.duration = Duration(
        milliseconds: ((1 - _offset / w) * 250).round().clamp(80, 250),
      );
    } else {
      _completingForward = false;
      _animTo = 0;
      _anim.duration = const Duration(milliseconds: 300);
    }
    _anim.value = 0;
    _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final current = widget.navigationShell.currentIndex;
    final prevIdx = _history.isEmpty ? null : _history.last;

    // isDragging: there's an active drag or the completion/spring animation
    // is still running and we have something to show behind the current tab.
    final isDragging = _draggingIndex != null && (_tracking || _offset > 0);

    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _TabEdgeDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_TabEdgeDragRecognizer>(
              () => _TabEdgeDragRecognizer(
                edgeWidth: _edgeWidth,
                canActivate: () => _canSwipeBack,
              ),
              (r) {
                r
                  ..onStart = _onDragStart
                  ..onUpdate = _onDragUpdate
                  ..onEnd = _onDragEnd;
              },
            ),
      },
      child: isDragging && prevIdx != null
          ? ClipRect(
              child: Stack(
                children: [
                  // Previous tab: slides in from the left.
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(_offset - w, 0),
                      child: widget.children[prevIdx],
                    ),
                  ),
                  // Current tab: slides out to the right.
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(_offset, 0),
                      child: widget.children[_draggingIndex!],
                    ),
                  ),
                ],
              ),
            )
          : IndexedStack(index: current, children: widget.children),
    );
  }
}

/// [HorizontalDragGestureRecognizer] that only enters the gesture arena when
/// the touch starts within [edgeWidth] px of the left edge AND [canActivate]
/// returns true.  The [canActivate] check runs at pointer-down time so this
/// recognizer never competes with the subpage [SwipeBackWrapper].
class _TabEdgeDragRecognizer extends HorizontalDragGestureRecognizer {
  _TabEdgeDragRecognizer({required this.edgeWidth, required this.canActivate});

  final double edgeWidth;
  final bool Function() canActivate;

  @override
  void addPointer(PointerDownEvent event) {
    if (event.localPosition.dx <= edgeWidth && canActivate()) {
      super.addPointer(event);
    }
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _controller,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
