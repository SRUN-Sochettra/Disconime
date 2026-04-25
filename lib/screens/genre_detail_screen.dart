import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../widgets/anime_image.dart';
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AnimeProvider>();
      if (provider.genreAnimeState != FetchState.loading) {
        provider.fetchAnimeByGenre(
          widget.genreId,
          widget.genreName,
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(widget.genreName)),
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
              message: provider.errorMessage,
              onRetry: () => provider.fetchAnimeByGenre(
                  widget.genreId, widget.genreName),
            );
          }

          if (provider.genreAnimeState == FetchState.loaded &&
              provider.genreAnime.isEmpty) {
            return Center(
              child: Text(
                'No anime found.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAnimeByGenre(
                widget.genreId, widget.genreName),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.genreAnime.length +
                  (provider.genreAnimeState == FetchState.loading ||
                          provider.genreAnimeState == FetchState.error
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == provider.genreAnime.length &&
                    provider.genreAnimeState == FetchState.loading) {
                  return const LoadMoreSkeleton();
                }

                if (index == provider.genreAnime.length &&
                    provider.genreAnimeState == FetchState.error) {
                  return ErrorView(
                    message: provider.errorMessage,
                    onRetry: () => provider.fetchAnimeByGenre(
                      widget.genreId,
                      widget.genreName,
                      loadMore: true,
                    ),
                    expand: false,
                  );
                }

                final Anime item = provider.genreAnime[index];
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