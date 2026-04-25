import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import '../providers/search_history_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/anime_card_skeleton.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AnimeProvider>();
      if (provider.searchState != FetchState.loading &&
          _controller.text.isNotEmpty) {
        provider.searchAnime(_controller.text, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    FocusScope.of(context).unfocus();
    if (query.isNotEmpty) {
      context.read<SearchHistoryProvider>().addQuery(query);
      context.read<AnimeProvider>().searchAnime(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('SEARCH')),
      body: Column(
        children: [
          // ── Search field ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(),
              onSubmitted: _performSearch,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search_rounded, color: primary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          context.read<AnimeProvider>().searchAnime('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withAlpha(30),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Results / History ─────────────────────────────
          Expanded(
            child: Consumer<AnimeProvider>(
              builder: (context, provider, child) {
                if (provider.searchState == FetchState.initial) {
                  return _buildHistory(context);
                }

                if (provider.searchState == FetchState.loading &&
                    provider.searchResults.isEmpty) {
                  return const AnimeListSkeleton();
                }

                if (provider.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.searchResults.length +
                      (provider.searchState == FetchState.loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.searchResults.length) {
                      return const LoadMoreSkeleton();
                    }

                    final Anime anime = provider.searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(anime: anime),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimeImage(
                              imageUrl: anime.imageUrl,
                              width: 100,
                              height: 140,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    anime.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  if (anime.genres.isNotEmpty)
                                    Text(
                                      anime.genres.take(3).join(' • '),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded,
                                          color: primary, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        anime.score.value?.toString() ??
                                            'N/A',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<SearchHistoryProvider>(
      builder: (context, historyProvider, child) {
        if (historyProvider.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: theme.colorScheme.onSurface.withAlpha(60),
                ),
                const SizedBox(height: 16),
                Text('Search for anime',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Your recent searches will appear here.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Searches',
                      style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: () => historyProvider.clearHistory(),
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: historyProvider.history.length,
                itemBuilder: (context, index) {
                  final query = historyProvider.history[index];
                  return ListTile(
                    leading: Icon(
                      Icons.history_rounded,
                      color: theme.colorScheme.onSurface.withAlpha(100),
                    ),
                    title: Text(query, style: theme.textTheme.bodyMedium),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      onPressed: () =>
                          historyProvider.removeQuery(query),
                    ),
                    onTap: () {
                      _controller.text = query;
                      _performSearch(query);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}