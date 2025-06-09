import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class IntervalTimer {
  final int seconds;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  IntervalTimer({required this.seconds});

  void start() {
    _timer = Timer.periodic(Duration(seconds: seconds), (_) => _playSound());
  }

  void _playSound() {
    _audioPlayer.play(AssetSource("ting.wav")); // Sound should be in assets
  }

  void stop() {
    _timer?.cancel();
  }
}
