import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.voiceCapture),
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
                onTap: () => context.go(RouteNames.home),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.view_kanban_outlined,
                label: 'Pipeline',
                selected: location.startsWith(RouteNames.deals),
                onTap: () => context.go(RouteNames.deals),
              ),
            ),
            const SizedBox(width: 58),
            Expanded(
              child: _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Khách hàng',
                selected: location.startsWith(RouteNames.clients),
                onTap: () => context.go(RouteNames.clients),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Báo cáo',
                selected: location.startsWith(RouteNames.analytics),
                onTap: () => context.go(RouteNames.analytics),
              ),
            ),
          ],
        ),
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
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
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
        scale: _scale,
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
                  fontWeight:
                      widget.selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
