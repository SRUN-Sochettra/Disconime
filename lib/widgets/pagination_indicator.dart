import 'package:flutter/material.dart';


/// Displays a subtle pagination status bar at the top of a
/// scrollable list showing:
/// - How many items are currently loaded
/// - A linear progress bar when more items are loading
/// - A "all caught up" state when no more pages exist
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     PaginationIndicator(
///       loadedCount: provider.topAnime.length,
///       isLoading: provider.topAnimeState == FetchState.loading,
///       hasMore: provider.hasMoreTopAnime,
///     ),
///     Expanded(child: ListView(...)),
///   ],
/// )
/// ```
class PaginationIndicator extends StatelessWidget {
  /// Number of items currently loaded.
  final int loadedCount;

  /// Whether a page is currently being fetched.
  final bool isLoading;

  /// Whether more pages are available.
  /// If false and not loading, shows "all caught up" state.
  final bool hasMore;

  /// Label for the item type — defaults to 'anime'.
  final String itemLabel;

  const PaginationIndicator({
    super.key,
    required this.loadedCount,
    required this.isLoading,
    required this.hasMore,
    this.itemLabel = 'anime',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status row ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Item count
                Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 14,
                      color: muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$loadedCount $itemLabel loaded',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),

                // State badge
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? _StatusBadge(
                          key: const ValueKey('loading'),
                          label: 'Loading more...',
                          color: primary,
                          icon: Icons.downloading_rounded,
                        )
                      : hasMore
                          ? _StatusBadge(
                              key: const ValueKey('more'),
                              label: 'Scroll for more',
                              color: muted,
                              icon: Icons.keyboard_arrow_down_rounded,
                            )
                          : _StatusBadge(
                              key: const ValueKey('done'),
                              label: 'All caught up',
                              color: primary,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                ),
              ],
            ),

            // ── Progress bar ───────────────────────────────────
            // Only visible while loading.
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: primary.withAlpha(20),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// A compact inline page counter shown inside a list footer.
/// Use this when you want a minimal page X indicator
/// instead of the full [PaginationIndicator] bar.
///
/// ```dart
/// PageCounter(currentPage: provider.currentPage)
/// ```
class PageCounter extends StatelessWidget {
  final int currentPage;
  final bool isLoading;

  const PageCounter({
    super.key,
    required this.currentPage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 12,
                  color: isLoading ? primary : muted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Page $currentPage',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isLoading ? primary : muted,
                    fontWeight: isLoading
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}