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
import '../widgets/sub_page_app_bar.dart';
import '../router/route_names.dart';
import '../widgets/view_toggle.dart';
import '../widgets/anime_image.dart';
import '../widgets/skeleton_loader.dart';

class GenreDetailScreen extends StatefulWidget {
  final int genreId;
  final String genreName;

  const GenreDetailScreen({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = false;

  static const Duration _scrollDebounceDuration = Duration(milliseconds: 150);
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AnimeProvider>()
          .fetchAnimeByGenre(widget.genreId, widget.genreName);
    });
    _scrollController.addListener(_onScroll);
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
      if (provider.genreAnimeState != FetchState.loading &&
          provider.hasMoreGenreAnime) {
        provider.fetchAnimeByGenre(
          widget.genreId,
          widget.genreName,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubPageAppBar(
        title: widget.genreName,
        actions: [
          ViewToggleButton(
            isGridView: _isGridView,
            onToggle: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          if (provider.genreAnimeState == FetchState.initial ||
              (provider.genreAnimeState == FetchState.loading &&
                  provider.genreAnime.isEmpty)) {
            return const AnimeListSkeleton();
          }

          if (provider.genreAnimeState == FetchState.error &&
              provider.genreAnime.isEmpty) {
            return ErrorView(
              message: provider.genreAnimeErrorMessage,
              onRetry: () => provider.fetchAnimeByGenre(
                widget.genreId,
                widget.genreName,
              ),
            );
          }

          if (provider.genreAnimeState == FetchState.loaded &&
              provider.genreAnime.isEmpty) {
            return EmptyState(
              type: EmptyStateType.genreDetail,
              onAction: () => context.pop(),
              actionLabel: 'Go Back',
            );
          }

          return Column(
            children: [
              PaginationIndicator(
                loadedCount: provider.genreAnime.length,
                isLoading:
                    provider.genreAnimeState == FetchState.loading,
                hasMore: provider.hasMoreGenreAnime,
              ),
              Expanded(
                child: _isGridView
                    ? _buildGridView(provider)
                    : _buildListView(provider),
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
      itemCount: provider.genreAnime.length +
          (provider.genreAnimeState == FetchState.loading ||
                  provider.genreAnimeState == FetchState.error
              ? 1
              : 0) +
          (provider.genreAnime.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.genreAnime.length &&
            provider.genreAnimeState == FetchState.loading) {
          return const LoadMoreSkeleton();
        }

        if (index == provider.genreAnime.length &&
            provider.genreAnimeState == FetchState.error) {
          return ErrorView(
            message: provider.genreAnimeErrorMessage,
            onRetry: () => provider.fetchAnimeByGenre(
              widget.genreId,
              widget.genreName,
              loadMore: true,
            ),
            expand: false,
          );
        }

        if (index >= provider.genreAnime.length) {
          return PageCounter(
            currentPage: provider.currentGenrePage,
            isLoading: provider.genreAnimeState == FetchState.loading,
          );
        }

        final Anime item = provider.genreAnime[index];
        final heroTag = 'genre_hero_${item.malId}';
        return AnimeListTile(
          anime: item,
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
      itemCount: provider.genreAnime.length +
          (provider.genreAnimeState == FetchState.loading ||
                  provider.genreAnimeState == FetchState.error
              ? 2
              : 0),
      itemBuilder: (context, index) {
        if (index >= provider.genreAnime.length &&
            provider.genreAnimeState == FetchState.loading) {
          return const SkeletonLoader(child: AnimeCardSkeleton());
        }

        if (index >= provider.genreAnime.length &&
            provider.genreAnimeState == FetchState.error) {
          if (index == provider.genreAnime.length) {
            return ErrorView(
              message: provider.genreAnimeErrorMessage,
              onRetry: () => provider.fetchAnimeByGenre(
                widget.genreId,
                widget.genreName,
                loadMore: true,
              ),
              expand: false,
            );
          }
          return const SizedBox.shrink();
        }

        final item = provider.genreAnime[index];
        final heroTag = 'genre_hero_${item.malId}';
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