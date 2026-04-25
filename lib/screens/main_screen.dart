import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anime_discovery/widgets/offline_banner.dart';
import 'package:anime_discovery/router/route_names.dart';

/// Shell screen — owns the persistent bottom nav bar.
/// [child] is the currently active tab screen provided by
/// [ShellRoute] in [appRouter].
class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  // ── Tab definitions ───────────────────────────────────────────
  static const List<_TabItem> _tabs = [
    _TabItem(
      route: RouteNames.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _TabItem(
      route: RouteNames.search,
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Search',
    ),
    _TabItem(
      route: RouteNames.seasonal,
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Season',
    ),
    _TabItem(
      route: RouteNames.genres,
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Genres',
    ),
    _TabItem(
      route: RouteNames.schedule,
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule_rounded,
      label: 'Schedule',
    ),
    _TabItem(
      route: RouteNames.characters,
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Characters',
    ),
    _TabItem(
      route: RouteNames.favorites,
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Saved',
    ),
    _TabItem(
      route: RouteNames.statistics,
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
    _TabItem(
      route: RouteNames.about,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'About',
    ),
  ];

  /// Returns the index of the tab whose route matches the
  /// current location — falls back to 0 (Home) if not found.
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere(
      (tab) => location.startsWith(tab.route),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Active tab content ──────────────────────────────
          child,

          // ── Offline banner ──────────────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineBanner(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            final route = _tabs[index].route;
            // Use go() so the shell does not stack — pressing
            // the same tab resets its scroll position etc.
            context.go(route);
          },
          items: _tabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ── Tab item data class ───────────────────────────────────────────
class _TabItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}