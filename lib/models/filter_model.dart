import 'package:flutter/material.dart';

class AnimeFilter {
  final String? type;
  final String? filter;
  final String? status;
  final String? rating;
  final String? genre;
  final String? orderBy;
  final String? sort;

  const AnimeFilter({
    this.type,
    this.filter,
    this.status,
    this.rating,
    this.genre,
    this.orderBy,
    this.sort,
  });

  AnimeFilter copyWith({
    String? Function()? type,
    String? Function()? filter,
    String? Function()? status,
    String? Function()? rating,
    String? Function()? genre,
    String? Function()? orderBy,
    String? Function()? sort,
  }) {
    return AnimeFilter(
      type: type != null ? type() : this.type,
      filter: filter != null ? filter() : this.filter,
      status: status != null ? status() : this.status,
      rating: rating != null ? rating() : this.rating,
      genre: genre != null ? genre() : this.genre,
      orderBy: orderBy != null ? orderBy() : this.orderBy,
      sort: sort != null ? sort() : this.sort,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AnimeFilter &&
      type == other.type &&
      filter == other.filter &&
      status == other.status &&
      rating == other.rating &&
      genre == other.genre &&
      orderBy == other.orderBy &&
      sort == other.sort;

  @override
  int get hashCode =>
      Object.hash(type, filter, status, rating, genre, orderBy, sort);

  /// Whether any filter is active.
  bool get isActive =>
      type != null ||
      filter != null ||
      status != null ||
      rating != null ||
      genre != null ||
      orderBy != null;

  /// Count of active filters for badge display.
  int get activeCount {
    int count = 0;
    if (type != null) count++;
    if (filter != null) count++;
    if (status != null) count++;
    if (rating != null) count++;
    if (genre != null) count++;
    if (orderBy != null) count++;
    return count;
  }

  static const Map<String, String> typeOptions = {
    'TV': 'tv',
    'Movie': 'movie',
    'OVA': 'ova',
    'Special': 'special',
    'ONA': 'ona',
    'Music': 'music',
  };

  static const Map<String, String> filterOptions = {
    'Airing': 'airing',
    'Upcoming': 'upcoming',
    'By Popularity': 'bypopularity',
    'Favorite': 'favorite',
  };

  static const Map<String, String> statusOptions = {
    'Airing': 'airing',
    'Complete': 'complete',
    'Upcoming': 'upcoming',
  };

  static const Map<String, String> ratingOptions = {
    'G - All Ages': 'g',
    'PG - Children': 'pg',
    'PG-13 - Teens': 'pg13',
    'R - 17+': 'r17',
    'R+ - Mild Nudity': 'r',
  };

  static const Map<String, String> orderByOptions = {
    'Score': 'score',
    'Popularity': 'popularity',
    'Rank': 'rank',
    'Title': 'title',
    'Start Date': 'start_date',
  };

  static const Map<String, String> sortOptions = {
    'Descending': 'desc',
    'Ascending': 'asc',
  };
}

// ── Character sort options ────────────────────────────────────────
enum CharacterSortOption {
  favoritesDesc,
  favoritesAsc,
  nameAsc,
  nameDesc,
}

extension CharacterSortOptionExtension on CharacterSortOption {
  String get label {
    switch (this) {
      case CharacterSortOption.favoritesDesc:
        return 'Most Favorited';
      case CharacterSortOption.favoritesAsc:
        return 'Least Favorited';
      case CharacterSortOption.nameAsc:
        return 'Name A→Z';
      case CharacterSortOption.nameDesc:
        return 'Name Z→A';
    }
  }

  IconData get icon {
    switch (this) {
      case CharacterSortOption.favoritesDesc:
        return Icons.favorite_rounded;
      case CharacterSortOption.favoritesAsc:
        return Icons.favorite_border_rounded;
      case CharacterSortOption.nameAsc:
        return Icons.sort_by_alpha_rounded;
      case CharacterSortOption.nameDesc:
        return Icons.sort_by_alpha_rounded;
    }
  }
}
// ── Favorites active filter ───────────────────────────────────────
class FavoritesActiveFilter {
  final String? type;
  final String orderBy;

  const FavoritesActiveFilter({
    this.type,
    this.orderBy = 'date_added',
  });

  FavoritesActiveFilter copyWith({
    String? Function()? type,
    String? orderBy,
  }) {
    return FavoritesActiveFilter(
      type: type != null ? type() : this.type,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  bool get isActive => type != null || orderBy != 'date_added';
}