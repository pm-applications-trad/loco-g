import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) {
      _player.stop();
    }
  }

  Future<void> _safePlay(String assetPath) async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource(assetPath));
    } catch (_) {}
  }

  Future<void> playTap() => _safePlay('sounds/tap.mp3');

  Future<void> playSuccess() => _safePlay('sounds/success.mp3');

  Future<void> playError() => _safePlay('sounds/error.mp3');

  Future<void> playReveal() => _safePlay('sounds/reveal.mp3');

  Future<void> playCountdown() => _safePlay('sounds/countdown.mp3');

  Future<void> playBackgroundMusic() async {
    if (!_enabled) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.3);
      await _player.play(AssetSource('sounds/background.mp3'));
    } catch (_) {}
  }

  Future<void> stopBackgroundMusic() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
