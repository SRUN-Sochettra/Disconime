import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/character_model.dart';
import '../models/filter_model.dart';
import '../providers/characters_provider.dart';
import '../providers/fetch_state.dart';
import '../router/route_names.dart';
import '../widgets/anime_image.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/pagination_indicator.dart';
import '../widgets/section_app_bar.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/view_toggle.dart';

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
  bool _isGridView = true; // Default to grid since characters look best as grid
  CharacterSortOption _sortOption = CharacterSortOption.favoritesDesc;

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

  List<TopCharacter> _applySortOption(List<TopCharacter> source) {
    final result = List<TopCharacter>.from(source);
    switch (_sortOption) {
      case CharacterSortOption.favoritesDesc:
        result.sort((a, b) => b.favorites.compareTo(a.favorites));
        break;
      case CharacterSortOption.favoritesAsc:
        result.sort((a, b) => a.favorites.compareTo(b.favorites));
        break;
      case CharacterSortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CharacterSortOption.nameDesc:
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CharacterSortOption.mostAnime:
        result.sort(
            (a, b) => b.animeNames.length.compareTo(a.animeNames.length));
        break;
    }
    return result;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(builderContext).size.height * 0.75,
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
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Sort Characters', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: CharacterSortOption.values.map((option) {
                          final isSelected = _sortOption == option;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() => _sortOption = option);
                                setSheetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary.withAlpha(20)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? primary
                                        : theme.dividerColor.withAlpha(60),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      option.icon,
                                      size: 18,
                                      color: isSelected
                                          ? primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.label,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected ? primary : null,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: primary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Done',
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
        title: 'Characters',
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Sort',
                onPressed: _showSortSheet,
              ),
              if (_sortOption != CharacterSortOption.favoritesDesc)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          ViewToggleButton(
            isGridView: _isGridView,
            onToggle: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Consumer<CharactersProvider>(
        builder: (context, provider, child) {
          if (provider.topCharacters.isEmpty &&
              (provider.topCharactersState == FetchState.loading ||
                  provider.topCharactersState == FetchState.initial)) {
            return const _CharactersGridSkeleton();
          }

          final sortedCharacters = _applySortOption(provider.topCharacters);

          if (provider.topCharactersState == FetchState.error &&
              provider.topCharacters.isEmpty) {
            return ErrorView(
              message: provider.topCharactersErrorMessage,
              onRetry: () => provider.fetchTopCharacters(),
            );
          }

          if (sortedCharacters.isEmpty) {
            return const EmptyState(
              type: EmptyStateType.recommendations,
              subtitle: 'No characters found.',
            );
          }

          return Column(
            children: [
              PaginationIndicator(
                loadedCount: sortedCharacters.length,
                isLoading: provider.topCharactersState == FetchState.loading,
                hasMore: provider.hasMore,
                itemLabel: 'characters',
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchTopCharacters(),
                  child: _isGridView
                      ? _buildGrid(provider, sortedCharacters)
                      : _buildList(provider, sortedCharacters),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid(
      CharactersProvider provider, List<TopCharacter> sortedCharacters) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: sortedCharacters.length +
          (provider.topCharactersState == FetchState.loading ? 3 : 0),
      itemBuilder: (context, index) {
        if (index >= sortedCharacters.length) {
          return const _CharacterCardSkeleton();
        }

        final character = sortedCharacters[index];
        final rank = index + 1;
        final heroTag = 'character_hero_${character.malId}';

        return _CharacterCard(
          character: character,
          rank: rank,
          heroTag: heroTag,
          sortOption: _sortOption,
        );
      },
    );
  }

  Widget _buildList(
      CharactersProvider provider, List<TopCharacter> sortedCharacters) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedCharacters.length +
          (provider.topCharactersState == FetchState.loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= sortedCharacters.length) {
          return const _CharacterListSkeleton();
        }

        final character = sortedCharacters[index];
        final rank = index + 1;
        final heroTag = 'character_list_${character.malId}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(
              '${RouteNames.characterDetailPath(character.malId)}'
              '?heroTag=${Uri.encodeComponent(heroTag)}',
              extra: character,
            ),
            child: Row(
              children: [
                // Rank
                SizedBox(
                  width: 32,
                  child: Text(
                    '#$rank',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: rank <= 3 ? primary : null,
                      fontWeight:
                          rank <= 3 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),

                // Avatar
                AnimeImage(
                  imageUrl: character.imageUrl,
                  width: 52,
                  height: 52,
                  borderRadius: 26,
                  heroTag: heroTag,
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (character.animeNames.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          character.animeNames.first,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_sortOption == CharacterSortOption.mostAnime &&
                            character.animeNames.length > 1) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${character.animeNames.length} anime appearances',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: primary,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                // Favorites / Anime Count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _sortOption == CharacterSortOption.mostAnime
                          ? Icons.movie_filter_rounded
                          : Icons.favorite_rounded,
                      size: 12,
                      color: primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _sortOption == CharacterSortOption.mostAnime
                          ? '${character.animeNames.length}'
                          : character.formattedFavorites,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final TopCharacter character;
  final int rank;
  final String heroTag;
  final CharacterSortOption sortOption;

  const _CharacterCard({
    required this.character,
    required this.rank,
    required this.heroTag,
    required this.sortOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        final path = '${RouteNames.characterDetailPath(character.malId)}'
            '?heroTag=${Uri.encodeComponent(heroTag)}';
        context.push(path, extra: character);
      },
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
                        Icon(
                          sortOption == CharacterSortOption.mostAnime
                              ? Icons.movie_filter_rounded
                              : Icons.favorite_rounded,
                          size: 8,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          sortOption == CharacterSortOption.mostAnime
                              ? '${character.animeNames.length}'
                              : character.formattedFavorites,
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

class _CharacterListSkeleton extends StatelessWidget {
  const _CharacterListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 32),
          SkeletonBox(width: 52, height: 52, borderRadius: 26),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: 140, borderRadius: 4),
                SizedBox(height: 6),
                SkeletonBox(height: 10, width: 100, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
