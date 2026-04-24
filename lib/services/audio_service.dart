import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    try {
      // Loop anime soundtracks continuously while the application is active.
      // Note: Replace this placeholder URL with your actual anime soundtrack stream or local asset.
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')),
      );
      await _player.setLoopMode(LoopMode.all);
      _player.play();
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
