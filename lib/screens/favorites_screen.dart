import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/anime_model.dart';
import '../widgets/anime_list_tile.dart';
import '../widgets/empty_state.dart';
import '../router/route_names.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SAVED')),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return const EmptyState(type: EmptyStateType.favorites);
          }

          final favorites = provider.favorites.reversed.toList();

          return ListView.builder(
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
        },
      ),
    );
  }
}