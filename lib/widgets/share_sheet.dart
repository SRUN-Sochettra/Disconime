import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/anime_model.dart';

/// Shows a polished in-app share bottom sheet for an [Anime].
///
/// Offers three actions:
/// 1. Share via system share sheet (share_plus)
/// 2. Copy a formatted text card to clipboard
/// 3. Copy the MAL URL to clipboard
///
/// Usage:
/// ```dart
/// ShareSheet.show(context, anime: anime);
/// ```
class ShareSheet {
  ShareSheet._();

  static void show(BuildContext context, {required Anime anime}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ShareSheetContent(anime: anime),
    );
  }
}

class _ShareSheetContent extends StatelessWidget {
  final Anime anime;

  const _ShareSheetContent({required this.anime});

  // ── Share text builder ────────────────────────────────────────
  String _buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🎌 ${anime.title}');

    if (anime.titleEnglish != null &&
        anime.titleEnglish!.isNotEmpty &&
        anime.titleEnglish != anime.title) {
      buffer.writeln('   ${anime.titleEnglish}');
    }

    buffer.writeln();

    if (anime.score.value != null) {
      buffer.writeln('⭐ Score: ${anime.score.value!.toStringAsFixed(1)}'
          '${anime.score.rank != null ? '  •  Rank #${anime.score.rank}' : ''}');
    }

    if (anime.type != null || anime.episodes != null) {
      final parts = <String>[];
      if (anime.type != null) parts.add(anime.type!);
      if (anime.episodes != null) parts.add('${anime.episodes} episodes');
      if (anime.year != null) parts.add(anime.year!);
      buffer.writeln('📺 ${parts.join('  •  ')}');
    }

    if (anime.status != null) {
      buffer.writeln('📌 ${anime.status}');
    }

    if (anime.genres.isNotEmpty) {
      buffer.writeln('🏷️  ${anime.genres.take(4).join(', ')}');
    }

    buffer.writeln();

    // Trim synopsis to ~200 chars for sharing.
    final synopsis = anime.synopsis.text;
    if (synopsis.isNotEmpty &&
        synopsis != 'No synopsis available.') {
      final trimmed = synopsis.length > 200
          ? '${synopsis.substring(0, 200).trimRight()}...'
          : synopsis;
      buffer.writeln(trimmed);
      buffer.writeln();
    }

    buffer.writeln('🔗 ${_malUrl()}');
    buffer.writeln();
    buffer.write('Shared via Disconime');

    return buffer.toString();
  }

  String _malUrl() =>
      'https://myanimelist.net/anime/${anime.malId}';

  // ── Actions ───────────────────────────────────────────────────
  Future<void> _shareViaSystem(BuildContext context) async {
    Navigator.pop(context);
    
    // FIX: Reverted to standard Share.share() as SharePlus was undefined.
    // Added sharePositionOrigin to prevent crashes on iPad/macOS (Issue #10).
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      _buildShareText(),
      subject: anime.title,
      sharePositionOrigin: box != null 
          ? box.localToGlobal(Offset.zero) & box.size 
          : null,
    );
  }

  Future<void> _copyCard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _buildShareText()));
    if (!context.mounted) return;
    Navigator.pop(context);
    _showSnackBar(context, 'Anime card copied to clipboard');
  }

  Future<void> _copyUrl(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _malUrl()));
    if (!context.mounted) return;
    Navigator.pop(context);
    _showSnackBar(context, 'MAL link copied to clipboard');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ───────────────────────────────────────────
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

          // ── Header ───────────────────────────────────────────
          Text(
            'Share',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            anime.title,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // ── Preview card ──────────────────────────────────────
          _PreviewCard(anime: anime),
          const SizedBox(height: 24),

          // ── Action buttons ────────────────────────────────────
          _ShareAction(
            icon: Icons.share_rounded,
            label: 'Share via...',
            subtitle: 'Open system share sheet',
            primary: primary,
            theme: theme,
            onTap: () => _shareViaSystem(context),
          ),
          Divider(color: theme.dividerColor, height: 1),
          _ShareAction(
            icon: Icons.copy_rounded,
            label: 'Copy Card',
            subtitle: 'Copy formatted anime info',
            primary: primary,
            theme: theme,
            onTap: () => _copyCard(context),
          ),
          Divider(color: theme.dividerColor, height: 1),
          _ShareAction(
            icon: Icons.link_rounded,
            label: 'Copy MAL Link',
            subtitle: _malUrl(),
            primary: primary,
            theme: theme,
            onTap: () => _copyUrl(context),
          ),
        ],
      ),
    );
  }
}

// ── Preview card ──────────────────────────────────────────────────
/// Shows a compact preview of what will be shared.
class _PreviewCard extends StatelessWidget {
  final Anime anime;
  const _PreviewCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: anime.imageUrl.isNotEmpty
                ? Image.network(
                    anime.imageUrl,
                    width: 56,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 80,
                      color: theme.colorScheme.surface,
                      child: Icon(
                        Icons.image_outlined,
                        color: primary.withAlpha(80),
                      ),
                    ),
                  )
                : Container(
                    width: 56,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: primary.withAlpha(80),
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  anime.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Score + type row
                Row(
                  children: [
                    if (anime.score.value != null) ...[
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        anime.score.value!.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (anime.type != null)
                      Text(
                        anime.type!,
                        style: theme.textTheme.labelSmall,
                      ),
                    if (anime.year != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        anime.year!,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Genres
                if (anime.genres.isNotEmpty)
                  Text(
                    anime.genres.take(3).join(' • '),
                    style: theme.textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),

                // MAL URL
                Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 11,
                      color: primary.withAlpha(150),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'myanimelist.net/anime/${anime.malId}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary.withAlpha(150),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share action tile ─────────────────────────────────────────────
class _ShareAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color primary;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ShareAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.primary,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withAlpha(30)),
              ),
              child: Icon(icon, color: primary, size: 20),
            ),
            const SizedBox(width: 14),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}