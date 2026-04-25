import 'package:flutter/material.dart';

/// Wraps children in a synchronized pulse animation.
/// [SkeletonBox] widgets inside will automatically read the
/// current opacity from the nearest [SkeletonLoader] ancestor.
class SkeletonLoader extends StatefulWidget {
  final Widget child;

  const SkeletonLoader({super.key, required this.child});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _controller,
      builder: (context, value, child) {
        // Maps 0..1 to 0.3..0.7 for a subtle pulse range.
        final opacity = 0.3 + (value * 0.4);
        return SkeletonScope(opacity: opacity, child: widget.child);
      },
    );
  }
}

/// Passes the current skeleton pulse opacity down the widget tree
/// via InheritedWidget so all SkeletonBox children stay in sync
/// without needing explicit controller references.
class SkeletonScope extends InheritedWidget {
  final double opacity;

  const SkeletonScope({
    super.key,
    required this.opacity,
    required super.child,
  });

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<SkeletonScope>()
            ?.opacity ??
        0.5;
  }

  @override
  bool updateShouldNotify(SkeletonScope oldWidget) =>
      oldWidget.opacity != opacity;
}

/// A single rectangular skeleton placeholder that pulses
/// in sync with the nearest [SkeletonLoader] ancestor.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = SkeletonScope.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: primary.withAlpha((opacity * 60).toInt()),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: primary.withAlpha((opacity * 40).toInt()),
          width: 1,
        ),
      ),
    );
  }
}