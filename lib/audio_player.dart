import 'dart:io';

import 'package:win32/win32.dart';

class AudioPlayer {
  AudioPlayer._();

  static void playWavAssetsDebug(String asset) {
    final file =
        '${File(Platform.resolvedExecutable).parent.path}\\data\\flutter_assets\\$asset';

    PlaySound(TEXT(file), NULL, SND_FILENAME | SND_ASYNC);
  }
}