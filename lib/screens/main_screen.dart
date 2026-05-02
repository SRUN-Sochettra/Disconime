import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:anime_discovery/providers/theme_provider.dart';
import 'package:anime_discovery/widgets/offline_banner.dart';
import 'package:anime_discovery/router/route_names.dart';
import 'package:anime_discovery/widgets/app_chrome.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  // ── Only 4 bottom tabs ─────────────────────────────────────────
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

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ValueNotifier<String> _pathNotifier = ValueNotifier<String>('/');

  @override
  void dispose() {
    _pathNotifier.dispose();
    super.dispose();
  }

  int _currentBottomIndex(String path) {
    for (var i = 0; i < MainScreen._bottomTabs.length; i++) {
      final route = MainScreen._bottomTabs[i].route;
      if (route == '/') {
        if (path == '/') return i;
      } else {
        if (path == route || path.startsWith('$route/')) return i;
      }
    }
    return -1;
  }

  bool _isMoreRoute(String path) {
    for (final item in MainScreen._moreItems) {
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

    if (_pathNotifier.value != path) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pathNotifier.value = path;
      });
    }

    final currentBottomIndex = _currentBottomIndex(path);
    final isOnMorePage = _isMoreRoute(path);

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final bg = theme.scaffoldBackgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
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
            top: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppChrome.bottomNavHeight,
            child: Row(
              children: [
                ...MainScreen._bottomTabs.asMap().entries.map((entry) {
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

                Expanded(
                  child: GestureDetector(
                    onTap: () => _showMoreSheet(context),
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

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _MoreSheet(pathNotifier: _pathNotifier);
      },
    );
  }
}

class _MoreSheet extends StatelessWidget {
  final ValueNotifier<String> pathNotifier;

  const _MoreSheet({required this.pathNotifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ValueListenableBuilder<String>(
      valueListenable: pathNotifier,
      builder: (context, currentPath, _) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppChrome.sheetRadius),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'MORE',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 20,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...MainScreen._moreItems.map((item) {
                            final isActive = currentPath == item.route ||
                                currentPath.startsWith('${item.route}/');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pop(context);
                                  if (!isActive) {
                                    context.go(item.route);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 3,
                                        height: isActive ? 20 : 0,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      Icon(
                                        isActive
                                            ? item.activeIcon
                                            : item.icon,
                                        color: isActive ? primary : null,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontSize: 14,
                                            color:
                                                isActive ? primary : null,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      if (isActive)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Divider(
                              color: theme.dividerColor.withAlpha(60),
                              height: 1,
                            ),
                          ),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              final isDark = themeProvider.isDarkMode;

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  themeProvider.toggleTheme(!isDark);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 20,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      Icon(
                                        isDark
                                            ? Icons.light_mode_outlined
                                            : Icons.dark_mode_outlined,
                                        color: primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          isDark
                                              ? 'Light Mode'
                                              : 'Dark Mode',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontSize: 14,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 36,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: primary.withAlpha(20),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: primary.withAlpha(40),
                                          ),
                                        ),
                                        child: AnimatedAlign(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          curve: Curves.easeOut,
                                          alignment: isDark
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            margin:
                                                const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        // ── Gold dot — always takes space, only fades ──────
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: selected ? 1.0 : 0.0,
          child: Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // ── Icon ───────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            icon,
            key: ValueKey(selected),
            size: AppChrome.navIconSize,
            color: selected ? primary : muted,
          ),
        ),
        const SizedBox(height: 4),

        // ── Label ──────────────────────────────────────────
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 8,
            height: 1.0,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? primary : muted,
            letterSpacing: 1.2,
          ),
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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