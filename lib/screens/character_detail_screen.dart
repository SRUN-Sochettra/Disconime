// REPLACE the imports section with:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/character_model.dart';
import '../providers/characters_provider.dart';
import '../providers/anime_provider.dart' show AnimeProvider; // ADD show
import '../widgets/anime_image.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/error_view.dart';
import '../router/route_names.dart';

class CharacterDetailScreen extends StatefulWidget {
  final TopCharacter character;
  final String? heroTag;

  const CharacterDetailScreen({
    super.key,
    required this.character,
    this.heroTag,
  });

  @override
  State<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CharactersProvider>()
          .fetchCharacterDetail(widget.character.malId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final char = widget.character;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: CircleAvatar(
          backgroundColor: Colors.black.withAlpha(100),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero portrait ───────────────────────────────────
            // FIX: Handle empty imageUrl gracefully
            char.imageUrl.isNotEmpty
                ? AnimeImage(
                    imageUrl: char.imageUrl,
                    width: double.infinity,
                    height: 420,
                    borderRadius: 0,
                    heroTag: widget.heroTag,
                  )
                : Container(
                    width: double.infinity,
                    height: 420,
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ── Name ──────────────────────────────────────
                Text(
                  char.name.isNotEmpty ? char.name : 'Unknown Character',
                  style: theme.textTheme.titleLarge,
                ),
                if (char.nameKanji != null &&
                    char.nameKanji!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    char.nameKanji!,
                    style: theme.textTheme.labelSmall,
                  ),
                ],

                // FIX: Show role if available
                if (char.role != null && char.role!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: char.role == 'Main'
                          ? theme.colorScheme.primary.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(
                          char.role == 'Main' ? 60 : 30,
                        ),
                      ),
                    ),
                    child: Text(
                      char.role!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                  // ── Favorites badge ────────────────────────────
                  _FavoritesBadge(count: char.formattedFavorites),
                  const SizedBox(height: 24),

                  // ── Detail section ─────────────────────────────
                  _CharacterDetailSection(malId: char.malId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Favorites badge ───────────────────────────────────────────────
class _FavoritesBadge extends StatelessWidget {
  final String count;
  const _FavoritesBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, size: 16, color: primary),
          const SizedBox(width: 6),
          Text(
            '$count Favorites',
            style: theme.textTheme.labelMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail section ────────────────────────────────────────────────
class _CharacterDetailSection extends StatelessWidget {
  final int malId;
  const _CharacterDetailSection({required this.malId});

  @override
  Widget build(BuildContext context) {
    final state = context.select<CharactersProvider, FetchState>(
      (p) => p.detailStateFor(malId),
    );
    final character = context.select<CharactersProvider, Character?>(
      (p) => p.detailFor(malId),
    );
    final errorMessage = context.select<CharactersProvider, String>(
      (p) => p.detailErrorFor(malId),
    );

    if (state == FetchState.initial || state == FetchState.loading) {
      return const _DetailSkeleton();
    }

    if (state == FetchState.error) {
      return ErrorView(
        message: errorMessage,
        onRetry: () => context
            .read<CharactersProvider>()
            .fetchCharacterDetail(malId),
        expand: false,
      );
    }

    if (character == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── About ────────────────────────────────────────────
        if (character.about != null &&
            character.about!.isNotEmpty) ...[
          _SectionTitle(title: 'About'),
          const SizedBox(height: 8),
          _ExpandableAbout(text: character.about!),
          const SizedBox(height: 32),
        ],

        // ── Animeography ─────────────────────────────────────
        if (character.animeography.isNotEmpty) ...[
          _SectionTitle(title: 'Appears In'),
          const SizedBox(height: 12),
          _AnimeographySection(animeList: character.animeography),
          const SizedBox(height: 32),
        ],

        // ── Voice Actors ──────────────────────────────────────
        if (character.voiceActors.isNotEmpty) ...[
          _SectionTitle(title: 'Voice Actors'),
          const SizedBox(height: 12),
          _VoiceActorsSection(voiceActors: character.voiceActors),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

// ── Section title ─────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

// ── Expandable about ──────────────────────────────────────────────
class _ExpandableAbout extends StatefulWidget {
  final String text;
  const _ExpandableAbout({required this.text});

  @override
  State<_ExpandableAbout> createState() => _ExpandableAboutState();
}

class _ExpandableAboutState extends State<_ExpandableAbout> {
  bool _expanded = false;
  static const int _collapsedLines = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            style: theme.textTheme.bodyMedium,
            maxLines: _collapsedLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
            style: theme.textTheme.bodyMedium,
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Read more',
            style: theme.textTheme.labelSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animeography section ──────────────────────────────────────────
class _AnimeographySection extends StatelessWidget {
  final List<CharacterAnime> animeList;
  const _AnimeographySection({required this.animeList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final item = animeList[index];
          return GestureDetector(
            onTap: () => _openAnime(context, item),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimeImage(
                    imageUrl: item.imageUrl,
                    width: 110,
                    height: 150,
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 110,
                    child: Text(
                      item.title,
                      style: theme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.role == 'Main'
                          ? primary.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: primary.withAlpha(
                          item.role == 'Main' ? 60 : 30,
                        ),
                      ),
                    ),
                    child: Text(
                      item.role,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primary,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAnime(BuildContext context, CharacterAnime item) async {
    final animeProvider = context.read<AnimeProvider>();

    // Show loading dialog immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final fullAnime = await animeProvider.getAnimeDetails(item.malId);
      if (!context.mounted) return;

      // Dismiss dialog and push route
      Navigator.pop(context);
      context.push(
        RouteNames.animeDetailPath(fullAnime.malId),
        extra: fullAnime,
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss on error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load anime details.')),
      );
    }
  }
}

// ── Voice actors section ──────────────────────────────────────────
class _VoiceActorsSection extends StatelessWidget {
  final List<CharacterVoiceActor> voiceActors;
  const _VoiceActorsSection({required this.voiceActors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: voiceActors.map((va) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Avatar
              AnimeImage(
                imageUrl: va.imageUrl,
                width: 48,
                height: 48,
                borderRadius: 24,
              ),
              const SizedBox(width: 12),

              // Name + language
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      va.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      va.language,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              // Language badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withAlpha(40)),
                ),
                child: Text(
                  va.language,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Detail skeleton ───────────────────────────────────────────────
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(height: 16, width: 100, borderRadius: 4),
          SizedBox(height: 12),
          SkeletonBox(
            height: 12,
            width: double.infinity,
            borderRadius: 4,
          ),
          SizedBox(height: 8),
          SkeletonBox(
            height: 12,
            width: double.infinity,
            borderRadius: 4,
          ),
          SizedBox(height: 8),
          SkeletonBox(height: 12, width: 200, borderRadius: 4),
          SizedBox(height: 32),
          SkeletonBox(height: 16, width: 120, borderRadius: 4),
          SizedBox(height: 12),
          Row(
            children: [
              SkeletonBox(width: 110, height: 150, borderRadius: 12),
              SizedBox(width: 12),
              SkeletonBox(width: 110, height: 150, borderRadius: 12),
              SizedBox(width: 12),
              SkeletonBox(width: 110, height: 150, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}