class AnimeFilter {
  final String? type;
  final String? filter;
  final String? rating;
  final String? orderBy;
  final String? sort;

  const AnimeFilter({
    this.type,
    this.filter,
    this.rating,
    this.orderBy,
    this.sort,
  });

  /// Returns a new [AnimeFilter] with the given fields replaced.
  AnimeFilter copyWith({
    String? Function()? type,
    String? Function()? filter,
    String? Function()? rating,
    String? Function()? orderBy,
    String? Function()? sort,
  }) {
    return AnimeFilter(
      type: type != null ? type() : this.type,
      filter: filter != null ? filter() : this.filter,
      rating: rating != null ? rating() : this.rating,
      orderBy: orderBy != null ? orderBy() : this.orderBy,
      sort: sort != null ? sort() : this.sort,
    );
  }

  /// Whether any filter is active.
  bool get isActive =>
      type != null || filter != null || rating != null || orderBy != null;

  /// Count of active filters for badge display.
  int get activeCount {
    int count = 0;
    if (type != null) count++;
    if (filter != null) count++;
    if (rating != null) count++;
    if (orderBy != null) count++;
    return count;
  }

  /// Available options — labels map to Jikan API values.
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