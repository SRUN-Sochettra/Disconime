import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/error_view.dart';
import 'detail_screen.dart';

class SeasonalScreen extends StatefulWidget {
  const SeasonalScreen({super.key});

  @override
  State<SeasonalScreen> createState() => _SeasonalScreenState();
}

class _SeasonalScreenState extends State<SeasonalScreen> {
  final ScrollController _scrollController = ScrollController();
  static const List<String> _seasons = ['winter', 'spring', 'summer', 'fall'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeProvider>().fetchSeasonalAnime();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AnimeProvider>();
      if (provider.seasonalState != FetchState.loading) {
        provider.fetchSeasonalAnime(
          year: provider.selectedYear,
          season: provider.selectedSeason,
          loadMore: true,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _showSeasonPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (i) => currentYear - i);
    final provider = context.read<AnimeProvider>();

    int? pickedYear = provider.selectedYear;
    String? pickedSeason = provider.selectedSeason;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            final primary = Theme.of(builderContext).colorScheme.primary;

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(builderContext).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Handle ─────────────────────────────────
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(128),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Header ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Season',
                        style: Theme.of(builderContext).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          provider.fetchSeasonalAnime();
                          Navigator.pop(builderContext);
                        },
                        child: const Text('Current Season'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Year ───────────────────────────────────
                  Text(
                    'YEAR',
                    style: Theme.of(builderContext).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: years.map((year) {
                      final isSelected = pickedYear == year;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => pickedYear = year),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withAlpha(20)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : Colors.grey.withAlpha(80),
                            ),
                          ),
                          child: Text(
                            year.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isSelected
                                  ? primary
                                  : Theme.of(builderContext)
                                      .colorScheme
                                      .onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── Season ─────────────────────────────────
                  Text(
                    'SEASON',
                    style: Theme.of(builderContext).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _seasons.map((season) {
                      final isSelected = pickedSeason == season;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => pickedSeason = season),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withAlpha(20)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : Colors.grey.withAlpha(80),
                            ),
                          ),
                          child: Text(
                            season[0].toUpperCase() + season.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isSelected
                                  ? primary
                                  : Theme.of(builderContext)
                                      .colorScheme
                                      .onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Apply Button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (pickedYear != null && pickedSeason != null)
                          ? () {
                              provider.fetchSeasonalAnime(
                                year: pickedYear,
                                season: pickedSeason,
                              );
                              Navigator.pop(builderContext);
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Load Season'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<AnimeProvider>(
          builder: (context, provider, child) =>
              Text(provider.seasonLabel),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Select season',
            onPressed: _showSeasonPicker,
          ),
        ],
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          // ── Skeleton ──────────────────────────────────────
          if (provider.seasonalState == FetchState.initial ||
              (provider.seasonalState == FetchState.loading &&
                  provider.seasonalAnime.isEmpty)) {
            return const AnimeListSkeleton();
          }

          // ── Full screen error ─────────────────────────────
          if (provider.seasonalState == FetchState.error &&
              provider.seasonalAnime.isEmpty) {
            return ErrorView(
              message: provider.errorMessage,
              onRetry: () => provider.fetchSeasonalAnime(
                year: provider.selectedYear,
                season: provider.selectedSeason,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchSeasonalAnime(
              year: provider.selectedYear,
              season: provider.selectedSeason,
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.seasonalAnime.length +
                  (provider.seasonalState == FetchState.loading ||
                          provider.seasonalState == FetchState.error
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                // ── Load more skeleton ──────────────────────
                if (index == provider.seasonalAnime.length &&
                    provider.seasonalState == FetchState.loading) {
                  return const LoadMoreSkeleton();
                }

                // ── Inline error ────────────────────────────
                if (index == provider.seasonalAnime.length &&
                    provider.seasonalState == FetchState.error) {
                  return ErrorView(
                    message: provider.errorMessage,
                    onRetry: () => provider.fetchSeasonalAnime(
                      year: provider.selectedYear,
                      season: provider.selectedSeason,
                      loadMore: true,
                    ),
                    expand: false,
                  );
                }

                final Anime item = provider.seasonalAnime[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(anime: item),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimeImage(
                          imageUrl: item.imageUrl,
                          width: 100,
                          height: 140,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (item.genres.isNotEmpty)
                                Text(
                                  item.genres.take(3).join(' • '),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: primary, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.score.value?.toString() ?? 'N/A',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // ── Type badge ──────────
                                  if (item.type != null) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: primary.withAlpha(80)),
                                      ),
                                      child: Text(
                                        item.type!,
                                        style: GoogleFonts.inter(
                                            fontSize: 11, color: primary),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}