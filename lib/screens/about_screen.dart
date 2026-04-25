import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ABOUT',
          style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── App icon ──────────────────────────────────────
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── App name + version ────────────────────────────
            Text(
              'Disconime',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            // NOTE: Version is currently hardcoded to keep the
            // dependency list minimal. To read it dynamically,
            // add package_info_plus to pubspec.yaml and replace
            // this Text with a FutureBuilder over
            // PackageInfo.fromPlatform().
            Text(
              'Version 1.0.0',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 40),

            // ── Sections ──────────────────────────────────────
            _buildSection(
              context,
              title: 'The Project',
              body: 'A high-end anime discovery platform built with '
                  'Flutter and the Jikan API. Designed for enthusiasts '
                  'who appreciate minimalist aesthetics and a premium '
                  'content-first experience.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Developer',
              body: 'SRUN-Sochettra',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Architecture',
              body: 'Layered architecture with Provider state management. '
                  'Separation of models, services, providers, screens, '
                  'and widgets.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Data Source',
              body: 'Powered by the Jikan REST API v4 — an unofficial '
                  'MyAnimeList API. Rate limiting and retry logic are '
                  'handled automatically.',
            ),
            const SizedBox(height: 40),

            Divider(color: theme.dividerColor),
            const SizedBox(height: 20),

            Text(
              'Powered by Jikan API v4',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 SRUN-Sochettra',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}