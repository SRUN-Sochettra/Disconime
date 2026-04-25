import 'package:anime_discovery/models/anime_model.dart';
import 'package:anime_discovery/models/character_model.dart';
import 'package:anime_discovery/models/schedule_model.dart';

/// Centralised test fixtures — used across all test files.
/// All data is hardcoded so tests never depend on network.
class TestData {
  TestData._();

  // ── Anime fixtures ────────────────────────────────────────────
  static const Anime naruto = Anime(
    malId: 20,
    title: 'Naruto',
    titleEnglish: 'Naruto',
    titleJapanese: 'ナルト',
    imageUrl: 'https://example.com/naruto.jpg',
    type: 'TV',
    episodes: 220,
    status: 'Finished Airing',
    duration: '23 min per ep',
    rating: 'PG-13 - Teens 13 or older',
    score: Score(value: 7.98, scoredBy: 1000000, rank: 100, popularity: 1),
    synopsis: Synopsis(
      text: 'Naruto Uzumaki, a mischievous adolescent ninja...',
      background: 'Originally published in Weekly Shonen Jump.',
    ),
    genres: ['Action', 'Adventure', 'Comedy'],
    year: '2002',
  );

  static const Anime fmab = Anime(
    malId: 5114,
    title: 'Fullmetal Alchemist: Brotherhood',
    titleEnglish: 'Fullmetal Alchemist: Brotherhood',
    titleJapanese: '鋼の錬金術師 FULLMETAL ALCHEMIST',
    imageUrl: 'https://example.com/fmab.jpg',
    type: 'TV',
    episodes: 64,
    status: 'Finished Airing',
    duration: '24 min per ep',
    rating: 'R - 17+ (violence & profanity)',
    score: Score(value: 9.10, scoredBy: 2000000, rank: 1, popularity: 3),
    synopsis: Synopsis(
      text: 'Two brothers search for a Philosopher\'s Stone...',
    ),
    genres: ['Action', 'Adventure', 'Drama', 'Fantasy'],
    year: '2009',
  );

  static const Anime animeNoScore = Anime(
    malId: 999,
    title: 'No Score Anime',
    imageUrl: '',
    score: Score(),
    synopsis: Synopsis(text: 'No synopsis available.'),
    genres: [],
  );

  static List<Anime> animeList = [naruto, fmab, animeNoScore];

  // ── JSON fixtures ─────────────────────────────────────────────
  static Map<String, dynamic> get narutoJson => {
        'mal_id': 20,
        'title': 'Naruto',
        'title_english': 'Naruto',
        'title_japanese': 'ナルト',
        'images': {
          'jpg': {
            'image_url': 'https://example.com/naruto.jpg',
            'large_image_url': 'https://example.com/naruto_large.jpg',
          }
        },
        'type': 'TV',
        'episodes': 220,
        'status': 'Finished Airing',
        'duration': '23 min per ep',
        'rating': 'PG-13 - Teens 13 or older',
        'score': 7.98,
        'scored_by': 1000000,
        'rank': 100,
        'popularity': 1,
        'synopsis': 'Naruto Uzumaki, a mischievous adolescent ninja...',
        'background': 'Originally published in Weekly Shonen Jump.',
        'genres': [
          {'mal_id': 1, 'name': 'Action'},
          {'mal_id': 2, 'name': 'Adventure'},
          {'mal_id': 4, 'name': 'Comedy'},
        ],
        'year': 2002,
        'trailer': {
          'youtube_id': 'abc123',
          'url': 'https://youtube.com/watch?v=abc123',
          'images': {
            'jpg': {
              'image_url': 'https://img.youtube.com/vi/abc123/hqdefault.jpg',
              'maximum_image_url':
                  'https://img.youtube.com/vi/abc123/maxresdefault.jpg',
            }
          },
        },
      };

  static Map<String, dynamic> get fmabJson => {
        'mal_id': 5114,
        'title': 'Fullmetal Alchemist: Brotherhood',
        'title_english': 'Fullmetal Alchemist: Brotherhood',
        'title_japanese': '鋼の錬金術師 FULLMETAL ALCHEMIST',
        'images': {
          'jpg': {
            'image_url': 'https://example.com/fmab.jpg',
            'large_image_url': 'https://example.com/fmab_large.jpg',
          }
        },
        'type': 'TV',
        'episodes': 64,
        'status': 'Finished Airing',
        'duration': '24 min per ep',
        'rating': 'R - 17+ (violence & profanity)',
        'score': 9.10,
        'scored_by': 2000000,
        'rank': 1,
        'popularity': 3,
        'synopsis': 'Two brothers search for a Philosopher\'s Stone...',
        'background': null,
        'genres': [
          {'mal_id': 1, 'name': 'Action'},
          {'mal_id': 2, 'name': 'Adventure'},
          {'mal_id': 8, 'name': 'Drama'},
          {'mal_id': 10, 'name': 'Fantasy'},
        ],
        'year': 2009,
        'trailer': null,
      };

  static Map<String, dynamic> get apiListResponse => {
        'data': [narutoJson, fmabJson],
        'pagination': {
          'last_visible_page': 5,
          'has_next_page': true,
          'current_page': 1,
          'items': {'count': 2, 'total': 100, 'per_page': 25},
        },
      };

  static Map<String, dynamic> get apiDetailResponse => {
        'data': narutoJson,
      };

  static Map<String, dynamic> get apiEmptyResponse => {
        'data': [],
        'pagination': {
          'last_visible_page': 1,
          'has_next_page': false,
          'current_page': 1,
          'items': {'count': 0, 'total': 0, 'per_page': 25},
        },
      };

  // ── Character fixtures ────────────────────────────────────────
  static Map<String, dynamic> get characterJson => {
        'character': {
          'mal_id': 17,
          'name': 'Naruto Uzumaki',
          'name_kanji': 'うずまきナルト',
          'images': {
            'jpg': {
              'image_url': 'https://example.com/naruto_char.jpg',
            }
          },
          'about': 'Naruto Uzumaki is the main character.',
        },
        'role': 'Main',
        'favorites': 50000,
        'voice_actors': [],
      };

  static Map<String, dynamic> get topCharacterJson => {
        'character': {
          'mal_id': 17,
          'name': 'Naruto Uzumaki',
          'name_kanji': 'うずまきナルト',
          'images': {
            'jpg': {
              'image_url': 'https://example.com/naruto_char.jpg',
            }
          },
        },
        'favorites': 50000,
        'anime': [
          {
            'anime': {
              'mal_id': 20,
              'title': 'Naruto',
              'images': {
                'jpg': {'image_url': 'https://example.com/naruto.jpg'}
              },
            },
            'role': 'Main',
          }
        ],
      };

  // ── Schedule fixtures ─────────────────────────────────────────
  static Map<String, dynamic> get scheduleEntryJson => {
        ...narutoJson,
        'broadcast': {
          'day': 'Saturdays',
          'time': '19:30',
          'timezone': 'Asia/Tokyo',
          'string': 'Saturdays at 19:30 (JST)',
        },
      };

  // ── Genre fixtures ────────────────────────────────────────────
  static Map<String, dynamic> get genreJson => {
        'mal_id': 1,
        'name': 'Action',
        'count': 5000,
        'url': 'https://myanimelist.net/anime/genre/1/Action',
      };

  static Map<String, dynamic> get genresResponse => {
        'data': [genreJson],
      };
}