import 'package:flutter/material.dart';
import '../widgets/section_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    // ignore: unused_local_variable
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: const SectionAppBar(title: 'About'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Brand block ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'DISCONIME',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 2,
                    color: primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Anime Discovery Platform',
                    style: theme.textTheme.bodySmall?.copyWith(
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primary.withAlpha(40),
                      ),
                    ),
                    child: Text(
                      'v1.0.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // ── Sections ──────────────────────────────────────
            const _AboutSection(
              label: 'The Project',
              body:
                  'A high-end anime discovery platform built with '
                  'Flutter and the Jikan API. Designed for enthusiasts '
                  'who appreciate minimalist aesthetics and a premium '
                  'content-first experience.',
            ),

            const _AboutSection(
              label: 'Architecture',
              body:
                  'Layered architecture with Provider state management. '
                  'Separation of models, services, providers, screens, '
                  'and widgets. Offline-first caching with stale-while-'
                  'revalidate strategy.',
            ),

            const _AboutSection(
              label: 'Data Source',
              body:
                  'Powered by the Jikan REST API v4 — an unofficial '
                  'MyAnimeList API. Rate limiting and exponential '
                  'backoff retry logic are handled automatically.',
            ),

            const _AboutSection(
              label: 'Features',
              body:
                  '• Top anime rankings with filters\n'
                  '• Instant search with history\n'
                  '• Seasonal anime browser\n'
                  '• Weekly broadcast schedule\n'
                  '• Genre exploration\n'
                  '• Character profiles & voice actors\n'
                  '• Offline support with smart caching\n'
                  '• Personal statistics dashboard\n'
                  '• Share anime cards',
            ),

            const _AboutSection(
              label: 'Tech Stack',
              body:
                  '• Flutter & Dart\n'
                  '• Provider for state management\n'
                  '• GoRouter for navigation\n'
                  '• SharedPreferences for persistence\n'
                  '• CachedNetworkImage for image loading\n'
                  '• Custom canvas charts & illustrations',
            ),

            const SizedBox(height: 16),

            // ── Divider ─────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 2,
                color: primary.withAlpha(40),
              ),
            ),

            const SizedBox(height: 24),

            // ── Footer ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Built by ',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'SRUN-Sochettra',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powered by Jikan API v4',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 SRUN-Sochettra',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Reusable section widget ───────────────────────────────────────
class _AboutSection extends StatelessWidget {
  final String label;
  final String body;

  const _AboutSection({
    required this.label,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Section body
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}