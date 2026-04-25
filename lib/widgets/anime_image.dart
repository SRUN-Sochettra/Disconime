import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const AnimeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve pixel dimensions to prevent storing full-resolution
    // images in memory when displaying smaller thumbnails.
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final memWidth = width != null
        ? (width! * devicePixelRatio).round().clamp(1, 5000)
        : null;

    final memHeight = height != null
        ? (height! * devicePixelRatio).round().clamp(1, 5000)
        : null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
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
                fit: fit,
                memCacheWidth: memWidth,
                memCacheHeight: memHeight,
                placeholder: (context, url) =>
                    _Placeholder(isDark: isDark),
                errorWidget: (context, url, error) =>
                    _ErrorPlaceholder(isDark: isDark),
              ),
      ),
    );
  }
}

/// Shown while the image is loading or if the URL is empty.
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

/// Shown when the image fails to load.
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