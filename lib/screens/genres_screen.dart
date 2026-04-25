import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/anime_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/skeleton_loader.dart';
import 'genre_detail_screen.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeProvider>().fetchGenres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GENRES',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          // ── Loading skeleton ────────────────────────────────
          if (provider.genresState == FetchState.initial ||
              provider.genresState == FetchState.loading) {
            return SkeletonLoader(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 16,
                // Single underscore — only one ignored parameter
                itemBuilder: (_, __) =>
                    const SkeletonBox(borderRadius: 12),
              ),
            );
          }

          // ── Error ───────────────────────────────────────────
          if (provider.genresState == FetchState.error) {
            return ErrorView(
              message: provider.errorMessage,
              onRetry: () => provider.fetchGenres(),
            );
          }

          // ── Grid ────────────────────────────────────────────
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.genres.length,
            itemBuilder: (context, index) {
              final genre = provider.genres[index];
              final name = genre['name'] as String;
              final count = genre['count'] as int? ?? 0;

              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenreDetailScreen(
                      genreId: genre['mal_id'] as int,
                      genreName: name,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.dividerColor.withAlpha(20)),
                    color: theme.colorScheme.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$count Titles',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
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