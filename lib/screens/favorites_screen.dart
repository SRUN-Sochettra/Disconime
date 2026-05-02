import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/anime_model.dart';
import '../widgets/anime_list_tile.dart';
import '../widgets/empty_state.dart';
import '../router/route_names.dart';
import '../widgets/section_app_bar.dart';
import '../widgets/view_toggle.dart';
import '../widgets/anime_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGridView = false;

  void _showFilterSheet() {
    final provider = context.read<FavoritesProvider>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).padding.bottom + 24,
              ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Saved', style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Sort By', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Date Added',
                        isSelected: provider.activeFilter.orderBy == 'date_added',
                        onTap: () {
                          setSheetState(() => provider.updateFilter(orderBy: 'date_added'));
                        },
                      ),
                      _FilterChip(
                        label: 'Title',
                        isSelected: provider.activeFilter.orderBy == 'title',
                        onTap: () {
                          setSheetState(() => provider.updateFilter(orderBy: 'title'));
                        },
                      ),
                      _FilterChip(
                        label: 'Score',
                        isSelected: provider.activeFilter.orderBy == 'score',
                        onTap: () {
                          setSheetState(() => provider.updateFilter(orderBy: 'score'));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Type', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'All',
                      'TV',
                      'Movie',
                      'OVA',
                      'Special',
                      'ONA',
                      'Music'
                    ].map((type) {
                      final isAll = type == 'All';
                      final value = isAll ? '' : type.toLowerCase();
                      final isSelected = isAll 
                          ? provider.activeFilter.type == null || provider.activeFilter.type!.isEmpty
                          : provider.activeFilter.type == value;
                      return _FilterChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () {
                          setSheetState(() => provider.updateFilter(type: value));
                        },
                      );
                    }).toList(),
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
    return Scaffold(
      appBar: SectionAppBar(
        title: 'Saved',
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
          ),
          ViewToggleButton(
            isGridView: _isGridView,
            onToggle: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          final favorites = provider.filteredFavorites;

          if (provider.favorites.isEmpty) {
            return const EmptyState(type: EmptyStateType.favorites);
          }

          if (favorites.isEmpty) {
            return const EmptyState(
              type: EmptyStateType.recommendations,
              subtitle: 'No favorites match your filters.',
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isGridView
                ? _buildGridView(context, favorites, provider)
                : _buildListView(context, favorites, provider),
          );
        },
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<Anime> favorites,
    FavoritesProvider provider,
  ) {
    final theme = Theme.of(context);
    return ListView.builder(
      key: const ValueKey('favorites_list'),
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final Anime item = favorites[index];
        final heroTag = 'favorites_hero_${item.malId}';
        return AnimeListTile(
          anime: item,
          heroTag: heroTag,
          onTap: () => context.push(
            RouteNames.animeDetailPath(item.malId),
            extra: item,
          ),
          trailing: IconButton(
            onPressed: () => provider.toggleFavorite(item),
            icon: Icon(
              Icons.bookmark_remove_outlined,
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List<Anime> favorites,
    FavoritesProvider provider,
  ) {
    return GridView.builder(
      key: const ValueKey('favorites_grid'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        final heroTag = 'favorites_hero_${item.malId}';
        return Stack(
          children: [
            InkWell(
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
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                  onPressed: () => provider.toggleFavorite(item),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : theme.dividerColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}