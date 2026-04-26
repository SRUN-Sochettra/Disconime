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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SectionAppBar(
        title: 'Saved',
        actions: [
          ViewToggleButton(
            isGridView: _isGridView,
            onToggle: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return const EmptyState(type: EmptyStateType.favorites);
          }

          final favorites = provider.favorites.reversed.toList();

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