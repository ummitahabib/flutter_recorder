import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class AudioService {
  final FlutterSoundRecorder _recordingSession = FlutterSoundRecorder();
  String? pathToAudio;
  final recordingPlayer = AssetsAudioPlayer();
  StreamSubscription? recorderSubscription;

  Future<String?> stopRecording() async {
    recorderSubscription?.cancel();
    _recordingSession.closeAudioSession();
    return await _recordingSession.stopRecorder();
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }
}
