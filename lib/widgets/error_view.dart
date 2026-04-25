import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  /// Optional — if true fills the whole screen,
  /// if false renders inline (e.g. inside a column).
  final bool expand;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // ── Error icon ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: primary, width: 1),
          ),
          child: Icon(
            Icons.error_outline,
            color: primary,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),

        // ── Error label ─────────────────────────────────────────
        Text(
          '> SYS.ERROR',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),

        // ── Error message ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Retry button ────────────────────────────────────────
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh, color: primary, size: 18),
          label: Text(
            'RETRY',
            style: GoogleFonts.spaceMono(
              color: primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary, width: 1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ],
    );

    // Expand fills screen, inline wraps content.
    return expand
        ? Center(child: content)
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: content),
          );
  }
}