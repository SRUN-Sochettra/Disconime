import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  /// If true fills the whole available space (full-screen error).
  /// If false renders inline with minimum height (load-more error).
  final bool expand;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // ── Icon ──────────────────────────────────────────────
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primary.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.wifi_off_rounded,
            color: primary,
            size: 30,
          ),
        ),
        const SizedBox(height: 20),

        // ── Title ─────────────────────────────────────────────
        Text(
          'Something went wrong',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // ── Message ───────────────────────────────────────────
        // FIX: message is now always a user-friendly string
        // produced by AnimeProvider._friendlyError() so we
        // never surface raw exception text to the user here.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 24),

        // ── Retry button ──────────────────────────────────────
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Try Again'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );

    return expand
        ? Center(child: content)
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: content),
          );
  }
}