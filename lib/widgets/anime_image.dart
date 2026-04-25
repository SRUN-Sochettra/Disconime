import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  // Hero tag — when provided the image is wrapped in a Hero widget
  // so it animates smoothly between list and detail screen.
  final String? heroTag;

  const AnimeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    int? cacheWidth;
    int? cacheHeight;

    if (width != null && width!.isFinite && width! > 0) {
      cacheWidth = (width! * devicePixelRatio).round().clamp(1, 3000);
    }

    if (height != null && height!.isFinite && height! > 0) {
      cacheHeight = (height! * devicePixelRatio).round().clamp(1, 3000);
    }

    final image = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl.isEmpty
            ? _Placeholder(isDark: isDark)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: fit,
                memCacheWidth: cacheWidth,
                memCacheHeight: cacheHeight,
                placeholder: (context, url) => _Placeholder(isDark: isDark),
                errorWidget: (context, url, error) =>
                    _ErrorPlaceholder(isDark: isDark),
              ),
      ),
    );

    // Wrap with Hero only when a tag is provided.
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        // Keep the clipping behaviour during the flight animation.
        flightShuttleBuilder: (
          flightContext,
          animation,
          direction,
          fromContext,
          toContext,
        ) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              // Interpolate border radius from list (12) to detail (0).
              final radius = Tween<double>(
                begin: direction == HeroFlightDirection.push
                    ? borderRadius
                    : 0,
                end: direction == HeroFlightDirection.push
                    ? 0
                    : borderRadius,
              ).evaluate(animation);

              return ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: child,
              );
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: cacheWidth,
              memCacheHeight: cacheHeight,
            ),
          );
        },
        child: image,
      );
    }

    return image;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final bool isDark;
  const _Placeholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? Colors.white10 : Colors.black12,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: isDark
              ? Colors.white.withAlpha(60)
              : Colors.black.withAlpha(60),
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final bool isDark;
  const _ErrorPlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? Colors.white10 : Colors.black12,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 36,
          color: isDark
              ? Colors.white.withAlpha(80)
              : Colors.black.withAlpha(80),
        ),
      ),
    );
  }
}