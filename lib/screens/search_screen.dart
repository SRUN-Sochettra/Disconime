import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/providers/anime_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';

import 'package:anime_discovery/providers/search_history_provider.dart';
import 'package:anime_discovery/widgets/anime_card_skeleton.dart';
import 'package:anime_discovery/widgets/anime_list_tile.dart';
import 'package:anime_discovery/widgets/error_view.dart';
import 'package:anime_discovery/widgets/pagination_indicator.dart';
import 'package:anime_discovery/widgets/empty_state.dart';
import 'package:anime_discovery/router/route_names.dart';

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

  static const Duration _typingDebounceDuration = Duration(milliseconds: 500);
  Timer? _typingDebounce;

  final ValueNotifier<bool> _hasText = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    _hasText.value = text.isNotEmpty;
    _typingDebounce?.cancel();

    if (text.isEmpty) {
      context.read<AnimeProvider>().searchAnime('');
      return;
    }

    _typingDebounce = Timer(_typingDebounceDuration, () {
      if (!mounted) return;
      context.read<AnimeProvider>().searchAnime(text);
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
      if (provider.searchState != FetchState.loading &&
          _controller.text.isNotEmpty &&
          provider.hasMoreSearchResults) {
        provider.searchAnime(_controller.text, loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.removeListener(_onTextChanged);
    _typingDebounce?.cancel();
    _scrollDebounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _hasText.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    if (query.isNotEmpty) {
      context.read<SearchHistoryProvider>().addQuery(query);
      context.read<AnimeProvider>().searchAnime(query);
    }
  }

  void _openDetail(Anime anime) {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchHistoryProvider>().addQuery(query);
    }
    context.push(
      RouteNames.animeDetailPath(anime.malId),
      extra: anime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('SEARCH')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium,
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search_rounded, color: primary),
                suffixIcon: ValueListenableBuilder<bool>(
                  valueListenable: _hasText,
                  builder: (_, hasText, __) => hasText
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => _controller.clear(),
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
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
          ),
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
                  return EmptyState(
                    type: EmptyStateType.searchNoResults,
                    subtitle:
                        'No results for "${_controller.text}".\nTry a different term.',
                    onAction: () => _controller.clear(),
                    actionLabel: 'Clear Search',
                  );
                }

                return Column(
                  children: [
                    PaginationIndicator(
                      loadedCount: provider.searchResults.length,
                      isLoading:
                          provider.searchState == FetchState.loading,
                      hasMore: provider.hasMoreSearchResults,
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.searchResults.length +
                            (provider.searchState == FetchState.loading
                                ? 1
                                : 0) +
                            (provider.searchResults.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.searchResults.length &&
                              provider.searchState ==
                                  FetchState.loading) {
                            return const LoadMoreSkeleton();
                          }

                          if (index >= provider.searchResults.length) {
                            return PageCounter(
                              currentPage: provider.currentSearchPage,
                              isLoading: provider.searchState ==
                                  FetchState.loading,
                            );
                          }

                          final Anime anime =
                              provider.searchResults[index];
                          final heroTag = 'search_hero_${anime.malId}';
                          return AnimeListTile(
                            anime: anime,
                            heroTag: heroTag,
                            onTap: () => _openDetail(anime),
                          );
                        },
                      ),
                    ),
                  ],
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
          return const EmptyState(type: EmptyStateType.search);
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
                      color:
                          theme.colorScheme.onSurface.withAlpha(100),
                    ),
                    title: Text(query,
                        style: theme.textTheme.bodyMedium),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color:
                            theme.colorScheme.onSurface.withAlpha(100),
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