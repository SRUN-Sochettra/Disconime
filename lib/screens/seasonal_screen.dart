import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';

import '../widgets/anime_list_tile.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/error_view.dart';
import '../widgets/pagination_indicator.dart';
import '../widgets/empty_state.dart';
import '../router/route_names.dart';
import 'package:anime_discovery/widgets/section_app_bar.dart';
import 'package:anime_discovery/widgets/view_toggle.dart';
import 'package:anime_discovery/widgets/anime_image.dart';
import 'package:anime_discovery/widgets/skeleton_loader.dart';

class SeasonalScreen extends StatefulWidget {
  const SeasonalScreen({super.key});

  @override
  State<SeasonalScreen> createState() => _SeasonalScreenState();
}

class _SeasonalScreenState extends State<SeasonalScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _hasFetched = false;
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();
  static const List<String> _seasons = ['winter', 'spring', 'summer', 'fall'];

  static const Duration _scrollDebounceDuration = Duration(milliseconds: 150);
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched && mounted) {
        _hasFetched = true;
        context.read<AnimeProvider>().fetchSeasonalAnime();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    if (position.pixels < position.maxScrollExtent - 200) {
      _scrollDebounce?.cancel();
      return;
    }

    if (_scrollDebounce?.isActive ?? false) return;

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
    super.build(context);
    return Scaffold(
      appBar: SectionAppBar(
        title: 'Seasonal',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Select season',
            onPressed: _showSeasonPicker,
          ),
          ViewToggleButton(
            isGridView: _isGridView,
            onToggle: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 8),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SeasonContextChip(
                label: provider.seasonLabel,
                onTap: _showSeasonPicker,
              ),
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
                  child: _isGridView
                      ? _buildGridView(provider)
                      : _buildListView(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView(AnimeProvider provider) {
    return ListView.builder(
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
            isLoading: provider.seasonalState == FetchState.loading,
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
    );
  }

  Widget _buildGridView(AnimeProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.seasonalAnime.length +
          (provider.seasonalState == FetchState.loading ||
                  provider.seasonalState == FetchState.error
              ? 2
              : 0),
      itemBuilder: (context, index) {
        if (index >= provider.seasonalAnime.length &&
            provider.seasonalState == FetchState.loading) {
          return const SkeletonLoader(child: AnimeCardSkeleton());
        }

        if (index >= provider.seasonalAnime.length &&
            provider.seasonalState == FetchState.error) {
          if (index == provider.seasonalAnime.length) {
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
          return const SizedBox.shrink();
        }

        final item = provider.seasonalAnime[index];
        final heroTag = 'seasonal_hero_${item.malId}';
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(
            RouteNames.animeDetailPath(item.malId),
            extra: item,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimeImage(
                  imageUrl: item.imageUrl,
                  width: double.infinity,
                  heroTag: heroTag,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${item.score.value ?? 'N/A'} ★',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeasonContextChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SeasonContextChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(40),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}