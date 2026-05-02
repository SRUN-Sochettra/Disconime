import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/anime_provider.dart';
import '../widgets/section_app_bar.dart';
import 'package:anime_discovery/providers/fetch_state.dart';

import '../widgets/error_view.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../router/route_names.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched && mounted) {
        _hasFetched = true;
        context.read<AnimeProvider>().fetchGenres();
      }
    });
  }

  void _showSortSheet() {
    final provider = context.read<AnimeProvider>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              Text('Sort Genres', style: theme.textTheme.titleMedium),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha_rounded),
                title: const Text('Name (A-Z)'),
                trailing: provider.genreSort == 'name'
                    ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  provider.setGenreSort('name');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: const Text('Title Count'),
                trailing: provider.genreSort == 'count'
                    ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  provider.setGenreSort('count');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SectionAppBar(
        title: 'Genres',
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onPressed: _showSortSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
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
                itemBuilder: (_, _) =>
                    const SkeletonBox(borderRadius: 12),
              ),
            );
          }

          if (provider.genresState == FetchState.error) {
            return ErrorView(
              message: provider.genresErrorMessage,
              onRetry: () => provider.fetchGenres(),
            );
          }

          final genres = provider.sortedGenres;

          if (genres.isEmpty) {
            return EmptyState(
              type: EmptyStateType.genres,
              onAction: () => provider.fetchGenres(),
              actionLabel: 'Retry',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              final name = genre['name'] as String;
              final count = genre['count'] as int? ?? 0;
              final genreId = genre['mal_id'] as int;

              return InkWell(
                onTap: () => context.push(
                  '${RouteNames.genreDetailPath(genreId)}'
                  '?name=${Uri.encodeComponent(name)}',
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
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