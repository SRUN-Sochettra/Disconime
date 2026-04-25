import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/models/character_model.dart';
import '../helpers/test_data.dart';

void main() {
  group('AnimeCharacter.fromJson', () {
    test('parses fields correctly', () {
      final character = AnimeCharacter.fromJson(TestData.characterJson);

      expect(character.malId, 17);
      expect(character.name, 'Naruto Uzumaki');
      expect(character.role, 'Main');
      expect(character.favorites, 50000);
      expect(character.imageUrl, contains('naruto_char'));
    });
  });

  group('TopCharacter.fromJson', () {
    test('parses fields correctly', () {
      final character = TopCharacter.fromJson(TestData.topCharacterJson);

      expect(character.malId, 17);
      expect(character.name, 'Naruto Uzumaki');
      expect(character.nameKanji, 'うずまきナルト');
      expect(character.favorites, 50000);
      expect(character.animeNames, contains('Naruto'));
    });

    test('formattedFavorites formats thousands', () {
      final character = TopCharacter.fromJson(TestData.topCharacterJson);
      expect(character.formattedFavorites, '50.0K');
    });

    test('formattedFavorites formats millions', () {
      final json = Map<String, dynamic>.from(TestData.topCharacterJson);
      json['favorites'] = 1500000;
      final character = TopCharacter.fromJson(json);
      expect(character.formattedFavorites, '1.5M');
    });

    test('formattedFavorites shows raw number under 1000', () {
      final json = Map<String, dynamic>.from(TestData.topCharacterJson);
      json['favorites'] = 999;
      final character = TopCharacter.fromJson(json);
      expect(character.formattedFavorites, '999');
    });
  });

  group('CharacterVoiceActor.fromJson', () {
    test('parses fields correctly', () {
      final json = {
        'person': {
          'mal_id': 1,
          'name': 'Junko Takeuchi',
          'images': {
            'jpg': {'image_url': 'https://example.com/va.jpg'}
          },
        },
        'language': 'Japanese',
      };

      final va = CharacterVoiceActor.fromJson(json);
      expect(va.malId, 1);
      expect(va.name, 'Junko Takeuchi');
      expect(va.language, 'Japanese');
    });
  });

  group('CharacterAnime.fromJson', () {
    test('parses fields correctly', () {
      final json = {
        'anime': {
          'mal_id': 20,
          'title': 'Naruto',
          'images': {
            'jpg': {'image_url': 'https://example.com/naruto.jpg'}
          },
        },
        'role': 'Main',
      };

      final ca = CharacterAnime.fromJson(json);
      expect(ca.malId, 20);
      expect(ca.title, 'Naruto');
      expect(ca.role, 'Main');
    });
  });
}