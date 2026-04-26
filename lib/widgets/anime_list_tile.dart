import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import 'anime_image.dart';

class AnimeListTile extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showRank;
  final bool showTypeBadge;
  // Optional Hero tag — passed down to AnimeImage so the poster
  // animates into the detail screen hero image.
  final String? heroTag;

  const AnimeListTile({
    super.key,
    required this.anime,
    required this.onTap,
    this.trailing,
    this.showRank = false,
    this.showTypeBadge = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Poster ───────────────────────────────────────
            AnimeImage(
              imageUrl: anime.imageUrl,
              width: 100,
              height: 140,
              heroTag: heroTag,
            ),
            const SizedBox(width: 16),

            // ── Info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    anime.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Genres
                  if (anime.genres.isNotEmpty)
                    Text(
                      anime.genres.take(3).join(' • '),
                      style: theme.textTheme.labelSmall,
                    ),
                  const SizedBox(height: 12),

                  // Score row
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        anime.score.value?.toStringAsFixed(2) ?? 'N/A',
                        style: theme.textTheme.labelMedium,
                      ),

                      // Optional rank badge
                      if (showRank && anime.score.rank != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '#${anime.score.rank} Rank',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],

                      // Optional type badge
                      if (showTypeBadge && anime.type != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withAlpha(80),
                            ),
                          ),
                          child: Text(
                            anime.type!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // FIX: use local variable for type promotion
            () {
              final t = trailing;
              return t ?? const SizedBox.shrink();
            }(),
          ],
        ),
      ),
    );
  }
}