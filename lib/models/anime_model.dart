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

  Anime({
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
    var genreList = <String>[];
    if (json['genres'] != null) {
      json['genres'].forEach((v) {
        genreList.add(v['name']);
      });
    }

    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? '',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      imageUrl: json['images']?['jpg']?['large_image_url'] ?? 
                json['images']?['jpg']?['image_url'] ?? '',
      type: json['type'],
      episodes: json['episodes'],
      status: json['status'],
      duration: json['duration'],
      rating: json['rating'],
      score: Score.fromJson(json),
      synopsis: Synopsis.fromJson(json),
      genres: genreList,
      year: json['year']?.toString() ?? json['aired']?['prop']?['from']?['year']?.toString(),
    );
  }
}

class Score {
  final double? value;
  final int? scoredBy;
  final int? rank;
  final int? popularity;

  Score({
    this.value,
    this.scoredBy,
    this.rank,
    this.popularity,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      value: json['score'] != null ? (json['score'] as num).toDouble() : null,
      scoredBy: json['scored_by'],
      rank: json['rank'],
      popularity: json['popularity'],
    );
  }
}

class Synopsis {
  final String text;
  final String? background;

  Synopsis({
    required this.text,
    this.background,
  });

  factory Synopsis.fromJson(Map<String, dynamic> json) {
    return Synopsis(
      text: json['synopsis'] ?? 'No synopsis available.',
      background: json['background'],
    );
  }
}
