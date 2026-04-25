import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/favorites_provider.dart';
import '../widgets/stat_chart.dart';
import '../widgets/empty_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'STATISTICS',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favProvider, child) {
          final favorites = favProvider.favorites;

          // ── Empty state ───────────────────────────────────────
          if (favorites.isEmpty) {
            return const EmptyState(
              type: EmptyStateType.favorites,
              subtitle:
                  'Save some anime first to see\nyour personal statistics.',
            );
          }

          final stats = _StatsCalculator(favorites);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Summary KPI cards ─────────────────────────────
              _SummarySection(stats: stats),
              const SizedBox(height: 32),

              // ── Score distribution ────────────────────────────
              _ScoreSection(stats: stats),
              const SizedBox(height: 32),

              // ── Genre breakdown donut ─────────────────────────
              _GenreSection(stats: stats),
              const SizedBox(height: 32),

              // ── Type breakdown ────────────────────────────────
              _TypeSection(stats: stats),
              const SizedBox(height: 32),

              // ── Status breakdown ──────────────────────────────
              _StatusSection(stats: stats),
              const SizedBox(height: 32),

              // ── Top genres ranked list ─────────────────────────
              _TopGenresSection(stats: stats),
              const SizedBox(height: 32),

              // ── Year distribution ─────────────────────────────
              _YearSection(stats: stats),
              const SizedBox(height: 32),

              // ── Top rated saved ───────────────────────────────
              _TopRatedSection(stats: stats),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

// ── Stats calculator ──────────────────────────────────────────────
/// Derives all statistics from the favorites list.
/// Pure computation — no state, no side effects.
class _StatsCalculator {
  final List<Anime> favorites;

  _StatsCalculator(this.favorites);

  // ── KPIs ─────────────────────────────────────────────────────
  int get totalSaved => favorites.length;

  double get averageScore {
    final scored = favorites.where((a) => a.score.value != null).toList();
    if (scored.isEmpty) return 0;
    return scored.fold<double>(0, (s, a) => s + a.score.value!) /
        scored.length;
  }

  int get totalEpisodes =>
      favorites.fold<int>(0, (s, a) => s + (a.episodes ?? 0));

  Anime? get highestRated {
    final scored = favorites.where((a) => a.score.value != null).toList();
    if (scored.isEmpty) return null;
    return scored.reduce(
      (a, b) => (a.score.value ?? 0) > (b.score.value ?? 0) ? a : b,
    );
  }

  // ── Genre breakdown ───────────────────────────────────────────
  Map<String, int> get genreCounts {
    final map = <String, int>{};
    for (final anime in favorites) {
      for (final genre in anime.genres) {
        map[genre] = (map[genre] ?? 0) + 1;
      }
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  // ── Type breakdown ────────────────────────────────────────────
  Map<String, int> get typeCounts {
    final map = <String, int>{};
    for (final anime in favorites) {
      final type = anime.type ?? 'Unknown';
      map[type] = (map[type] ?? 0) + 1;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  // ── Status breakdown ──────────────────────────────────────────
  Map<String, int> get statusCounts {
    final map = <String, int>{};
    for (final anime in favorites) {
      final status = anime.status ?? 'Unknown';
      map[status] = (map[status] ?? 0) + 1;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  // ── Score distribution ────────────────────────────────────────
  /// Buckets: 1-2, 2-3, ... 9-10
  Map<String, int> get scoreDistribution {
    final map = <String, int>{
      '1': 0,
      '2': 0,
      '3': 0,
      '4': 0,
      '5': 0,
      '6': 0,
      '7': 0,
      '8': 0,
      '9': 0,
      '10': 0,
    };
    for (final anime in favorites) {
      if (anime.score.value == null) continue;
      final bucket = anime.score.value!.floor().clamp(1, 10).toString();
      map[bucket] = (map[bucket] ?? 0) + 1;
    }
    return map;
  }

  // ── Year distribution ─────────────────────────────────────────
  Map<String, int> get yearCounts {
    final map = <String, int>{};
    for (final anime in favorites) {
      if (anime.year == null) continue;
      map[anime.year!] = (map[anime.year!] ?? 0) + 1;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  // ── Top rated ─────────────────────────────────────────────────
  List<Anime> get topRated {
    final scored = favorites
        .where((a) => a.score.value != null)
        .toList()
      ..sort((a, b) =>
          (b.score.value ?? 0).compareTo(a.score.value ?? 0));
    return scored.take(5).toList();
  }
}

// ── Summary section ───────────────────────────────────────────────
class _SummarySection extends StatelessWidget {
  final _StatsCalculator stats;
  const _SummarySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            StatCard(
              value: stats.totalSaved.toString(),
              label: 'Saved',
              icon: Icons.bookmark_rounded,
            ),
            const SizedBox(width: 12),
            StatCard(
              value: stats.averageScore > 0
                  ? stats.averageScore.toStringAsFixed(2)
                  : 'N/A',
              label: 'Avg Score',
              icon: Icons.star_rounded,
            ),
            const SizedBox(width: 12),
            StatCard(
              value: _formatEpisodes(stats.totalEpisodes),
              label: 'Episodes',
              icon: Icons.play_circle_outline_rounded,
            ),
          ],
        ),
        if (stats.highestRated != null) ...[
          const SizedBox(height: 12),
          _HighlightCard(
            label: 'Highest Rated',
            title: stats.highestRated!.title,
            value:
                stats.highestRated!.score.value?.toStringAsFixed(1) ?? 'N/A',
            icon: Icons.emoji_events_rounded,
          ),
        ],
      ],
    );
  }

  String _formatEpisodes(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

// ── Highlight card ────────────────────────────────────────────────
class _HighlightCard extends StatelessWidget {
  final String label;
  final String title;
  final String value;
  final IconData icon;

  const _HighlightCard({
    required this.label,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score section ─────────────────────────────────────────────────
class _ScoreSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _ScoreSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distribution = stats.scoreDistribution;
    final hasScores =
        distribution.values.any((v) => v > 0);

    if (!hasScores) return const SizedBox.shrink();

    return _SectionCard(
      child: ScoreDistributionChart(
        title: 'Score Distribution',
        distribution: distribution,
      ),
    );
  }
}

// ── Genre section ─────────────────────────────────────────────────
class _GenreSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _GenreSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final genreCounts = stats.genreCounts;
    if (genreCounts.isEmpty) return const SizedBox.shrink();

    // Take top 8 genres for readability.
    final topGenres = genreCounts.entries.take(8).toList();
    final total = topGenres.fold<int>(0, (s, e) => s + e.value);

    return _SectionCard(
      child: DonutChart(
        title: 'Genre Breakdown',
        segments: topGenres
            .map((e) => DonutSegment(
                  label: e.key,
                  value: e.value.toDouble(),
                ))
            .toList(),
        centerLabel: 'Genres',
        centerValue: genreCounts.length.toString(),
      ),
    );
  }
}

// ── Type section ──────────────────────────────────────────────────
class _TypeSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _TypeSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final typeCounts = stats.typeCounts;
    if (typeCounts.isEmpty) return const SizedBox.shrink();

    final maxVal = typeCounts.values
        .fold<int>(0, (max, v) => v > max ? v : max)
        .toDouble();

    return _SectionCard(
      child: BarChart(
        title: 'By Type',
        data: typeCounts.entries
            .map((e) => BarChartData(
                  label: e.key,
                  value: e.value.toDouble(),
                  displayValue: e.value.toString(),
                ))
            .toList(),
        maxValue: maxVal,
      ),
    );
  }
}

// ── Status section ────────────────────────────────────────────────
class _StatusSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _StatusSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final statusCounts = stats.statusCounts;
    if (statusCounts.isEmpty) return const SizedBox.shrink();

    final maxVal = statusCounts.values
        .fold<int>(0, (max, v) => v > max ? v : max)
        .toDouble();

    return _SectionCard(
      child: BarChart(
        title: 'By Status',
        data: statusCounts.entries
            .map((e) => BarChartData(
                  label: _shortenStatus(e.key),
                  value: e.value.toDouble(),
                  displayValue: e.value.toString(),
                ))
            .toList(),
        maxValue: maxVal,
      ),
    );
  }

  String _shortenStatus(String status) {
    if (status == 'Currently Airing') return 'Airing';
    if (status == 'Finished Airing') return 'Finished';
    if (status == 'Not yet aired') return 'Upcoming';
    return status;
  }
}

// ── Top genres ranked list section ────────────────────────────────
class _TopGenresSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _TopGenresSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final genreCounts = stats.genreCounts;
    if (genreCounts.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      child: RankedList(
        title: 'Top Genres',
        items: genreCounts.entries
            .map((e) => _RankedItem(label: e.key, count: e.value))
            .toList(),
        maxItems: 8,
      ),
    );
  }
}

// ── Year section ──────────────────────────────────────────────────
class _YearSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _YearSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final yearCounts = stats.yearCounts;
    if (yearCounts.isEmpty) return const SizedBox.shrink();

    final maxVal = yearCounts.values
        .fold<int>(0, (max, v) => v > max ? v : max)
        .toDouble();

    return _SectionCard(
      child: BarChart(
        title: 'By Year',
        data: yearCounts.entries
            .map((e) => BarChartData(
                  label: e.key,
                  value: e.value.toDouble(),
                  displayValue: e.value.toString(),
                ))
            .toList(),
        maxValue: maxVal,
      ),
    );
  }
}

// ── Top rated section ─────────────────────────────────────────────
class _TopRatedSection extends StatelessWidget {
  final _StatsCalculator stats;
  const _TopRatedSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final topRated = stats.topRated;
    if (topRated.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Rated Saved', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...topRated.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final anime = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 28,
                    child: Text(
                      '#$rank',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: rank == 1 ? primary : null,
                        fontWeight: rank == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),

                  // Title
                  Expanded(
                    child: Text(
                      anime.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: rank == 1
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Score
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        anime.score.value?.toStringAsFixed(1) ?? 'N/A',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}