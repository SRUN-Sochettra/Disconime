import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/error_view.dart';

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
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SYS.INFO'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, child) {
              final isFav = favProvider.isFavorite(anime.malId);
              return IconButton(
                tooltip:
                    isFav ? 'Remove from favorites' : 'Add to favorites',
                icon: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_outline,
                  color: primary,
                ),
                onPressed: () => favProvider.toggleFavorite(anime),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            16.0, kToolbarHeight + 40, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ─────────────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: primary, width: 2),
                ),
                child: AnimeImage(
                  imageUrl: anime.imageUrl,
                  size: AnimeImageSize.large,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Titles ─────────────────────────────────────────────
            _buildPanel(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'TITLES'),
                  const SizedBox(height: 10),
                  _buildInfoRow(context, 'MAIN', anime.title),
                  if (anime.titleEnglish != null &&
                      anime.titleEnglish!.isNotEmpty &&
                      anime.titleEnglish != anime.title)
                    _buildInfoRow(context, 'EN', anime.titleEnglish!),
                  if (anime.titleJapanese != null &&
                      anime.titleJapanese!.isNotEmpty)
                    _buildInfoRow(context, 'JP', anime.titleJapanese!),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Stats ──────────────────────────────────────────────
            _buildPanel(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'STATS'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          context,
                          label: 'SCORE',
                          value: anime.score.value?.toStringAsFixed(2) ??
                              'N/A',
                          icon: Icons.star_outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          context,
                          label: 'RANK',
                          value: anime.score.rank != null
                              ? '#${anime.score.rank}'
                              : 'N/A',
                          icon: Icons.leaderboard_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          context,
                          label: 'POPULAR',
                          value: anime.score.popularity != null
                              ? '#${anime.score.popularity}'
                              : 'N/A',
                          icon: Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                  if (anime.score.scoredBy != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      context,
                      'SCORED BY',
                      '${_formatNumber(anime.score.scoredBy!)} users',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Info ───────────────────────────────────────────────
            _buildPanel(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'INFO'),
                  const SizedBox(height: 10),
                  if (anime.type != null)
                    _buildInfoRow(context, 'TYPE', anime.type!),
                  if (anime.status != null)
                    _buildInfoRow(context, 'STATUS', anime.status!),
                  if (anime.episodes != null)
                    _buildInfoRow(
                        context, 'EPISODES', anime.episodes.toString()),
                  if (anime.duration != null)
                    _buildInfoRow(context, 'DURATION', anime.duration!),
                  if (anime.rating != null)
                    _buildInfoRow(context, 'RATING', anime.rating!),
                  if (anime.year != null)
                    _buildInfoRow(context, 'YEAR', anime.year!),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Genres ─────────────────────────────────────────────
            if (anime.genres.isNotEmpty) ...[
              _buildPanel(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'GENRES'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anime.genres
                          .map((genre) => _buildGenreChip(context, genre))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Synopsis ───────────────────────────────────────────
            _buildPanel(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'SYNOPSIS'),
                  const SizedBox(height: 10),
                  Text(
                    anime.synopsis.text.isEmpty
                        ? 'No synopsis available.'
                        : anime.synopsis.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (anime.synopsis.background != null &&
                      anime.synopsis.background!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionHeader(context, 'BACKGROUND'),
                    const SizedBox(height: 10),
                    Text(
                      anime.synopsis.background!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── Recommendations ────────────────────────────────────
            Consumer<AnimeProvider>(
              builder: (context, provider, child) {
                final isLoading =
                    provider.recommendationsState == FetchState.loading;
                final hasError =
                    provider.recommendationsState == FetchState.error;
                final isEmpty = provider.recommendations.isEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmpty && !isLoading
                          ? '> SIMILAR_DATA: NOT_FOUND'
                          : '> SIMILAR_DATA',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (isLoading && isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: primary),
                        ),
                      )
                    else if (hasError && isEmpty)
                      ErrorView(
                        message: provider.errorMessage,
                        onRetry: () => context
                            .read<AnimeProvider>()
                            .fetchRecommendations(anime.malId),
                        expand: false,
                      )
                    else if (!isEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.recommendations.length,
                          itemBuilder: (context, index) {
                            final rec = provider.recommendations[index];
                            return GestureDetector(
                              onTap: () async {
                                final animeProvider =
                                    context.read<AnimeProvider>();
                                try {
                                  final fullAnime = await animeProvider
                                      .getAnimeDetails(rec.malId);
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailScreen(anime: fullAnime),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            '[ERROR]: FAILED_TO_RETRIEVE_DATA'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 16),
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withAlpha(100),
                                        border: Border.all(
                                            color: primary, width: 1),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: AnimeImage(
                                              imageUrl: rec.imageUrl,
                                              size: AnimeImageSize.medium,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.all(8.0),
                                            child: Text(
                                              rec.title,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, {required Widget child}) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(100),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String label) {
    return Text(
      '> $label',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '[$label]',
              style: GoogleFonts.spaceMono(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.spaceMono(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: primary.withAlpha(128), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceMono(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(BuildContext context, String genre) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: primary, width: 1),
        color: primary.withAlpha(20),
      ),
      child: Text(
        genre,
        style: GoogleFonts.spaceMono(
          color: primary,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}