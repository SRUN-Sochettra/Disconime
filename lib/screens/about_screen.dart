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
            Text('Disconime', style: theme.textTheme.titleLarge),
            Text('Version 1.0.0', style: theme.textTheme.labelSmall),
            const SizedBox(height: 40),
            _buildSection(
              context,
              'The Project',
              'A high-end anime discovery platform built with Flutter '
                  'and the Jikan API. Designed for enthusiasts who appreciate '
                  'minimalist aesthetics and a premium content-first experience.',
            ),
            const SizedBox(height: 24),
            _buildSection(context, 'Developer', 'SRUN-Sochettra'),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Architecture',
              'Enterprise Layered Clean Architecture with Provider '
                  'State Management.',
            ),
            const SizedBox(height: 40),
            Divider(color: theme.dividerColor.withAlpha(40)),
            const SizedBox(height: 20),
            Text('Powered by Jikan API v4',
                style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}