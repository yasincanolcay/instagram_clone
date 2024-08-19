import 'package:audioplayers/audioplayers.dart';

class AudioPlayersMethods {
  AudioPlayer player = AudioPlayer();
  //post music
  Future<void> playMusic(
    Source path,
  ) async {
    return player.play(path);
  }

  void stop() {
    player.stop();
  }
}
