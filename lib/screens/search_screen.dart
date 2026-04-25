import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/search_history_provider.dart';
import 'package:anime_discovery/widgets/anime_card_skeleton.dart';
import 'package:anime_discovery/widgets/anime_list_tile.dart';
import 'package:anime_discovery/widgets/error_view.dart';
import 'package:anime_discovery/screens/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const Duration _scrollDebounceDuration = Duration(milliseconds: 150);
  Timer? _scrollDebounce;
  bool _isLoadMoreArmed = true;

  final ValueNotifier<bool> _hasText = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.addListener(() {
      _hasText.value = _controller.text.isNotEmpty;
    });
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
      if (provider.searchState != FetchState.loading &&
          _controller.text.isNotEmpty) {
        provider.searchAnime(_controller.text, loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollDebounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _hasText.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    FocusScope.of(context).unfocus();
    if (query.isNotEmpty) {
      context.read<SearchHistoryProvider>().addQuery(query);
      context.read<AnimeProvider>().searchAnime(query);
      _isLoadMoreArmed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('SEARCH')),
      body: Column(
        children: [
          // ── Search field ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search_rounded, color: primary),
                suffixIcon: ValueListenableBuilder<bool>(
                  valueListenable: _hasText,
                  builder: (_, hasText, __) => hasText
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            context.read<AnimeProvider>().searchAnime('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.dividerColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Results / History ─────────────────────────────────
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

                if (provider.searchState == FetchState.error &&
                    provider.searchResults.isEmpty) {
                  return ErrorView(
                    message: provider.searchErrorMessage,
                    onRetry: () => context
                        .read<AnimeProvider>()
                        .searchAnime(_controller.text),
                  );
                }

                if (provider.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.searchResults.length +
                      (provider.searchState == FetchState.loading ? 1 : 0),
                  // FIX: __ → _ (unnecessary double underscore lint)
                  itemBuilder: (context, index) {
                    if (index == provider.searchResults.length) {
                      return const LoadMoreSkeleton();
                    }

                    final Anime anime = provider.searchResults[index];
                    return AnimeListTile(
                      anime: anime,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(anime: anime),
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

  // ── Search history ────────────────────────────────────────────
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
                Text(
                  'Search for anime',
                  style: theme.textTheme.titleMedium,
                ),
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
                  Text(
                    'Recent Searches',
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => historyProvider.clearHistory(),
                    child: Text(
                      'Clear all',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
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
                    title: Text(
                      query,
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      onPressed: () => historyProvider.removeQuery(query),
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