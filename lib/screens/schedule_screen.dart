import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/section_app_bar.dart';

import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import 'package:anime_discovery/providers/fetch_state.dart';

import '../router/route_names.dart';
import '../widgets/anime_image.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/skeleton_loader.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  bool _hasFetched = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    final provider = context.read<ScheduleProvider>();

    _tabController = TabController(
      length: BroadcastDay.values.length,
      vsync: this,
      initialIndex: provider.selectedDay.index,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final day = BroadcastDay.values[_tabController.index];
      provider.selectDay(day);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched && mounted) {
        _hasFetched = true;
        provider.fetchSchedule(provider.selectedDay);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: SectionAppBar(
        title: 'Schedule',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _ScheduleTabBar(
            controller: _tabController,
            primary: primary,
            theme: theme,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: BroadcastDay.values
            .map((day) => _ScheduleDayView(day: day))
            .toList(),
      ),
    );
  }
}

class _ScheduleTabBar extends StatelessWidget {
  final TabController controller;
  final Color primary;
  final ThemeData theme;

  const _ScheduleTabBar({
    required this.controller,
    required this.primary,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: primary,
          indicatorWeight: 2,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: theme.textTheme.labelMedium,
          tabs: BroadcastDay.values.map((day) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(day.label),
                  if (day.isToday) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ScheduleDayView extends StatefulWidget {
  final BroadcastDay day;

  const _ScheduleDayView({required this.day});

  @override
  State<_ScheduleDayView> createState() => _ScheduleDayViewState();
}

class _ScheduleDayViewState extends State<_ScheduleDayView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ScrollController _scrollController;
  Timer? _scrollDebounce;

  static const Duration _scrollDebounceDuration =
      Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    if (position.pixels < position.maxScrollExtent - 200) {
      _scrollDebounce?.cancel();
      return;
    }

    if (_scrollDebounce?.isActive ?? false) return;

    _scrollDebounce = Timer(_scrollDebounceDuration, () {
      if (!mounted) return;

      final provider = context.read<ScheduleProvider>();
      if (provider.stateFor(widget.day) != FetchState.loading &&
          provider.hasMoreFor(widget.day)) {
        provider.fetchSchedule(widget.day, loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final provider = context.watch<ScheduleProvider>();
    final state = provider.stateFor(widget.day);
    final entries = provider.entriesFor(widget.day);
    final errorMessage = provider.errorFor(widget.day);
    final hasMore = provider.hasMoreFor(widget.day);

    if (state == FetchState.initial ||
        (state == FetchState.loading && entries.isEmpty)) {
      return const _ScheduleSkeleton();
    }

    if (state == FetchState.error && entries.isEmpty) {
      return ErrorView(
        message: errorMessage,
        onRetry: () => provider.fetchSchedule(widget.day),
      );
    }

    if (state == FetchState.loaded && entries.isEmpty) {
      return EmptyState(
        type: EmptyStateType.seasonal,
        subtitle: 'No anime scheduled for ${widget.day.fullName}.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshDay(widget.day),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: entries.length +
            1 +
            (state == FetchState.loading || state == FetchState.error
                ? 1
                : 0) +
            (!hasMore && entries.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _DayBanner(day: widget.day, count: entries.length);
          }

          final itemIndex = index - 1;

          if (itemIndex == entries.length && state == FetchState.loading) {
            return const _ScheduleEntrySkeletonTile();
          }

          if (itemIndex == entries.length && state == FetchState.error) {
            return ErrorView(
              message: errorMessage,
              onRetry: () =>
                  provider.fetchSchedule(widget.day, loadMore: true),
              expand: false,
            );
          }

          if (itemIndex >= entries.length) {
            return _EndOfSchedule(day: widget.day);
          }

          return _ScheduleEntryTile(entry: entries[itemIndex]);
        },
      ),
    );
  }
}

class _DayBanner extends StatelessWidget {
  final BroadcastDay day;
  final int count;

  const _DayBanner({
    required this.day,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      day.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (day.isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'TODAY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$count titles airing',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEntryTile extends StatelessWidget {
  final ScheduleEntry entry;

  const _ScheduleEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final anime = entry.anime;

    // No Hero on schedule: tabs use wantKeepAlive, so the same malId can
    // exist on multiple day tabs and duplicate tags crash when pushing detail.
    const String? heroTag = null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          RouteNames.animeDetailPath(anime.malId),
          extra: anime,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimeImage(
                imageUrl: anime.imageUrl,
                width: 90,
                height: 120,
                borderRadius: 16,
                heroTag: heroTag,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimeBadge(
                        time: entry.formattedTime,
                        primary: primary,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        anime.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (anime.genres.isNotEmpty)
                        Text(
                          anime.genres.take(2).join(' • '),
                          style: theme.textTheme.labelSmall,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            anime.score.value?.toStringAsFixed(1) ?? 'N/A',
                            style: theme.textTheme.labelMedium,
                          ),
                          if (anime.episodes != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${anime.episodes} ep',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                          if (anime.type != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primary.withAlpha(60),
                                ),
                              ),
                              child: Text(
                                anime.type!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: primary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String time;
  final Color primary;
  final ThemeData theme;

  const _TimeBadge({
    required this.time,
    required this.primary,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isTba = time == 'TBA';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 12,
          color: isTba ? theme.colorScheme.onSurfaceVariant : primary,
        ),
        const SizedBox(width: 4),
        Text(
          time,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isTba ? theme.colorScheme.onSurfaceVariant : primary,
            fontWeight: isTba ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EndOfSchedule extends StatelessWidget {
  final BroadcastDay day;

  const _EndOfSchedule({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Divider(color: theme.dividerColor),
          const SizedBox(height: 16),
          Icon(
            Icons.check_circle_outline_rounded,
            color: primary.withAlpha(80),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'All ${day.fullName} titles loaded',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: 8,
        itemBuilder: (context, index) => const _ScheduleEntrySkeletonTile(),
      ),
    );
  }
}

class _ScheduleEntrySkeletonTile extends StatelessWidget {
  const _ScheduleEntrySkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Row(
          children: [
            SkeletonBox(width: 90, height: 120, borderRadius: 16),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(height: 10, width: 60, borderRadius: 4),
                  SizedBox(height: 10),
                  SkeletonBox(
                    height: 14,
                    width: double.infinity,
                    borderRadius: 4,
                  ),
                  SizedBox(height: 6),
                  SkeletonBox(height: 14, width: 140, borderRadius: 4),
                  SizedBox(height: 10),
                  SkeletonBox(height: 10, width: 100, borderRadius: 4),
                ],
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}