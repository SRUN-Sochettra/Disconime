import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/anime_model.dart';
import '../widgets/anime_image.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SYS.FAVORITES'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(76),
                  ),
                  const SizedBox(height: 16),
                  const Text('> NO_FAVORITES_FOUND'),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark anime from the detail screen.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: kToolbarHeight + 20),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final Anime item = provider.favorites.reversed.toList()[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(anime: item),
                            ),
                          );
                        },
                        child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withAlpha(100),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1,
                                  ),
                                ),
                                child: AnimeImage(
                                  imageUrl: item.imageUrl,
                                  size: AnimeImageSize.small,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '> ${item.title}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '[SCORE]: ${item.score.value ?? 'N/A'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    if (item.genres.isNotEmpty)
                                      Text(
                                        '[GENRE]: ${item.genres.take(2).join(', ')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => provider.toggleFavorite(item),
                                icon: Icon(
                                  Icons.bookmark_remove_outlined,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: 'Remove from favorites',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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