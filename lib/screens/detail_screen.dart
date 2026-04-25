import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/anime_card_skeleton.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;
  const DetailScreen({super.key, required this.anime});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeProvider>().fetchRecommendations(widget.anime.malId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: CircleAvatar(
          backgroundColor: Colors.black.withAlpha(100),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                        ? Theme.of(context).colorScheme.primary
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
            // ── Hero Image ─────────────────────────────────────
            AnimeImage(
              imageUrl: anime.imageUrl,
              width: double.infinity,
              height: 450,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ─────────────────────────────────────
                  Text(
                    anime.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (anime.titleEnglish != null &&
                      anime.titleEnglish!.isNotEmpty &&
                      anime.titleEnglish != anime.title) ...[
                    const SizedBox(height: 4),
                    Text(
                      anime.titleEnglish!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (anime.titleJapanese != null &&
                      anime.titleJapanese!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      anime.titleJapanese!,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Stats ─────────────────────────────────────
                  Row(
                    children: [
                      _buildStatBadge(
                        context,
                        icon: Icons.star_rounded,
                        value: anime.score.value?.toStringAsFixed(1) ?? 'N/A',
                        label: 'Score',
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        context,
                        icon: Icons.leaderboard_rounded,
                        value: anime.score.rank != null
                            ? '#${anime.score.rank}'
                            : 'N/A',
                        label: 'Rank',
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        context,
                        icon: Icons.trending_up_rounded,
                        value: anime.score.popularity != null
                            ? '#${anime.score.popularity}'
                            : 'N/A',
                        label: 'Popular',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Genres ────────────────────────────────────
                  if (anime.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anime.genres
                          .map((g) => _buildGenreChip(context, g))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Synopsis ──────────────────────────────────
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    anime.synopsis.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // ── Info ──────────────────────────────────────
                  _buildInfoSection(context, anime),
                  const SizedBox(height: 32),

                  // ── Recommendations ───────────────────────────
                  _buildRecommendations(context, anime),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(100),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Anime anime) {
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
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
      addRow('Scored By', '${_formatNumber(anime.score.scoredBy!)} users');
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Information', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, Anime anime) {
    return Consumer<AnimeProvider>(
      builder: (context, provider, child) {
        if (provider.recommendationsState == FetchState.loading) {
          return const RecommendationListSkeleton();
        }
        if (provider.recommendations.isEmpty) {
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
                itemCount: provider.recommendations.length,
                itemBuilder: (context, index) {
                  final rec = provider.recommendations[index];
                  return GestureDetector(
                    onTap: () async {
                      final animeProvider = context.read<AnimeProvider>();
                      try {
                        final fullAnime =
                            await animeProvider.getAnimeDetails(rec.malId);
                        // Guard context across async gap using
                        // State.mounted check.
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(anime: fullAnime),
                          ),
                        );
                      } catch (_) {
                        if (!mounted) return;
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
      },
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}