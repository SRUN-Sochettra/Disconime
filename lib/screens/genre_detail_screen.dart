import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../widgets/anime_list_tile.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/error_view.dart';
import 'detail_screen.dart';

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

  // FIX: Added the same debounce + armed-flag pattern used in
  // HomeScreen so load-more does not fire on every scroll event
  // that passes the threshold.
  static const Duration _scrollDebounceDuration = Duration(milliseconds: 150);
  Timer? _scrollDebounce;
  bool _isLoadMoreArmed = true;

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
      if (provider.genreAnimeState != FetchState.loading) {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genreName),
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          // ── Initial / full-screen loading ─────────────────────
          if (provider.genreAnimeState == FetchState.initial ||
              (provider.genreAnimeState == FetchState.loading &&
                  provider.genreAnime.isEmpty)) {
            return const AnimeListSkeleton();
          }

          // ── Full-screen error ─────────────────────────────────
          if (provider.genreAnimeState == FetchState.error &&
              provider.genreAnime.isEmpty) {
            return ErrorView(
              // FIX: Use dedicated genreAnimeErrorMessage instead
              // of the shared errorMessage field.
              message: provider.genreAnimeErrorMessage,
              onRetry: () => provider.fetchAnimeByGenre(
                widget.genreId,
                widget.genreName,
              ),
            );
          }

          // ── Empty state ───────────────────────────────────────
          if (provider.genreAnimeState == FetchState.loaded &&
              provider.genreAnime.isEmpty) {
            return Center(
              child: Text(
                'No anime found.',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAnimeByGenre(
              widget.genreId,
              widget.genreName,
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.genreAnime.length +
                  (provider.genreAnimeState == FetchState.loading ||
                          provider.genreAnimeState == FetchState.error
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                // ── Load-more skeleton ────────────────────────
                if (index == provider.genreAnime.length &&
                    provider.genreAnimeState == FetchState.loading) {
                  return const LoadMoreSkeleton();
                }

                // ── Inline error ──────────────────────────────
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

                final Anime item = provider.genreAnime[index];
                // FIX: Replaced duplicated inline Row layout with
                // the shared AnimeListTile widget.
                return AnimeListTile(
                  anime: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(anime: item),
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