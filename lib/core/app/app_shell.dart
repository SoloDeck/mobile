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
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: _FadeTabSwitcher(
        activeIndex: navigationShell.currentIndex,
        reduceMotion: reduceMotion,
        child: navigationShell,
      ),
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

// Material 3 "Fade Through" for tab switching:
// old content fades out (opacity 1→0, scale 1→0.96),
// new content fades in (opacity 0→1, scale 0.96→1).
// Exit is shorter than enter so the UI feels responsive.
class _FadeTabSwitcher extends StatefulWidget {
  const _FadeTabSwitcher({
    required this.activeIndex,
    required this.child,
    required this.reduceMotion,
  });

  final int activeIndex;
  final Widget child;
  final bool reduceMotion;

  @override
  State<_FadeTabSwitcher> createState() => _FadeTabSwitcherState();
}

class _FadeTabSwitcherState extends State<_FadeTabSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..value = 1.0;

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(_FadeTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      if (widget.reduceMotion) return;
      _controller
        ..duration = const Duration(milliseconds: 140)
        ..reverse().then((_) {
          if (!mounted) return;
          _controller
            ..duration = const Duration(milliseconds: 220)
            ..forward();
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
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
    final color =
        widget.selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

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
