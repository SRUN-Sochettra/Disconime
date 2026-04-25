import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/models/anime_model.dart';
import '../helpers/test_data.dart';

void main() {
  group('Anime.fromJson', () {
    test('parses all fields correctly', () {
      final anime = Anime.fromJson(TestData.narutoJson);

      expect(anime.malId, 20);
      expect(anime.title, 'Naruto');
      expect(anime.titleEnglish, 'Naruto');
      expect(anime.titleJapanese, 'ナルト');
      expect(anime.type, 'TV');
      expect(anime.episodes, 220);
      expect(anime.status, 'Finished Airing');
      expect(anime.year, '2002');
      expect(anime.genres, ['Action', 'Adventure', 'Comedy']);
      expect(anime.imageUrl, contains('naruto'));
    });

    test('parses score correctly', () {
      final anime = Anime.fromJson(TestData.narutoJson);

      expect(anime.score.value, closeTo(7.98, 0.001));
      expect(anime.score.scoredBy, 1000000);
      expect(anime.score.rank, 100);
      expect(anime.score.popularity, 1);
    });

    test('parses synopsis correctly', () {
      final anime = Anime.fromJson(TestData.narutoJson);

      expect(anime.synopsis.text, contains('Naruto Uzumaki'));
      expect(anime.synopsis.background, contains('Weekly Shonen Jump'));
    });

    test('parses trailer correctly', () {
      final anime = Anime.fromJson(TestData.narutoJson);

      expect(anime.trailer, isNotNull);
      expect(anime.trailer!.youtubeId, 'abc123');
      expect(anime.trailer!.isValid, isTrue);
      expect(
        anime.trailer!.watchUrl,
        'https://www.youtube.com/watch?v=abc123',
      );
    });

    test('handles null trailer gracefully', () {
      final anime = Anime.fromJson(TestData.fmabJson);
      expect(anime.trailer, isNull);
    });

    test('handles missing score gracefully', () {
      final json = Map<String, dynamic>.from(TestData.narutoJson);
      json.remove('score');
      json.remove('scored_by');
      json.remove('rank');
      json.remove('popularity');

      final anime = Anime.fromJson(json);

      expect(anime.score.value, isNull);
      expect(anime.score.scoredBy, isNull);
      expect(anime.score.rank, isNull);
      expect(anime.score.popularity, isNull);
    });

    test('handles missing genres gracefully', () {
      final json = Map<String, dynamic>.from(TestData.narutoJson);
      json.remove('genres');

      final anime = Anime.fromJson(json);
      expect(anime.genres, isEmpty);
    });

    test('prefers large_image_url over image_url', () {
      final anime = Anime.fromJson(TestData.narutoJson);
      expect(anime.imageUrl, contains('large'));
    });

    test('falls back to aired year when year field is null', () {
      final json = Map<String, dynamic>.from(TestData.narutoJson);
      json.remove('year');
      json['aired'] = {
        'prop': {
          'from': {'year': 2002}
        }
      };

      final anime = Anime.fromJson(json);
      expect(anime.year, '2002');
    });
  });

  group('Anime.toJson / fromLocalJson roundtrip', () {
    test('serialises and deserialises correctly', () {
      final original = TestData.naruto;
      final json = original.toJson();
      final restored = Anime.fromLocalJson(json);

      expect(restored.malId, original.malId);
      expect(restored.title, original.title);
      expect(restored.titleEnglish, original.titleEnglish);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.type, original.type);
      expect(restored.episodes, original.episodes);
      expect(restored.status, original.status);
      expect(restored.score.value, original.score.value);
      expect(restored.score.rank, original.score.rank);
      expect(restored.genres, original.genres);
      expect(restored.year, original.year);
    });
  });

  group('Score', () {
    test('fromJson handles numeric score', () {
      final score = Score.fromJson({'score': 8.5, 'rank': 10});
      expect(score.value, closeTo(8.5, 0.001));
      expect(score.rank, 10);
    });

    test('fromJson handles integer score', () {
      final score = Score.fromJson({'score': 9});
      expect(score.value, closeTo(9.0, 0.001));
    });

    test('fromJson handles null score', () {
      final score = Score.fromJson({'score': null});
      expect(score.value, isNull);
    });
  });

  group('Trailer', () {
    test('isValid returns false when youtubeId is null', () {
      const trailer = Trailer(youtubeId: null, thumbnailUrl: 'url');
      expect(trailer.isValid, isFalse);
    });

    test('isValid returns false when thumbnailUrl is null', () {
      const trailer = Trailer(youtubeId: 'abc', thumbnailUrl: null);
      expect(trailer.isValid, isFalse);
    });

    test('isValid returns true when both are present', () {
      const trailer = Trailer(youtubeId: 'abc', thumbnailUrl: 'url');
      expect(trailer.isValid, isTrue);
    });

    test('watchUrl is correctly formatted', () {
      const trailer = Trailer(youtubeId: 'testId');
      expect(
        trailer.watchUrl,
        'https://www.youtube.com/watch?v=testId',
      );
    });

    test('embedUrl is correctly formatted', () {
      const trailer = Trailer(youtubeId: 'testId');
      expect(
        trailer.embedUrl,
        'https://www.youtube.com/embed/testId?autoplay=1',
      );
    });
  });
}