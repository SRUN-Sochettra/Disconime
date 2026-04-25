import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_view.dart';
import '../widgets/filter_sheet.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeProvider>().fetchTopAnime();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      final provider = context.read<AnimeProvider>();
      if (provider.topAnimeState != FetchState.loading) {
        provider.fetchTopAnime(loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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

  @override
  Widget build(BuildContext context) {
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
          // ── Filter button with active badge ──────────────────
          Consumer<AnimeProvider>(
            builder: (context, provider, child) {
              final count = provider.currentFilter.activeCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      provider.currentFilter.isActive
                          ? Icons.tune_rounded
                          : Icons.tune_outlined,
                    ),
                    tooltip: 'Filter',
                    onPressed: _showFilterSheet,
                  ),
                  if (count > 0)
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
                            count.toString(),
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
            },
          ),

          // ── View toggle ───────────────────────────────────────
          IconButton(
            icon: Icon(
              _isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          if (provider.topAnimeState == FetchState.initial ||
              (provider.topAnimeState == FetchState.loading &&
                  provider.topAnime.isEmpty)) {
            return const AnimeListSkeleton();
          }

          if (provider.topAnimeState == FetchState.error &&
              provider.topAnime.isEmpty) {
            return ErrorView(
              message: provider.errorMessage,
              onRetry: () => provider.fetchTopAnime(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTopAnime(),
            child: _isGridView
                ? _buildGrid(context, provider)
                : _buildList(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, AnimeProvider provider) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.topAnime.length +
          (provider.topAnimeState == FetchState.loading ||
                  provider.topAnimeState == FetchState.error
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index == provider.topAnime.length &&
            provider.topAnimeState == FetchState.loading) {
          return const LoadMoreSkeleton();
        }
        if (index == provider.topAnime.length &&
            provider.topAnimeState == FetchState.error) {
          return ErrorView(
            message: provider.errorMessage,
            onRetry: () => provider.fetchTopAnime(loadMore: true),
            expand: false,
          );
        }

        final Anime anime = provider.topAnime[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(anime: anime)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimeImage(imageUrl: anime.imageUrl, width: 100, height: 140),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        anime.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (anime.genres.isNotEmpty)
                        Text(
                          anime.genres.take(3).join(' • '),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            anime.score.value?.toString() ?? 'N/A',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '#${anime.score.rank ?? '?'} Rank',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
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
    );
  }

  Widget _buildGrid(BuildContext context, AnimeProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.topAnime.length +
          (provider.topAnimeState == FetchState.loading ? 2 : 0),
      itemBuilder: (context, index) {
        // ── Grid load-more skeleton ───────────────────────────
        if (index >= provider.topAnime.length) {
          return const SkeletonLoader(child: AnimeCardSkeleton());
        }

        final Anime anime = provider.topAnime[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(anime: anime)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimeImage(
                  imageUrl: anime.imageUrl,
                  width: double.infinity,
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