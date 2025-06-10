import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class IntervalTimer {
  final int intervalSeconds;
  final int totalMinutes;
  Timer? _intervalTimer;
  Timer? _endTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLooping = false;

  IntervalTimer({required this.intervalSeconds, required this.totalMinutes});

  void start() {
    _intervalTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => _playSound());

    _endTimer = Timer(Duration(minutes: totalMinutes), () {
      _intervalTimer?.cancel();
      _startLoopingSound(); // Sound when time is up
    });
  }

  void _playSound() {
    _audioPlayer.play(AssetSource("ting.wav"));
  }

  void _startLoopingSound() async {
    _isLooping = true;
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setPlaybackRate(2.0);
    _audioPlayer.play(AssetSource("ting.wav"));
  }

  void stop() {
    _intervalTimer?.cancel();
    _endTimer?.cancel();
    if (_isLooping) {
      _audioPlayer.stop();
      _isLooping = false;
    }
  }
}

