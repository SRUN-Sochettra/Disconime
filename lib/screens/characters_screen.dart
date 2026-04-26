import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../providers/characters_provider.dart';
import '../router/route_names.dart';
import '../widgets/anime_image.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/pagination_indicator.dart';
import '../widgets/skeleton_loader.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _hasFetched = false;
  final ScrollController _scrollController = ScrollController();

  static const Duration _scrollDebounceDuration =
      Duration(milliseconds: 150);

  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched && mounted) {
        _hasFetched = true;
        final provider = context.read<CharactersProvider>();
        if (provider.topCharactersState == FetchState.initial) {
          provider.fetchTopCharacters();
        }
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    // Load more when 200px from bottom
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (_scrollDebounce?.isActive ?? false) return;

      _scrollDebounce = Timer(_scrollDebounceDuration, () {
        if (!mounted) return;

        final provider = context.read<CharactersProvider>();
        if (provider.topCharactersState != FetchState.loading &&
            provider.hasMore) {
          provider.fetchTopCharacters(loadMore: true);
        }
      });
    }
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
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHARACTERS',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
      ),
      body: Consumer<CharactersProvider>(
        builder: (context, provider, child) {
          if (provider.topCharactersState == FetchState.initial ||
              (provider.topCharactersState == FetchState.loading &&
                  provider.topCharacters.isEmpty)) {
            return const _CharactersGridSkeleton();
          }

          if (provider.topCharactersState == FetchState.error &&
              provider.topCharacters.isEmpty) {
            return ErrorView(
              message: provider.topCharactersErrorMessage,
              onRetry: () => provider.fetchTopCharacters(),
            );
          }

          if (provider.topCharacters.isEmpty) {
            return const EmptyState(
              type: EmptyStateType.recommendations,
              subtitle: 'No characters found.',
            );
          }

          return Column(
            children: [
              PaginationIndicator(
                loadedCount: provider.topCharacters.length,
                isLoading: provider.topCharactersState == FetchState.loading,
                hasMore: provider.hasMore,
                itemLabel: 'characters',
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchTopCharacters(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.topCharacters.length +
                        (provider.topCharactersState == FetchState.loading
                            ? 3
                            : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.topCharacters.length) {
                        return const _CharacterCardSkeleton();
                      }

                      final character = provider.topCharacters[index];
                      final rank = index + 1;
                      final heroTag = 'character_hero_${character.malId}';

                      return _CharacterCard(
                        character: character,
                        rank: rank,
                        heroTag: heroTag,
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

class _CharacterCard extends StatelessWidget {
  final TopCharacter character;
  final int rank;
  final String heroTag;

  const _CharacterCard({
    required this.character,
    required this.rank,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => context.push(
        '${RouteNames.characterDetailPath(character.malId)}'
        '?heroTag=${Uri.encodeComponent(heroTag)}',
        extra: character,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                AnimeImage(
                  imageUrl: character.imageUrl,
                  width: double.infinity,
                  borderRadius: 12,
                  heroTag: heroTag,
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? primary.withAlpha(230)
                          : Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$rank',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: rank <= 3 ? Colors.black : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 8,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          character.formattedFavorites,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            character.name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (character.animeNames.isNotEmpty)
            Text(
              character.animeNames.first,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _CharactersGridSkeleton extends StatelessWidget {
  const _CharactersGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.58,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: 18,
        itemBuilder: (context, index) => const _CharacterCardSkeleton(),
      ),
    );
  }
}

class _CharacterCardSkeleton extends StatelessWidget {
  const _CharacterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SkeletonBox(
            width: double.infinity,
            borderRadius: 12,
          ),
        ),
        SizedBox(height: 6),
        SkeletonBox(height: 10, width: 80, borderRadius: 4),
        SizedBox(height: 4),
        SkeletonBox(height: 10, width: 60, borderRadius: 4),
      ],
    );
  }
}