import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeProvider>().fetchTopAnime();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<AnimeProvider>();
        if (provider.topAnimeState != FetchState.loading) {
          provider.fetchTopAnime(loadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'DISCOVER_ANIME',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          if (provider.topAnimeState == FetchState.initial || 
              (provider.topAnimeState == FetchState.loading && provider.topAnime.isEmpty)) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          if (provider.topAnimeState == FetchState.error && provider.topAnime.isEmpty) {
            return Center(
              child: Text(
                '[ERROR]: ${provider.errorMessage}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTopAnime(),
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: kToolbarHeight + 20),
              itemCount: provider.topAnime.length + (provider.topAnimeState == FetchState.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.topAnime.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                }
                
                final Anime item = provider.topAnime[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            color: Theme.of(context).colorScheme.surface.withAlpha(100),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                                  ),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '> ${item.title}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '[SCORE]: ${item.score.value ?? 'N/A'}',
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}