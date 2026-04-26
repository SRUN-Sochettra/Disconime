import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

class AnimeCardSkeleton extends StatelessWidget {
  const AnimeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 100, height: 140, borderRadius: 12),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                SkeletonBox(
                  height: 16,
                  width: double.infinity,
                  borderRadius: 6,
                ),
                SizedBox(height: 8),
                SkeletonBox(height: 16, width: 160, borderRadius: 6),
                SizedBox(height: 16),
                SkeletonBox(height: 11, width: 160, borderRadius: 6),
                SizedBox(height: 12),
                SkeletonBox(height: 11, width: 80, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationCardSkeleton extends StatelessWidget {
  const RecommendationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 130, height: 180, borderRadius: 12),
          SizedBox(height: 8),
          SkeletonBox(height: 11, width: 100, borderRadius: 6),
        ],
      ),
    );
  }
}

class AnimeListSkeleton extends StatelessWidget {
  final int itemCount;

  const AnimeListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        // FIX: use __ for second parameter to avoid duplicate identifier error
        itemBuilder: (_, __) => const AnimeCardSkeleton(),
      ),
    );
  }
}

class RecommendationListSkeleton extends StatelessWidget {
  final int itemCount;

  const RecommendationListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          // FIX: use __ for second parameter to avoid duplicate identifier error
          itemBuilder: (_, __) => const RecommendationCardSkeleton(),
        ),
      ),
    );
  }
}

class LoadMoreSkeleton extends StatelessWidget {
  const LoadMoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonLoader(
      child: AnimeCardSkeleton(),
    );
  }
}