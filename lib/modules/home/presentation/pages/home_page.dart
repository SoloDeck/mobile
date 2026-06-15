import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solodesk_mobile/core/router/route_names.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SoloDesk')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NavigationCard(
            label: 'Khách hàng',
            icon: Icons.people_outline,
            route: RouteNames.clients,
          ),
          _NavigationCard(
            label: 'Pipeline thương vụ',
            icon: Icons.trending_up,
            route: RouteNames.deals,
          ),
          _NavigationCard(
            label: 'Tổng quan',
            icon: Icons.analytics_outlined,
            route: RouteNames.analytics,
          ),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }
}
