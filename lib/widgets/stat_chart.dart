import 'package:flutter/material.dart';

// ── Bar chart ─────────────────────────────────────────────────────

/// A single bar in [BarChart].
class BarChartData {
  final String label;
  final double value;
  final String? displayValue;

  const BarChartData({
    required this.label,
    required this.value,
    this.displayValue,
  });
}

/// A horizontal bar chart drawn entirely on Flutter canvas.
/// No external charting library needed.
class BarChart extends StatefulWidget {
  final List<BarChartData> data;
  final double maxValue;
  final String? title;

  const BarChart({
    super.key,
    required this.data,
    required this.maxValue,
    this.title,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Column(
              children: widget.data.map((item) {
                final ratio = widget.maxValue > 0
                    ? (item.value / widget.maxValue).clamp(0.0, 1.0)
                    : 0.0;
                final animatedRatio = ratio * _animation.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Label
                      SizedBox(
                        width: 80,
                        child: Text(
                          item.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Bar
                      Expanded(
                        child: Stack(
                          children: [
                            // Track
                            Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: primary.withAlpha(12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            // Fill
                            FractionallySizedBox(
                              widthFactor: animatedRatio,
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primary.withAlpha(180),
                                      primary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            // Value label inside bar
                            if (animatedRatio > 0.15)
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    item.displayValue ??
                                        item.value.toInt().toString(),
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ── Donut chart ───────────────────────────────────────────────────

/// A single segment in [DonutChart].
class DonutSegment {
  final String label;
  final double value;
  final Color? color;

  const DonutSegment({
    required this.label,
    required this.value,
    this.color,
  });
}

/// A donut chart drawn entirely on Flutter canvas.
class DonutChart extends StatefulWidget {
  final List<DonutSegment> segments;
  final String? centerLabel;
  final String? centerValue;
  final String? title;

  const DonutChart({
    super.key,
    required this.segments,
    this.centerLabel,
    this.centerValue,
    this.title,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Generate colors from primary if not provided.
    final colors = _generateColors(primary, widget.segments.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Donut
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: widget.segments,
                      colors: colors,
                      progress: _animation.value,
                      centerLabel: widget.centerLabel,
                      centerValue: widget.centerValue,
                      textStyle: theme.textTheme.labelSmall!,
                      valueStyle: theme.textTheme.titleMedium!,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),

            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.segments
                    .asMap()
                    .entries
                    .take(8)
                    .map((entry) {
                  final index = entry.key;
                  final segment = entry.value;
                  final total = widget.segments.fold<double>(
                    0,
                    (sum, s) => sum + s.value,
                  );
                  final pct = total > 0
                      ? (segment.value / total * 100).toStringAsFixed(1)
                      : '0';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            segment.label,
                            style: theme.textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static List<Color> _generateColors(Color primary, int count) {
    final List<Color> colors = [];
    for (var i = 0; i < count; i++) {
      final hue = (i * 360 / count) % 360;
      colors.add(HSLColor.fromAHSL(1, hue, 0.65, 0.55).toColor());
    }
    // Always put primary first.
    if (colors.isNotEmpty) colors[0] = primary;
    return colors;
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final List<Color> colors;
  final double progress;
  final String? centerLabel;
  final String? centerValue;
  final TextStyle textStyle;
  final TextStyle valueStyle;

  const _DonutPainter({
    required this.segments,
    required this.colors,
    required this.progress,
    this.centerLabel,
    this.centerValue,
    required this.textStyle,
    required this.valueStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;

    var startAngle = -3.14159265 / 2; // Start at top

    for (var i = 0; i < segments.length; i++) {
      final sweepAngle =
          (segments[i].value / total) * 2 * 3.14159265 * progress;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Gap between segments
    if (segments.length > 1) {
      final gapPaint = Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2;
      canvas.drawCircle(center, radius - strokeWidth / 2, gapPaint);
    }

    // Center text
    if (centerValue != null) {
      final valuePainter = TextPainter(
        text: TextSpan(
          text: centerValue,
          style: valueStyle.copyWith(fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(
        canvas,
        center - Offset(valuePainter.width / 2, valuePainter.height / 2 + 6),
      );
    }

    if (centerLabel != null) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: centerLabel,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        center -
            Offset(labelPainter.width / 2, labelPainter.height / 2 - 12),
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.segments != segments;
}

// ── Stat card ─────────────────────────────────────────────────────

/// A single KPI card shown in the summary row.
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Score distribution chart ──────────────────────────────────────

/// Displays score distribution as a mini sparkline / histogram.
class ScoreDistributionChart extends StatefulWidget {
  final Map<String, int> distribution;
  final String? title;

  const ScoreDistributionChart({
    super.key,
    required this.distribution,
    this.title,
  });

  @override
  State<ScoreDistributionChart> createState() =>
      _ScoreDistributionChartState();
}

class _ScoreDistributionChartState extends State<ScoreDistributionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    if (widget.distribution.isEmpty) return const SizedBox.shrink();

    final maxVal = widget.distribution.values
        .fold<int>(0, (max, v) => v > max ? v : max)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return SizedBox(
              height: 124,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.distribution.entries.map((entry) {
                  final ratio = maxVal > 0
                      ? (entry.value / maxVal).clamp(0.0, 1.0)
                      : 0.0;
                  final animatedRatio = ratio * _animation.value;

                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Count label
                          if (entry.value > 0)
                            Text(
                              entry.value.toString(),
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(
                                fontSize: 9,
                                color: muted,
                              ),
                            ),
                          const SizedBox(height: 2),
                          // Bar
                          Container(
                            height: 90 * animatedRatio,
                            decoration: BoxDecoration(
                              color: primary.withAlpha(
                                (100 + (ratio * 155)).toInt(),
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Score label
                          Text(
                            entry.key,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
