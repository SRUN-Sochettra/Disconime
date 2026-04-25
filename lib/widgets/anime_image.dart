import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum AnimeImageSize { small, medium, large }

class AnimeImage extends StatelessWidget {
  final String imageUrl;
  final AnimeImageSize size;
  final BoxFit fit;

  const AnimeImage({
    super.key,
    required this.imageUrl,
    this.size = AnimeImageSize.medium,
    this.fit = BoxFit.cover,
  });

  double? get _width {
    switch (size) {
      case AnimeImageSize.small:
        return 60;
      case AnimeImageSize.medium:
        return 140;
      case AnimeImageSize.large:
        return null; // fills parent
    }
  }

  double? get _height {
    switch (size) {
      case AnimeImageSize.small:
        return 80;
      case AnimeImageSize.medium:
        return 200;
      case AnimeImageSize.large:
        return null; // fills parent
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (imageUrl.isEmpty) {
      return _placeholder(primary);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: _width,
      height: _height,
      fit: fit,
      // Shown while the image is downloading.
      placeholder: (context, url) => SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          children: [
            // Shimmer-like pulse background.
            _PulsingBox(width: _width, height: _height, color: primary),
            // Centered subtle icon.
            Center(
              child: Icon(
                Icons.image_outlined,
                color: primary.withAlpha(80),
                size: 24,
              ),
            ),
          ],
        ),
      ),
      // Shown when the image fails to load.
      errorWidget: (context, url, error) => SizedBox(
        width: _width,
        height: _height,
        child: Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: _iconSize),
        ),
      ),
    );
  }

  Widget _placeholder(Color primary) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: primary.withAlpha(80),
          size: _iconSize,
        ),
      ),
    );
  }

  double get _iconSize {
    switch (size) {
      case AnimeImageSize.small:
        return 24;
      case AnimeImageSize.medium:
        return 32;
      case AnimeImageSize.large:
        return 48;
    }
  }
}

/// Simple pulsing box used as a placeholder while the image loads.
class _PulsingBox extends StatefulWidget {
  final double? width;
  final double? height;
  final Color color;

  const _PulsingBox({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  State<_PulsingBox> createState() => _PulsingBoxState();
}

class _PulsingBoxState extends State<_PulsingBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.05, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: widget.color.withValues(alpha: _animation.value),
        );
      },
    );
  }
}