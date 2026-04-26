import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_model.dart';
import '../providers/anime_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';

import '../providers/favorites_provider.dart';
import '../widgets/anime_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/share_sheet.dart';
import '../router/route_names.dart'; // ADD
import '../models/character_model.dart';

class DetailScreen extends StatefulWidget {
  final Anime anime;
  final String? heroTag;

  const DetailScreen({
    super.key,
    required this.anime,
    this.heroTag,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const int _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AnimeProvider>();

      // FIX: Removed clearDetailData() — fetchCharacters/fetchStaff already
      // deduplicate via their own _current*MalId trackers, so a broad clear
      // is redundant and causes stale-data flashes when navigating.
      provider.fetchRecommendations(widget.anime.malId);
      provider.fetchCharacters(widget.anime.malId);
      provider.fetchStaff(widget.anime.malId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final theme = Theme.of(context);

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
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          // ── Share button ──────────────────────────────────────
          CircleAvatar(
            backgroundColor: Colors.black.withAlpha(100),
            child: IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.white,
              ),
              onPressed: () => ShareSheet.show(context, anime: anime),
            ),
          ),
          const SizedBox(width: 8),

          // ── Bookmark button ───────────────────────────────────
          CircleAvatar(
            backgroundColor: Colors.black.withAlpha(100),
            child: Consumer<FavoritesProvider>(
              builder: (context, favProvider, child) {
                final isFav = favProvider.isFavorite(anime.malId);
                return IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: isFav
                        ? theme.colorScheme.primary
                        : Colors.white,
                  ),
                  onPressed: () => favProvider.toggleFavorite(anime),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ──────────────────────────────────
                AnimeImage(
                  imageUrl: anime.imageUrl,
                  width: double.infinity,
                  height: 420,
                  borderRadius: 0,
                  heroTag: widget.heroTag,
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Titles ────────────────────────────────
                      Text(
                        anime.title,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (anime.titleEnglish != null &&
                          anime.titleEnglish!.isNotEmpty &&
                          anime.titleEnglish != anime.title) ...[
                        const SizedBox(height: 4),
                        Text(
                          anime.titleEnglish!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (anime.titleJapanese != null &&
                          anime.titleJapanese!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          anime.titleJapanese!,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                      const SizedBox(height: 20),

                      // ── Stats row ─────────────────────────────
                      Row(
                        children: [
                          _StatBadge(
                            icon: Icons.star_rounded,
                            value: anime.score.value
                                    ?.toStringAsFixed(1) ??
                                'N/A',
                            label: 'Score',
                          ),
                          const SizedBox(width: 12),
                          _StatBadge(
                            icon: Icons.leaderboard_rounded,
                            value: anime.score.rank != null
                                ? '#${anime.score.rank}'
                                : 'N/A',
                            label: 'Rank',
                          ),
                          const SizedBox(width: 12),
                          _StatBadge(
                            icon: Icons.trending_up_rounded,
                            value: anime.score.popularity != null
                                ? '#${anime.score.popularity}'
                                : 'N/A',
                            label: 'Popular',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Trailer button ─────────────────────────
                      if (anime.trailer?.isValid == true)
                        _TrailerButton(trailer: anime.trailer!),

                      const SizedBox(height: 4),

                      // ── Genre chips ───────────────────────────
                      if (anime.genres.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: anime.genres
                              .map((g) => _GenreChip(label: g))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),

                // ── Tab bar ──────────────────────────────────────
                _DetailTabBar(controller: _tabController),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(anime: anime),
            _CharactersTab(malId: anime.malId),
            _StaffTab(malId: anime.malId),
          ],
        ),
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────
class _DetailTabBar extends StatelessWidget {
  final TabController controller;
  const _DetailTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: TabBar(
        controller: controller,
        labelColor: primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: primary,
        indicatorWeight: 2,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Characters'),
          Tab(text: 'Staff'),
        ],
      ),
    );
  }
}

// ── Tab 0: Overview ───────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Anime anime;
  const _OverviewTab({required this.anime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Synopsis', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ExpandableSynopsis(text: anime.synopsis.text),
        const SizedBox(height: 24),

        if (anime.synopsis.background != null &&
            anime.synopsis.background!.isNotEmpty) ...[
          Text('Background', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            anime.synopsis.background!,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
        ],

        _InfoSection(anime: anime),
        const SizedBox(height: 32),

        _RecommendationsSection(currentAnime: anime),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Expandable synopsis ───────────────────────────────────────────
class _ExpandableSynopsis extends StatefulWidget {
  final String text;
  const _ExpandableSynopsis({required this.text});

  @override
  State<_ExpandableSynopsis> createState() => _ExpandableSynopsisState();
}

class _ExpandableSynopsisState extends State<_ExpandableSynopsis> {
  bool _expanded = false;
  static const int _collapsedLines = 4;

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

// ── Trailer button ────────────────────────────────────────────────
class _TrailerButton extends StatelessWidget {
  final Trailer trailer;
  const _TrailerButton({required this.trailer});

  Future<void> _launchTrailer(BuildContext context) async {
    final uri = Uri.parse(trailer.watchUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open trailer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => _launchTrailer(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  trailer.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.surface,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 48,
                      color: primary.withAlpha(80),
                    ),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(color: Colors.black.withAlpha(80)),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withAlpha(80),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 36,
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline_rounded,
                      size: 14,
                      color: primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Watch Trailer',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Characters ─────────────────────────────────────────────
class _CharactersTab extends StatelessWidget {
  final int malId;
  const _CharactersTab({required this.malId});

  @override
  Widget build(BuildContext context) {
    final state = context.select<AnimeProvider, FetchState>(
      (p) => p.charactersState,
    );
    final characters = context.select<AnimeProvider, List<AnimeCharacter>>(
      (p) => p.characters,
    );
    final errorMessage = context.select<AnimeProvider, String>(
      (p) => p.charactersErrorMessage,
    );

    if (state == FetchState.initial || state == FetchState.loading) {
      return const _CharacterGridSkeleton();
    }

    if (state == FetchState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.read<AnimeProvider>().fetchCharacters(malId),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (characters.isEmpty) {
      return Center(
        child: Text(
          'No character data available.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55, // FIX: Slightly taller to fit name + favorites
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        return _CharacterCard(character: characters[index]);
      },
    );
  }
}

// ── Character card ────────────────────────────────────────────────
// ── Character card ────────────────────────────────────────────────
class _CharacterCard extends StatelessWidget {
  final AnimeCharacter character;
  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        // FIX: Guard against invalid malId
        if (character.malId == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Character data not available.'),
            ),
          );
          return;
        }

        final topChar = TopCharacter(
          malId: character.malId,
          name: character.name,
          imageUrl: character.imageUrl,
          favorites: character.favorites ?? 0,
          animeNames: const [],
          role: character.role,
        );
        final heroTag = 'char_detail_${character.malId}';
        context.push(
          '${RouteNames.characterDetailPath(topChar.malId)}'
          '?heroTag=${Uri.encodeComponent(heroTag)}',
          extra: topChar,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // FIX: Use character.imageUrl directly
                // AnimeCharacter.fromJson already extracts the
                // URL from the nested character.images.jpg path
                character.imageUrl.isNotEmpty
                    ? AnimeImage(
                        imageUrl: character.imageUrl,
                        width: double.infinity,
                        borderRadius: 10,
                      )
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                // Role badge
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: character.role == 'Main'
                          ? primary.withAlpha(220)
                          : Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      character.role,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: character.role == 'Main'
                            ? Colors.black
                            : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Name ───────────────────────────────────────────
          Text(
            character.name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // ── Favorites count ────────────────────────────────
          if (character.favorites != null && character.favorites! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _formatNumber(character.favorites!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// ── Character grid skeleton ───────────────────────────────────────
class _CharacterGridSkeleton extends StatelessWidget {
  const _CharacterGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                borderRadius: 10,
              ),
            ),
            SizedBox(height: 6),
            SkeletonBox(height: 10, width: 80, borderRadius: 4),
            SizedBox(height: 4),
            SkeletonBox(height: 10, width: 50, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

// ── Tab 2: Staff ──────────────────────────────────────────────────
class _StaffTab extends StatelessWidget {
  final int malId;
  const _StaffTab({required this.malId});

  @override
  Widget build(BuildContext context) {
    final state = context.select<AnimeProvider, FetchState>(
      (p) => p.staffState,
    );
    final staff = context.select<AnimeProvider, List<AnimeStaff>>(
      (p) => p.staff,
    );
    final errorMessage = context.select<AnimeProvider, String>(
      (p) => p.staffErrorMessage,
    );
    final theme = Theme.of(context);

    if (state == FetchState.initial || state == FetchState.loading) {
      return const _StaffListSkeleton();
    }

    if (state == FetchState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.read<AnimeProvider>().fetchStaff(malId),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (staff.isEmpty) {
      return Center(
        child: Text(
          'No staff data available.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: staff.length,
      separatorBuilder: (context, index) =>
          Divider(color: theme.dividerColor, height: 1),
      itemBuilder: (context, index) {
        return _StaffTile(member: staff[index]);
      },
    );
  }
}

// ── Staff tile ────────────────────────────────────────────────────
class _StaffTile extends StatelessWidget {
  final AnimeStaff member;
  const _StaffTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AnimeImage(
            imageUrl: member.imageUrl,
            width: 52,
            height: 52,
            borderRadius: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: member.positions
                      .take(3)
                      .map(
                        (pos) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withAlpha(40),
                            ),
                          ),
                          child: Text(
                            pos,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Staff list skeleton ───────────────────────────────────────────
class _StaffListSkeleton extends StatelessWidget {
  const _StaffListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (context, index) =>
            Divider(color: Theme.of(context).dividerColor, height: 1),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: const [
              SkeletonBox(width: 52, height: 52, borderRadius: 26),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                        height: 14, width: 140, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBox(
                        height: 10, width: 100, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat badge ────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Genre chip ────────────────────────────────────────────────────
class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(100),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Info section ──────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final Anime anime;
  const _InfoSection({required this.anime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];

    void addRow(String label, String? value) {
      if (value == null || value.isEmpty) return;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    addRow('Type', anime.type);
    addRow('Status', anime.status);
    addRow('Episodes', anime.episodes?.toString());
    addRow('Duration', anime.duration);
    addRow('Rating', anime.rating);
    addRow('Year', anime.year);
    if (anime.score.scoredBy != null) {
      addRow(
        'Scored By',
        '${_formatNumber(anime.score.scoredBy!)} users',
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Information', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

// ── Recommendations section ───────────────────────────────────────
class _RecommendationsSection extends StatelessWidget {
  final Anime currentAnime;
  const _RecommendationsSection({required this.currentAnime});

  @override
  Widget build(BuildContext context) {
    final state = context.select<AnimeProvider, FetchState>(
      (p) => p.recommendationsState,
    );
    final recommendations = context.select<AnimeProvider, List<Anime>>(
      (p) => p.recommendations,
    );

    if (state == FetchState.loading) {
      return const RecommendationListSkeleton();
    }

    if (state == FetchState.error || recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You Might Also Like',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              final recHeroTag = 'rec_hero_${rec.malId}';

              return GestureDetector(
                onTap: () async {
                  final animeProvider = context.read<AnimeProvider>();

                  // Show loading dialog immediately
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final fullAnime =
                        await animeProvider.getAnimeDetails(rec.malId);
                    // FIX: Guard before every navigation call (Issue #6)
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    if (!context.mounted) return;
                    context.push(
                      RouteNames.animeDetailPath(fullAnime.malId),
                      extra: fullAnime,
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    Navigator.pop(context); // Dismiss on error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to load anime details.'),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimeImage(
                        imageUrl: rec.imageUrl,
                        width: 130,
                        height: 180,
                        heroTag: recHeroTag,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 130,
                        child: Text(
                          rec.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}