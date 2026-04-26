import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';
import 'package:anime_discovery/providers/theme_provider.dart';
import 'package:anime_discovery/widgets/anime_card_skeleton.dart';
import 'package:anime_discovery/widgets/anime_list_tile.dart';
import 'package:anime_discovery/widgets/skeleton_loader.dart';
import 'package:anime_discovery/widgets/error_view.dart';
import 'package:anime_discovery/widgets/filter_sheet.dart';
import 'package:anime_discovery/widgets/anime_image.dart';
import 'package:anime_discovery/widgets/pagination_indicator.dart';
import 'package:anime_discovery/router/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // FIX: Keep state alive so re-visiting tab does not re-fetch
  @override
  bool get wantKeepAlive => true;

  static const Duration _scrollDebounceDuration =
      Duration(milliseconds: 150);

  final ScrollController _scrollController = ScrollController();
  bool _isGridView = false;
  Timer? _scrollDebounce;
  bool _hasFetched = false; // FIX: Only fetch once

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // FIX: Defer fetch to after first frame only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched && mounted) {
        _hasFetched = true;
        context.read<AnimeProvider>().fetchTopAnime();
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
      if (provider.topAnimeState != FetchState.loaded) return;
      if (!provider.hasMoreTopAnime) return;
      provider.fetchTopAnime(loadMore: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final provider = context.read<AnimeProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      builder: (_) => FilterSheet(
        currentFilter: provider.currentFilter,
        onApply: (filter) => provider.applyFilter(filter),
        onClear: () => provider.clearFilter(),
      ),
    );
  }

  void _openDetail(BuildContext context, Anime anime, String heroTag) {
    context.push(
      RouteNames.animeDetailPath(anime.malId),
      extra: anime,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DISCONIME',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 26),
        ),
        leading: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () =>
                  themeProvider.toggleTheme(!themeProvider.isDarkMode),
            );
          },
        ),
        actions: [
          _FilterActionButton(onPressed: _showFilterSheet),
          IconButton(
            icon: Icon(
              _isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            onPressed: () =>
                setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: _TopAnimeBody(
        isGridView: _isGridView,
        scrollController: _scrollController,
        onAnimeSelected: _openDetail,
      ),
    );
  }
}

// ── Filter action button ──────────────────────────────────────────
class _FilterActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _FilterActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = context.select<AnimeProvider, bool>(
      (p) => p.currentFilter.isActive,
    );
    final activeFilterCount = context.select<AnimeProvider, int>(
      (p) => p.currentFilter.activeCount,
    );
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            hasActiveFilter
                ? Icons.tune_rounded
                : Icons.tune_outlined,
          ),
          tooltip: 'Filter',
          onPressed: onPressed,
        ),
        if (activeFilterCount > 0)
          Positioned(
            right: 6,
            top: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  activeFilterCount.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────
class _TopAnimeBody extends StatelessWidget {
  final bool isGridView;
  final ScrollController scrollController;
  final void Function(BuildContext, Anime, String) onAnimeSelected;

  const _TopAnimeBody({
    required this.isGridView,
    required this.scrollController,
    required this.onAnimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final topAnime = context.select<AnimeProvider, List<Anime>>(
      (p) => p.topAnime,
    );
    final topAnimeState = context.select<AnimeProvider, FetchState>(
      (p) => p.topAnimeState,
    );
    final errorMessage = context.select<AnimeProvider, String>(
      (p) => p.topAnimeErrorMessage,
    );
    final hasMore = context.select<AnimeProvider, bool>(
      (p) => p.hasMoreTopAnime,
    );
    final currentPage = context.select<AnimeProvider, int>(
      (p) => p.currentTopPage,
    );

    if (topAnimeState == FetchState.initial ||
        (topAnimeState == FetchState.loading && topAnime.isEmpty)) {
      return const AnimeListSkeleton();
    }

    if (topAnimeState == FetchState.error && topAnime.isEmpty) {
      return ErrorView(
        message: errorMessage,
        onRetry: () =>
            context.read<AnimeProvider>().fetchTopAnime(),
      );
    }

    return Column(
      children: [
        PaginationIndicator(
          loadedCount: topAnime.length,
          isLoading: topAnimeState == FetchState.loading,
          hasMore: hasMore,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<AnimeProvider>().fetchTopAnime(),
            child: isGridView
                ? _TopAnimeGridView(
                    topAnime: topAnime,
                    topAnimeState: topAnimeState,
                    scrollController: scrollController,
                    currentPage: currentPage,
                    hasMore: hasMore,
                    onAnimeSelected: onAnimeSelected,
                  )
                : _TopAnimeListView(
                    topAnime: topAnime,
                    topAnimeState: topAnimeState,
                    errorMessage: errorMessage,
                    scrollController: scrollController,
                    currentPage: currentPage,
                    hasMore: hasMore,
                    onAnimeSelected: onAnimeSelected,
                  ),
          ),
        ),
      ],
    );
  }
}

// ── List view ─────────────────────────────────────────────────────
class _TopAnimeListView extends StatelessWidget {
  final List<Anime> topAnime;
  final FetchState topAnimeState;
  final String errorMessage;
  final ScrollController scrollController;
  final int currentPage;
  final bool hasMore;
  final void Function(BuildContext, Anime, String) onAnimeSelected;

  const _TopAnimeListView({
    required this.topAnime,
    required this.topAnimeState,
    required this.errorMessage,
    required this.scrollController,
    required this.currentPage,
    required this.hasMore,
    required this.onAnimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: topAnime.length +
          (topAnimeState == FetchState.loading ||
                  topAnimeState == FetchState.error
              ? 1
              : 0) +
          (topAnime.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == topAnime.length &&
            topAnimeState == FetchState.loading) {
          return const LoadMoreSkeleton();
        }
        if (index == topAnime.length &&
            topAnimeState == FetchState.error) {
          return ErrorView(
            message: errorMessage,
            onRetry: () => context
                .read<AnimeProvider>()
                .fetchTopAnime(loadMore: true),
            expand: false,
          );
        }
        if (index >= topAnime.length) {
          return PageCounter(
            currentPage: currentPage,
            isLoading: topAnimeState == FetchState.loading,
          );
        }
        final anime = topAnime[index];
        final heroTag = 'anime_hero_${anime.malId}';
        return AnimeListTile(
          anime: anime,
          showRank: true,
          heroTag: heroTag,
          onTap: () => onAnimeSelected(context, anime, heroTag),
        );
      },
    );
  }
}

// ── Grid view ─────────────────────────────────────────────────────
class _TopAnimeGridView extends StatelessWidget {
  final List<Anime> topAnime;
  final FetchState topAnimeState;
  final ScrollController scrollController;
  final int currentPage;
  final bool hasMore;
  final void Function(BuildContext, Anime, String) onAnimeSelected;

  const _TopAnimeGridView({
    required this.topAnime,
    required this.topAnimeState,
    required this.scrollController,
    required this.currentPage,
    required this.hasMore,
    required this.onAnimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: topAnime.length +
          (topAnimeState == FetchState.loading ||
                  topAnimeState == FetchState.error
              ? 2
              : 0),
      itemBuilder: (context, index) {
        if (index >= topAnime.length &&
            topAnimeState == FetchState.loading) {
          return const SkeletonLoader(child: AnimeCardSkeleton());
        }
        if (index >= topAnime.length &&
            topAnimeState == FetchState.error) {
          if (index == topAnime.length) {
            return ErrorView(
              message: context
                  .read<AnimeProvider>()
                  .topAnimeErrorMessage,
              onRetry: () => context
                  .read<AnimeProvider>()
                  .fetchTopAnime(loadMore: true),
              expand: false,
            );
          }
          return const SizedBox.shrink();
        }
        final anime = topAnime[index];
        final heroTag = 'anime_hero_${anime.malId}';
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onAnimeSelected(context, anime, heroTag),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimeImage(
                  imageUrl: anime.imageUrl,
                  width: double.infinity,
                  heroTag: heroTag,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                anime.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${anime.score.value ?? 'N/A'} ★',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}