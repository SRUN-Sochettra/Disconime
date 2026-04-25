import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../widgets/anime_list_tile.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/error_view.dart';
import '../widgets/pagination_indicator.dart';
import '../widgets/empty_state.dart';
import '../router/route_names.dart';

class SeasonalScreen extends StatefulWidget {
  const SeasonalScreen({super.key});

  @override
  State<SeasonalScreen> createState() => _SeasonalScreenState();
}

class _SeasonalScreenState extends State<SeasonalScreen> {
  final ScrollController _scrollController = ScrollController();
  static const List<String> _seasons = ['winter', 'spring', 'summer', 'fall'];

  static const Duration _scrollDebounceDuration = Duration(milliseconds: 150);
  Timer? _scrollDebounce;
  bool _isLoadMoreArmed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeProvider>().fetchSeasonalAnime();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    if (position.extentAfter > 200) {
      _isLoadMoreArmed = true;
      _scrollDebounce?.cancel();
      return;
    }

    if (!_isLoadMoreArmed || (_scrollDebounce?.isActive ?? false)) return;

    _isLoadMoreArmed = false;
    _scrollDebounce = Timer(_scrollDebounceDuration, () {
      if (!mounted) return;
      final provider = context.read<AnimeProvider>();
      if (provider.seasonalState != FetchState.loading &&
          provider.hasMoreSeasonalAnime) {
        provider.fetchSeasonalAnime(
          year: provider.selectedYear,
          season: provider.selectedSeason,
          loadMore: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollDebounce?.cancel();
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
            final theme = Theme.of(builderContext);
            final primary = theme.colorScheme.primary;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Season',
                          style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: () {
                          provider.fetchSeasonalAnime();
                          Navigator.pop(builderContext);
                        },
                        child: Text(
                          'Current Season',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('YEAR', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: years.map((year) {
                      final isSelected = pickedYear == year;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => pickedYear = year),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
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
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Text(
                            year.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('SEASON', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _seasons.map((season) {
                      final isSelected = pickedSeason == season;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => pickedSeason = season),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
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
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Text(
                            season[0].toUpperCase() + season.substring(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          (pickedYear != null && pickedSeason != null)
                              ? () {
                                  provider.fetchSeasonalAnime(
                                    year: pickedYear,
                                    season: pickedSeason,
                                  );
                                  Navigator.pop(builderContext);
                                }
                              : null,
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Load Season',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    return Scaffold(
      appBar: AppBar(
        title: context.select<AnimeProvider, Widget>(
          (p) => Text(p.seasonLabel),
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
          if (provider.seasonalState == FetchState.initial ||
              (provider.seasonalState == FetchState.loading &&
                  provider.seasonalAnime.isEmpty)) {
            return const AnimeListSkeleton();
          }

          if (provider.seasonalState == FetchState.error &&
              provider.seasonalAnime.isEmpty) {
            return ErrorView(
              message: provider.seasonalErrorMessage,
              onRetry: () => provider.fetchSeasonalAnime(
                year: provider.selectedYear,
                season: provider.selectedSeason,
              ),
            );
          }

          if (provider.seasonalState == FetchState.loaded &&
              provider.seasonalAnime.isEmpty) {
            return EmptyState(
              type: EmptyStateType.seasonal,
              onAction: _showSeasonPicker,
              actionLabel: 'Change Season',
            );
          }

          return Column(
            children: [
              PaginationIndicator(
                loadedCount: provider.seasonalAnime.length,
                isLoading:
                    provider.seasonalState == FetchState.loading,
                hasMore: provider.hasMoreSeasonalAnime,
              ),
              Expanded(
                child: RefreshIndicator(
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
                            : 0) +
                        (provider.seasonalAnime.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.seasonalAnime.length &&
                          provider.seasonalState == FetchState.loading) {
                        return const LoadMoreSkeleton();
                      }

                      if (index == provider.seasonalAnime.length &&
                          provider.seasonalState == FetchState.error) {
                        return ErrorView(
                          message: provider.seasonalErrorMessage,
                          onRetry: () => provider.fetchSeasonalAnime(
                            year: provider.selectedYear,
                            season: provider.selectedSeason,
                            loadMore: true,
                          ),
                          expand: false,
                        );
                      }

                      if (index >= provider.seasonalAnime.length) {
                        return PageCounter(
                          currentPage: provider.currentSeasonalPage,
                          isLoading: provider.seasonalState ==
                              FetchState.loading,
                        );
                      }

                      final Anime item = provider.seasonalAnime[index];
                      final heroTag = 'seasonal_hero_${item.malId}';
                      return AnimeListTile(
                        anime: item,
                        showTypeBadge: true,
                        heroTag: heroTag,
                        onTap: () => context.push(
                          RouteNames.animeDetailPath(item.malId),
                          extra: item,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}