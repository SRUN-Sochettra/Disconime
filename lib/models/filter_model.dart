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

  // FIX: Added == operator and hashCode so FilterSheet can detect
  // whether the filter actually changed before firing an API call.
  @override
  bool operator ==(Object other) =>
      other is AnimeFilter &&
      type == other.type &&
      filter == other.filter &&
      rating == other.rating &&
      orderBy == other.orderBy &&
      sort == other.sort;

  @override
  int get hashCode => Object.hash(type, filter, rating, orderBy, sort);

  /// Whether any filter is active.
  bool get isActive =>
      type != null || filter != null || rating != null || orderBy != null;

  /// Count of active filters for badge display.
  // NOTE: sort is intentionally excluded from isActive and activeCount
  // because it is a display preference, not a content filter.
  // Change this if your UX requires sort to count as an active filter.
  int get activeCount {
    int count = 0;
    if (type != null) count++;
    if (filter != null) count++;
    if (rating != null) count++;
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