import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anime_discovery/widgets/offline_banner.dart';
import 'package:anime_discovery/router/route_names.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  // ── Only 5 bottom tabs ─────────────────────────────────────────
  static const List<_TabItem> _bottomTabs = [
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
      route: RouteNames.schedule,
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule_rounded,
      label: 'Schedule',
    ),
  ];

  // ── "More" menu items ──────────────────────────────────────────
  static const List<_TabItem> _moreItems = [
    _TabItem(
      route: RouteNames.genres,
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Genres',
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
      label: 'Statistics',
    ),
    _TabItem(
      route: RouteNames.about,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'About',
    ),
  ];

  // ── All routes that live in the shell ───────────────────────────
  static const List<String> _allRoutes = [
    RouteNames.home,
    RouteNames.search,
    RouteNames.seasonal,
    RouteNames.schedule,
    RouteNames.genres,
    RouteNames.characters,
    RouteNames.favorites,
    RouteNames.statistics,
    RouteNames.about,
  ];

  int _currentBottomIndex(String path) {
    for (var i = 0; i < _bottomTabs.length; i++) {
      final route = _bottomTabs[i].route;
      if (route == '/') {
        if (path == '/') return i;
      } else {
        if (path == route || path.startsWith('$route/')) return i;
      }
    }
    // If current route is a "more" item, no bottom tab is selected
    // → return -1 to highlight the "More" button instead
    return -1;
  }

  bool _isMoreRoute(String path) {
    for (final item in _moreItems) {
      if (path == item.route || path.startsWith('${item.route}/')) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final path = location.split('?').first;
    final currentBottomIndex = _currentBottomIndex(path);
    final isOnMorePage = _isMoreRoute(path);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final bg = theme.scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          child,
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
          color: bg,
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                // ── Bottom tab items ───────────────────────────
                ..._bottomTabs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final tab = entry.value;
                  final selected = i == currentBottomIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (selected) return;
                        context.go(tab.route);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: _NavBarIcon(
                        icon: selected ? tab.activeIcon : tab.icon,
                        label: tab.label,
                        selected: selected,
                        primary: primary,
                        muted: muted,
                      ),
                    ),
                  );
                }),

                // ── "More" button ──────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showMoreSheet(context, path),
                    behavior: HitTestBehavior.opaque,
                    child: _NavBarIcon(
                      icon: isOnMorePage
                          ? Icons.menu_rounded
                          : Icons.menu_outlined,
                      label: 'More',
                      selected: isOnMorePage,
                      primary: primary,
                      muted: muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreSheet(BuildContext context, String currentPath) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Menu items ──────────────────────────────────
              ..._moreItems.map((item) {
                final isActive = currentPath == item.route ||
                    currentPath.startsWith('${item.route}/');

                return ListTile(
                  leading: Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? primary : null,
                    size: 22,
                  ),
                  title: Text(
                    item.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: isActive ? primary : null,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isActive
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (!isActive) {
                      context.go(item.route);
                    }
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ── Nav bar icon widget ───────────────────────────────────────────
class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color primary;
  final Color muted;

  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.primary,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: selected ? primary : muted,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? primary : muted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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