import 'package:flutter/material.dart';

/// The type of empty state to display.
/// Each variant gets its own illustration, title and subtitle.
enum EmptyStateType {
  search,
  searchNoResults,
  favorites,
  seasonal,
  genres,
  genreDetail,
  recommendations,
}

/// A polished empty state widget that replaces plain text/icon
/// empty states across all screens.
///
/// Draws a custom animated illustration using pure Flutter canvas
/// so there are zero external asset dependencies.
///
/// Usage:
/// ```dart
/// EmptyState(type: EmptyStateType.favorites)
/// EmptyState(
///   type: EmptyStateType.searchNoResults,
///   subtitle: 'No results for "naruto"',
/// )
/// ```
class EmptyState extends StatefulWidget {
  final EmptyStateType type;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.type,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Gentle floating up/down motion for the illustration.
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fade in on first render.
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _configFor(widget.type);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Floating illustration ─────────────────────────
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  );
                },
                child: _EmptyStateIllustration(
                  type: widget.type,
                  primary: primary,
                  muted: muted,
                ),
              ),
              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────
              Text(
                config.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ── Subtitle ──────────────────────────────────────
              Text(
                widget.subtitle ?? config.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              // ── Optional action button ─────────────────────────
              if (widget.onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: widget.onAction,
                  icon: Icon(config.actionIcon, size: 18),
                  label: Text(widget.actionLabel ?? config.actionLabel),
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
            ],
          ),
        ),
      ),
    );
  }

  _EmptyStateConfig _configFor(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.search:
        return const _EmptyStateConfig(
          title: 'Search for Anime',
          subtitle:
              'Discover thousands of titles.\nYour recent searches will appear here.',
          actionIcon: Icons.search_rounded,
          actionLabel: 'Start Searching',
        );
      case EmptyStateType.searchNoResults:
        return const _EmptyStateConfig(
          title: 'No Results Found',
          subtitle:
              'We couldn\'t find any anime matching your search.\nTry a different term.',
          actionIcon: Icons.refresh_rounded,
          actionLabel: 'Clear Search',
        );
      case EmptyStateType.favorites:
        return const _EmptyStateConfig(
          title: 'No Saved Anime Yet',
          subtitle:
              'Bookmark your favourite titles from\nthe detail screen to see them here.',
          actionIcon: Icons.explore_rounded,
          actionLabel: 'Explore Anime',
        );
      case EmptyStateType.seasonal:
        return const _EmptyStateConfig(
          title: 'No Seasonal Anime',
          subtitle:
              'Nothing found for this season.\nTry selecting a different season.',
          actionIcon: Icons.calendar_month_rounded,
          actionLabel: 'Change Season',
        );
      case EmptyStateType.genres:
        return const _EmptyStateConfig(
          title: 'No Genres Found',
          subtitle:
              'Could not load the genre list.\nPlease check your connection.',
          actionIcon: Icons.refresh_rounded,
          actionLabel: 'Retry',
        );
      case EmptyStateType.genreDetail:
        return const _EmptyStateConfig(
          title: 'No Anime in This Genre',
          subtitle:
              'This genre appears to be empty.\nTry exploring another genre.',
          actionIcon: Icons.arrow_back_rounded,
          actionLabel: 'Go Back',
        );
      case EmptyStateType.recommendations:
        return const _EmptyStateConfig(
          title: 'No Recommendations',
          subtitle: 'We couldn\'t find any recommendations\nfor this title.',
          actionIcon: Icons.explore_rounded,
          actionLabel: 'Explore',
        );
    }
  }
}

// ── Config ────────────────────────────────────────────────────────
class _EmptyStateConfig {
  final String title;
  final String subtitle;
  final IconData actionIcon;
  final String actionLabel;

  const _EmptyStateConfig({
    required this.title,
    required this.subtitle,
    required this.actionIcon,
    required this.actionLabel,
  });
}

// ── Illustration ──────────────────────────────────────────────────
class _EmptyStateIllustration extends StatelessWidget {
  final EmptyStateType type;
  final Color primary;
  final Color muted;

  const _EmptyStateIllustration({
    required this.type,
    required this.primary,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _IllustrationPainter(
          type: type,
          primary: primary,
          muted: muted,
        ),
      ),
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────
class _IllustrationPainter extends CustomPainter {
  final EmptyStateType type;
  final Color primary;
  final Color muted;

  const _IllustrationPainter({
    required this.type,
    required this.primary,
    required this.muted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case EmptyStateType.search:
      case EmptyStateType.searchNoResults:
        _drawSearch(canvas, size);
        break;
      case EmptyStateType.favorites:
        _drawFavorites(canvas, size);
        break;
      case EmptyStateType.seasonal:
        _drawSeasonal(canvas, size);
        break;
      case EmptyStateType.genres:
      case EmptyStateType.genreDetail:
        _drawGenres(canvas, size);
        break;
      case EmptyStateType.recommendations:
        _drawRecommendations(canvas, size);
        break;
    }
  }

  // ── Search illustration ───────────────────────────────────────
  // A magnifying glass with subtle decorative dots.
  void _drawSearch(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer glow circle
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()..color = primary.withAlpha(12),
    );

    // Lens circle outline
    final lensPaint = Paint()
      ..color = primary.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(Offset(cx - 10, cy - 10), 44, lensPaint);

    // Lens fill
    canvas.drawCircle(
      Offset(cx - 10, cy - 10),
      44,
      Paint()..color = primary.withAlpha(15),
    );

    // Handle
    final handlePaint = Paint()
      ..color = primary.withAlpha(80)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx + 22, cy + 22),
      Offset(cx + 48, cy + 48),
      handlePaint,
    );

    // Inner cross lines (no results variant)
    if (type == EmptyStateType.searchNoResults) {
      final crossPaint = Paint()
        ..color = primary.withAlpha(60)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(cx - 22, cy - 22),
        Offset(cx + 2, cy + 2),
        crossPaint,
      );
      canvas.drawLine(
        Offset(cx + 2, cy - 22),
        Offset(cx - 22, cy + 2),
        crossPaint,
      );
    } else {
      // Shimmer lines inside lens
      final linePaint = Paint()
        ..color = primary.withAlpha(40)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - 26, cy - 14),
        Offset(cx + 6, cy - 14),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - 26, cy - 4),
        Offset(cx - 2, cy - 4),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - 26, cy + 6),
        Offset(cx + 2, cy + 6),
        linePaint,
      );
    }

    // Decorative dots
    _drawDots(canvas, size);
  }

  // ── Favorites illustration ────────────────────────────────────
  // A large bookmark shape with a star inside.
  void _drawFavorites(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()..color = primary.withAlpha(12),
    );

    // Bookmark shape
    final bookmarkPath = Path();
    const bLeft = 45.0;
    const bRight = 115.0;
    const bTop = 28.0;
    const bBottom = 132.0;
    const bMidY = 90.0;

    bookmarkPath.moveTo(bLeft, bTop);
    bookmarkPath.lineTo(bRight, bTop);
    bookmarkPath.lineTo(bRight, bBottom);
    bookmarkPath.lineTo((bLeft + bRight) / 2, bMidY);
    bookmarkPath.lineTo(bLeft, bBottom);
    bookmarkPath.close();

    // Fill
    canvas.drawPath(
      bookmarkPath,
      Paint()..color = primary.withAlpha(20),
    );

    // Stroke
    canvas.drawPath(
      bookmarkPath,
      Paint()
        ..color = primary.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );

    // Star inside bookmark
    _drawStar(
      canvas,
      center: Offset(cx, cy - 12),
      radius: 18,
      color: primary.withAlpha(120),
    );

    _drawDots(canvas, size);
  }

  // ── Seasonal illustration ─────────────────────────────────────
  // A calendar page with a sparkle.
  void _drawSeasonal(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()..color = primary.withAlpha(12),
    );

    // Calendar body
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + 4),
        width: 96,
        height: 88,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rrect,
      Paint()..color = primary.withAlpha(18),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = primary.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Header bar
    final headerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 48, cy - 40, 96, 24),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      headerRect,
      Paint()..color = primary.withAlpha(50),
    );

    // Calendar grid dots
    final dotPaint = Paint()..color = primary.withAlpha(80);
    const cols = 3;
    const rows = 2;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(
            cx - 28 + c * 28.0,
            cy + 10 + r * 24.0,
          ),
          4,
          dotPaint,
        );
      }
    }

    // Clip pins
    final pinPaint = Paint()..color = primary.withAlpha(100);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 24, cy - 44), width: 6, height: 16),
        const Radius.circular(3),
      ),
      pinPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 24, cy - 44), width: 6, height: 16),
        const Radius.circular(3),
      ),
      pinPaint,
    );

    // Sparkle
    _drawSparkle(canvas, Offset(cx + 52, cy - 44), primary, 10);
    _drawDots(canvas, size);
  }

  // ── Genres illustration ───────────────────────────────────────
  // A grid of rounded squares.
  void _drawGenres(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()..color = primary.withAlpha(12),
    );

    // 2x2 grid of rounded squares
    const tileSize = 36.0;
    const gap = 10.0;
    const totalW = tileSize * 2 + gap;
    const totalH = tileSize * 2 + gap;
    final startX = cx - totalW / 2;
    final startY = cy - totalH / 2;

    final alphas = [80, 50, 50, 30];
    var i = 0;
    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < 2; c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startX + c * (tileSize + gap),
            startY + r * (tileSize + gap),
            tileSize,
            tileSize,
          ),
          const Radius.circular(10),
        );
        canvas.drawRRect(
          rect,
          Paint()..color = primary.withAlpha(alphas[i]),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..color = primary.withAlpha(60)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        i++;
      }
    }

    _drawSparkle(canvas, Offset(cx + 58, cy - 50), primary, 10);
    _drawDots(canvas, size);
  }

  // ── Recommendations illustration ──────────────────────────────
  // Three stacked film frames.
  void _drawRecommendations(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()..color = primary.withAlpha(12),
    );

    // Three layered cards (back to front)
    final offsets = [
      const Offset(10, -10),
      const Offset(5, -5),
      const Offset(0, 0),
    ];
    final alphas = [20, 35, 55];

    for (var i = 0; i < 3; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + offsets[i].dx, cy + offsets[i].dy),
          width: 80,
          height: 106,
        ),
        const Radius.circular(12),
      );
      canvas.drawRRect(rect, Paint()..color = primary.withAlpha(alphas[i]));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = primary.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Play button on front card
    final playPath = Path();
    playPath.moveTo(cx - 10, cy - 16);
    playPath.lineTo(cx + 18, cy);
    playPath.lineTo(cx - 10, cy + 16);
    playPath.close();
    canvas.drawPath(
      playPath,
      Paint()..color = primary.withAlpha(120),
    );

    _drawDots(canvas, size);
  }

  // ── Shared helpers ────────────────────────────────────────────

  void _drawStar(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = (i * 3.14159265 / points) - 3.14159265 / 2;
      final x = center.dx + r * _cos(angle);
      final y = center.dy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSparkle(
      Canvas canvas, Offset center, Color color, double size) {
    final paint = Paint()
      ..color = color.withAlpha(120)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Four lines radiating outward
    for (var i = 0; i < 4; i++) {
      final angle = i * 3.14159265 / 2;
      canvas.drawLine(
        Offset(
          center.dx + _cos(angle) * size * 0.3,
          center.dy + _sin(angle) * size * 0.3,
        ),
        Offset(
          center.dx + _cos(angle) * size,
          center.dy + _sin(angle) * size,
        ),
        paint,
      );
    }

    // Center dot
    canvas.drawCircle(
      center,
      size * 0.2,
      Paint()..color = color.withAlpha(120),
    );
  }

  void _drawDots(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = muted.withAlpha(40);
    final positions = [
      Offset(size.width * 0.12, size.height * 0.2),
      Offset(size.width * 0.88, size.height * 0.18),
      Offset(size.width * 0.08, size.height * 0.78),
      Offset(size.width * 0.92, size.height * 0.8),
      Offset(size.width * 0.18, size.height * 0.5),
      Offset(size.width * 0.84, size.height * 0.5),
    ];
    final radii = [4.0, 3.0, 3.0, 4.0, 2.5, 2.5];
    for (var i = 0; i < positions.length; i++) {
      canvas.drawCircle(positions[i], radii[i], dotPaint);
    }
  }

  // Trig helpers — avoids dart:math import in painter
  double _cos(double angle) {
    // Simple Taylor series approximation good enough for illustrations.
    // ignore: prefer_math_over_direct_calls
    return _taylorCos(angle);
  }

  double _sin(double angle) {
    return _taylorCos(angle - 3.14159265 / 2);
  }

  double _taylorCos(double x) {
    // Normalize to [-π, π]
    while (x > 3.14159265) { x -= 2 * 3.14159265; }
while (x < -3.14159265) { x += 2 * 3.14159265; }
    // cos(x) ≈ 1 - x²/2 + x⁴/24 - x⁶/720
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }

  @override
  bool shouldRepaint(_IllustrationPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.primary != primary ||
      oldDelegate.muted != muted;
}