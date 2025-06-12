import 'dart:async';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:permission_handler/permission_handler.dart';

const String _accessKey =
    '2rWMrOXfh5Mxg4y8sjgQE4rfj7fMIaL7Qia0xJNQdS2Q5CQAfBRhMg==';

class WakewordService {
  PorcupineManager? _porcupineManager;
  bool _isListening = false;

  Future<void> initWakeWord(Function(int) onWakeWordDetected) async {
    await _checkPermissions();

    try {
      print("🟡 웨이크워드 초기화 시작...");
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        _accessKey,
        ['assets/soomiya_ko_android_v3_0_0.ppn'],
        onWakeWordDetected,
        modelPath: 'assets/porcupine_params_ko.pv',
      );

      await _porcupineManager!.start();
      _isListening = true;
      print("🟢 웨이크워드 감지 시작됨!");
    } catch (e, stackTrace) {
      print("🔴 에러 발생: $e");
      print(stackTrace);
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void stop() {
    _porcupineManager?.stop();
    _porcupineManager?.delete();
    _isListening = false;
  }
}
