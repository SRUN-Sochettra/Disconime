import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
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

    // FIX: Do NOT pass memCacheWidth/memCacheHeight —
    // these trigger synchronous decode on the main thread
    // which causes ANR when many images load at once.
    // Let CachedNetworkImage manage its own cache sizing.
    final image = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl.isEmpty
            ? _Placeholder(isDark: isDark)
            : CachedNetworkImage(
                imageUrl: _sanitizeUrl(imageUrl),
                width: width,
                height: height,
                fit: fit,
                // FIX: Limit concurrent image requests
                // by using a fixed max width for the cache
                maxWidthDiskCache: 600,
                maxHeightDiskCache: 900,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 100),
                placeholder: (context, url) =>
                    _Placeholder(isDark: isDark),
                errorWidget: (context, url, error) =>
                    _ErrorPlaceholder(isDark: isDark),
              ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
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
              imageUrl: _sanitizeUrl(imageUrl),
              fit: BoxFit.cover,
              maxWidthDiskCache: 600,
              maxHeightDiskCache: 900,
            ),
          );
        },
        child: image,
      );
    }

    return image;
  }

  // FIX: Jikan sometimes returns URLs with spaces or
  // special characters that cause decode failures
  String _sanitizeUrl(String url) {
    try {
      return Uri.encodeFull(url);
    } catch (_) {
      return url;
    }
  }
}

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