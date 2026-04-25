import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/anime_model.dart';
import '../widgets/anime_list_tile.dart';
import '../widgets/page_transitions.dart';
import 'detail_screen.dart';

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurface.withAlpha(60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved anime yet.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark anime from the detail screen.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
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
                onTap: () => Navigator.push(
                  context,
                  ScaleFadePageRoute(
                    page: DetailScreen(
                      anime: item,
                      heroTag: heroTag,
                    ),
                  ),
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