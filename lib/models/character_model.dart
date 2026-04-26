/// A full character model returned by the Jikan /characters endpoints.
/// This is separate from [AnimeCharacter] which is a lightweight
/// model used only inside the detail screen character tab.
class Character {
  final int malId;
  final String name;
  final String? nameKanji;
  final String imageUrl;
  final int favorites;
  final String? about;
  final List<CharacterAnime> animeography;
  final List<CharacterVoiceActor> voiceActors;

  const Character({
    required this.malId,
    required this.name,
    this.nameKanji,
    required this.imageUrl,
    required this.favorites,
    this.about,
    required this.animeography,
    required this.voiceActors,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    // Top characters endpoint wraps the character in a 'character' key.
    // Full character endpoint returns the data directly.
    final data = json['character'] as Map<String, dynamic>? ?? json;

    final images = data['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    // Animeography
    final animeList = <CharacterAnime>[];
    final rawAnime = json['anime'] as List<dynamic>?;
    if (rawAnime != null) {
      for (final item in rawAnime) {
        try {
          animeList.add(
            CharacterAnime.fromJson(item as Map<String, dynamic>),
          );
        } catch (_) {}
      }
    }

    // Voice actors
    final vaList = <CharacterVoiceActor>[];
    final rawVa = json['voices'] as List<dynamic>?;
    if (rawVa != null) {
      for (final item in rawVa) {
        try {
          vaList.add(
            CharacterVoiceActor.fromJson(item as Map<String, dynamic>),
          );
        } catch (_) {}
      }
    }

    return Character(
      malId: data['mal_id'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      nameKanji: data['name_kanji'] as String?,
      imageUrl: jpg?['image_url'] as String? ?? '',
      favorites: json['favorites'] as int? ?? 0,
      about: data['about'] as String?,
      animeography: animeList,
      voiceActors: vaList,
    );
  }
}

/// An anime that a character appears in.
class CharacterAnime {
  final int malId;
  final String title;
  final String imageUrl;
  final String role;

  const CharacterAnime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.role,
  });

  factory CharacterAnime.fromJson(Map<String, dynamic> json) {
    final anime = json['anime'] as Map<String, dynamic>? ?? {};
    final images = anime['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    return CharacterAnime(
      malId: anime['mal_id'] as int? ?? 0,
      title: anime['title'] as String? ?? '',
      imageUrl: jpg?['image_url'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

/// A voice actor for a character.
class CharacterVoiceActor {
  final int malId;
  final String name;
  final String imageUrl;
  final String language;

  const CharacterVoiceActor({
    required this.malId,
    required this.name,
    required this.imageUrl,
    required this.language,
  });

  factory CharacterVoiceActor.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final images = person['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    return CharacterVoiceActor(
      malId: person['mal_id'] as int? ?? 0,
      name: person['name'] as String? ?? '',
      imageUrl: jpg?['image_url'] as String? ?? '',
      language: json['language'] as String? ?? '',
    );
  }
}

/// Lightweight model used in the top characters list.
/// Full detail is fetched separately on tap.
class TopCharacter {
  final int malId;
  final String name;
  final String? nameKanji;
  final String imageUrl;
  final int favorites;
  final List<String> animeNames;

  final String? role; // FIX: Add role field

  const TopCharacter({
    required this.malId,
    required this.name,
    this.nameKanji,
    required this.imageUrl,
    required this.favorites,
    required this.animeNames,
    this.role, // FIX: Optional so existing code doesn't break
  });

  factory TopCharacter.fromJson(Map<String, dynamic> json) {
    final character = json['character'] as Map<String, dynamic>? ?? {};
    final images = character['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    // Extract anime names this character appears in.
    final animeNames = <String>[];
    final rawAnime = json['anime'] as List<dynamic>?;
    if (rawAnime != null) {
      for (final item in rawAnime) {
        try {
          final anime =
              (item as Map<String, dynamic>)['anime'] as Map<String, dynamic>?;
          final title = anime?['title'] as String?;
          if (title != null) animeNames.add(title);
        } catch (_) {}
      }
    }

    return TopCharacter(
      malId: character['mal_id'] as int? ?? 0,
      name: character['name'] as String? ?? '',
      nameKanji: character['name_kanji'] as String?,
      imageUrl: jpg?['image_url'] as String? ?? '',
      favorites: json['favorites'] as int? ?? 0,
      animeNames: animeNames,
      role: null, // Not available in top characters list
    );
  }

  /// Formatted favorites count (e.g. 12.3K, 1.2M).
  String get formattedFavorites {
    if (favorites >= 1000000) {
      return '${(favorites / 1000000).toStringAsFixed(1)}M';
    }
    if (favorites >= 1000) {
      return '${(favorites / 1000).toStringAsFixed(1)}K';
    }
    return favorites.toString();
  }
}