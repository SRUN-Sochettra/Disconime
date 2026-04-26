class Anime {
  final int malId;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final String imageUrl;
  final String? type;
  final int? episodes;
  final String? status;
  final String? duration;
  final String? rating;
  final Score score;
  final Synopsis synopsis;
  final List<String> genres;
  final String? year;
  final Trailer? trailer;

  const Anime({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.imageUrl,
    this.type,
    this.episodes,
    this.status,
    this.duration,
    this.rating,
    required this.score,
    required this.synopsis,
    required this.genres,
    this.year,
    this.trailer,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
  final genreList = <String>[];
  if (json['genres'] != null) {
    for (final v in json['genres'] as List<dynamic>) {
      final name = (v as Map<String, dynamic>)['name'];
      if (name != null) genreList.add(name as String);
    }
  }

  // Helper to safely parse numbers that might come as int or double
  double? parseScore(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
  }

  return Anime(
    malId: json['mal_id'] as int? ?? 0,
    title: json['title'] as String? ?? 'Unknown Title',
    titleEnglish: json['title_english'] as String?,
    titleJapanese: json['title_japanese'] as String?,
    imageUrl: json['images']?['jpg']?['large_image_url'] as String? ??
        json['images']?['jpg']?['image_url'] as String? ??
        '',
    type: json['type'] as String?,
    episodes: json['episodes'] as int?,
    status: json['status'] as String?,
    duration: json['duration'] as String?,
    rating: json['rating'] as String?,
    score: Score(
      value: parseScore(json['score']),
      scoredBy: json['scored_by'] as int?,
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
    ),
    synopsis: Synopsis(
      text: json['synopsis'] as String? ?? 'No synopsis available.',
      background: json['background'] as String?,
    ),
    genres: genreList,
    year: json['year']?.toString() ?? 
          json['aired']?['prop']?['from']?['year']?.toString(),
    trailer: json['trailer'] != null
        ? Trailer.fromJson(json['trailer'] as Map<String, dynamic>)
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'title_english': titleEnglish,
      'title_japanese': titleJapanese,
      'image_url': imageUrl,
      'type': type,
      'episodes': episodes,
      'status': status,
      'duration': duration,
      'rating': rating,
      'score': score.value,
      'scored_by': score.scoredBy,
      'rank': score.rank,
      'popularity': score.popularity,
      'synopsis': synopsis.text,
      'background': synopsis.background,
      'genres': genres,
      'year': year,
    };
  }

  factory Anime.fromLocalJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      titleEnglish: json['title_english'] as String?,
      titleJapanese: json['title_japanese'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      type: json['type'] as String?,
      episodes: json['episodes'] as int?,
      status: json['status'] as String?,
      duration: json['duration'] as String?,
      rating: json['rating'] as String?,
      score: Score(
        value: json['score'] != null
            ? (json['score'] as num).toDouble()
            : null,
        scoredBy: json['scored_by'] as int?,
        rank: json['rank'] as int?,
        popularity: json['popularity'] as int?,
      ),
      synopsis: Synopsis(
        text: json['synopsis'] as String? ?? 'No synopsis available.',
        background: json['background'] as String?,
      ),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      year: json['year'] as String?,
      // Trailer is not persisted locally — not needed for favorites.
    );
  }
}

// ── Score ─────────────────────────────────────────────────────────
class Score {
  final double? value;
  final int? scoredBy;
  final int? rank;
  final int? popularity;

  const Score({
    this.value,
    this.scoredBy,
    this.rank,
    this.popularity,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      value: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      scoredBy: json['scored_by'] as int?,
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
    );
  }
}

// ── Synopsis ──────────────────────────────────────────────────────
class Synopsis {
  final String text;
  final String? background;

  const Synopsis({
    required this.text,
    this.background,
  });

  factory Synopsis.fromJson(Map<String, dynamic> json) {
    return Synopsis(
      text: json['synopsis'] as String? ?? 'No synopsis available.',
      background: json['background'] as String?,
    );
  }
}

// ── Trailer ───────────────────────────────────────────────────────
class Trailer {
  final String? youtubeId;
  final String? url;
  final String? thumbnailUrl;

  const Trailer({
    this.youtubeId,
    this.url,
    this.thumbnailUrl,
  });

  factory Trailer.fromJson(Map<String, dynamic> json) {
    // Jikan returns images.maximum_image_url for the best thumbnail.
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    return Trailer(
      youtubeId: json['youtube_id'] as String?,
      url: json['url'] as String?,
      thumbnailUrl: jpg?['maximum_image_url'] as String? ??
          jpg?['large_image_url'] as String? ??
          jpg?['image_url'] as String?,
    );
  }

  /// Whether this trailer has enough data to be playable/displayable.
  bool get isValid =>
      youtubeId != null &&
      youtubeId!.isNotEmpty &&
      thumbnailUrl != null &&
      thumbnailUrl!.isNotEmpty;

  /// YouTube watch URL.
  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  /// YouTube embed URL (used in WebView if added later).
  String get embedUrl =>
      'https://www.youtube.com/embed/$youtubeId?autoplay=1';
}

// ── Character ─────────────────────────────────────────────────────
class AnimeCharacter {
  final int malId;
  final String name;
  final String imageUrl;
  final String role;
  final int? favorites;

  const AnimeCharacter({
    required this.malId,
    required this.name,
    required this.imageUrl,
    required this.role,
    this.favorites,
  });

  factory AnimeCharacter.fromJson(Map<String, dynamic> json) {
    final character = json['character'] as Map<String, dynamic>? ?? {};
    final images = character['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    return AnimeCharacter(
      malId: character['mal_id'] as int? ?? 0,
      name: character['name'] as String? ?? '',
      imageUrl: jpg?['large_image_url'] as String? ??
          jpg?['image_url'] as String? ??
          '',
      role: json['role'] as String? ?? '',
      // FIX: favorites is nested inside character, not at top level
      favorites: character['favorites'] as int? ?? json['favorites'] as int?,
    );
  }
}

// ── Staff ─────────────────────────────────────────────────────────
class AnimeStaff {
  final int malId;
  final String name;
  final String imageUrl;
  final List<String> positions;

  const AnimeStaff({
    required this.malId,
    required this.name,
    required this.imageUrl,
    required this.positions,
  });

  factory AnimeStaff.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final images = person['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    final positions = <String>[];
    if (json['positions'] != null) {
      for (final p in json['positions'] as List<dynamic>) {
        positions.add(p as String);
      }
    }

    return AnimeStaff(
      malId: person['mal_id'] as int? ?? 0,
      name: person['name'] as String? ?? '',
      imageUrl: jpg?['image_url'] as String? ?? '',
      positions: positions,
    );
  }
}