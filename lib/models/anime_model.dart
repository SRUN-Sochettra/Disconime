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
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final genreList = <String>[];
    if (json['genres'] != null) {
      for (final v in json['genres'] as List<dynamic>) {
        final name = (v as Map<String, dynamic>)['name'];
        if (name != null) genreList.add(name as String);
      }
    }

    return Anime(
      malId: json['mal_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
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
      score: Score.fromJson(json),
      synopsis: Synopsis.fromJson(json),
      genres: genreList,
      year: (json['year'] as int?)?.toString() ??
          (json['aired']?['prop']?['from']?['year'] as int?)?.toString(),
    );
  }

  /// Serializes the anime to a flat JSON map for local storage.
  /// We store only what we need to display in the favorites screen
  /// without needing to re-fetch from the API.
  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'title_english': titleEnglish,
      'title_japanese': titleJapanese,
      // Store image URL directly — no nested images map needed for local storage
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

  /// Deserializes from the flat local storage format produced by [toJson].
  factory Anime.fromLocalJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      titleEnglish: json['title_english'] as String?,
      titleJapanese: json['title_japanese'] as String?,
      // Local storage uses a flat image_url field
      imageUrl: json['image_url'] as String? ?? '',
      type: json['type'] as String?,
      episodes: json['episodes'] as int?,
      status: json['status'] as String?,
      duration: json['duration'] as String?,
      rating: json['rating'] as String?,
      score: Score(
        value: json['score'] != null ? (json['score'] as num).toDouble() : null,
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
    );
  }
}

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
      value: json['score'] != null ? (json['score'] as num).toDouble() : null,
      scoredBy: json['scored_by'] as int?,
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
    );
  }
}

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