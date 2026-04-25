import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/page_transitions.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;
  // Hero tag passed from the list screen — must match the tag
  // used on the AnimeImage in the list tile / grid card.
  final String? heroTag;

  const DetailScreen({
    super.key,
    required this.anime,
    this.heroTag,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnimeProvider>();
      provider.clearRecommendations();
      provider.fetchRecommendations(widget.anime.malId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: CircleAvatar(
          backgroundColor: Colors.black.withAlpha(100),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.black.withAlpha(100),
            child: Consumer<FavoritesProvider>(
              builder: (context, favProvider, child) {
                final isFav = favProvider.isFavorite(anime.malId);
                return IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: isFav
                        ? theme.colorScheme.primary
                        : Colors.white,
                  ),
                  onPressed: () => favProvider.toggleFavorite(anime),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image ────────────────────────────────────
            // heroTag matches the tag used in the list tile so
            // Flutter animates the poster into the full-width
            // detail image seamlessly.
            AnimeImage(
              imageUrl: anime.imageUrl,
              width: double.infinity,
              height: 450,
              borderRadius: 0,
              heroTag: widget.heroTag,
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Titles ───────────────────────────────────
                  Text(
                    anime.title,
                    style: theme.textTheme.titleLarge,
                  ),
                  if (anime.titleEnglish != null &&
                      anime.titleEnglish!.isNotEmpty &&
                      anime.titleEnglish != anime.title) ...[
                    const SizedBox(height: 4),
                    Text(
                      anime.titleEnglish!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (anime.titleJapanese != null &&
                      anime.titleJapanese!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      anime.titleJapanese!,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Stats row ────────────────────────────────
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.star_rounded,
                        value: anime.score.value?.toStringAsFixed(1) ??
                            'N/A',
                        label: 'Score',
                      ),
                      const SizedBox(width: 12),
                      _StatBadge(
                        icon: Icons.leaderboard_rounded,
                        value: anime.score.rank != null
                            ? '#${anime.score.rank}'
                            : 'N/A',
                        label: 'Rank',
                      ),
                      const SizedBox(width: 12),
                      _StatBadge(
                        icon: Icons.trending_up_rounded,
                        value: anime.score.popularity != null
                            ? '#${anime.score.popularity}'
                            : 'N/A',
                        label: 'Popular',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Genre chips ──────────────────────────────
                  if (anime.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anime.genres
                          .map((g) => _GenreChip(label: g))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Synopsis ─────────────────────────────────
                  Text(
                    'Synopsis',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    anime.synopsis.text,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // ── Info table ───────────────────────────────
                  _InfoSection(anime: anime),
                  const SizedBox(height: 32),

                  // ── Recommendations ──────────────────────────
                  _RecommendationsSection(currentAnime: anime),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat badge ────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Genre chip ────────────────────────────────────────────────────
class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(100),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Info section ──────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final Anime anime;
  const _InfoSection({required this.anime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];

    void addRow(String label, String? value) {
      if (value == null || value.isEmpty) return;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(label, style: theme.textTheme.labelSmall),
              ),
              Expanded(
                child: Text(value, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      );
    }

    addRow('Type', anime.type);
    addRow('Status', anime.status);
    addRow('Episodes', anime.episodes?.toString());
    addRow('Duration', anime.duration);
    addRow('Rating', anime.rating);
    addRow('Year', anime.year);
    if (anime.score.scoredBy != null) {
      addRow(
        'Scored By',
        '${_formatNumber(anime.score.scoredBy!)} users',
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Information', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

// ── Recommendations section ───────────────────────────────────────
class _RecommendationsSection extends StatelessWidget {
  final Anime currentAnime;
  const _RecommendationsSection({required this.currentAnime});

  @override
  Widget build(BuildContext context) {
    final state = context.select<AnimeProvider, FetchState>(
      (p) => p.recommendationsState,
    );
    final recommendations = context.select<AnimeProvider, List<Anime>>(
      (p) => p.recommendations,
    );

    if (state == FetchState.loading) {
      return const RecommendationListSkeleton();
    }

    if (state == FetchState.error || recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You Might Also Like',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              // Each recommendation card gets a unique Hero tag
              // so tapping it animates the poster into the next
              // detail screen.
              final recHeroTag = 'rec_hero_${rec.malId}';

              return GestureDetector(
                onTap: () async {
                  final animeProvider = context.read<AnimeProvider>();
                  try {
                    final fullAnime =
                        await animeProvider.getAnimeDetails(rec.malId);
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      ScaleFadePageRoute(
                        page: DetailScreen(
                          anime: fullAnime,
                          heroTag: recHeroTag,
                        ),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to load anime details.'),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimeImage(
                        imageUrl: rec.imageUrl,
                        width: 130,
                        height: 180,
                        heroTag: recHeroTag,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 130,
                        child: Text(
                          rec.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}