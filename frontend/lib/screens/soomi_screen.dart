import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class SoomiScreen extends StatefulWidget {
  const SoomiScreen({super.key});

  @override
  State<SoomiScreen> createState() => _SoomiScreenState();
}

class _SoomiScreenState extends State<SoomiScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedText = "";
  double _soundLevel = 0.0;
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();

    // 화면 진입 시 자동으로 음성 인식 시작
    Future.delayed(const Duration(milliseconds: 1000), () {
      _startListening();
    });
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _startListening() async {
    try {
      print("🎤 음성 인식 시작 시도...");

      // 웨이크워드 서비스를 일시 중지하고 마이크 해제
      await _pauseWakewordService();

      // 잠시 대기 후 음성 인식 시작
      await Future.delayed(const Duration(milliseconds: 500));

      bool available = await _speech.initialize(
        onError: (val) {
          print("❌ 음성 인식 오류: ${val.errorMsg}");
          _resumeWakewordService(); // 오류 시 웨이크워드 서비스 재시작
        },
        onStatus: (status) {
          print("📶 음성 인식 상태: $status");
          if (status == 'notListening' || status == 'done') {
            _resumeWakewordService(); // 음성 인식 완료 시 웨이크워드 서비스 재시작
          }
        },
      );

      print("✅ 음성 인식 사용 가능: $available");

      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = "";
        });

        await _speech.listen(
          onResult: (val) => setState(() {
            _recognizedText = val.recognizedWords;
            print("🗣️ 인식된 텍스트: ${val.recognizedWords}");
          }),
          onSoundLevelChange: (level) {
            setState(() {
              _soundLevel = level;
            });
            print("🔊 소리 레벨: $level");
          },
          localeId: "ko-KR",
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.search,
        );
      } else {
        print("❌ 음성 인식을 사용할 수 없습니다.");
        _resumeWakewordService(); // 실패 시 웨이크워드 서비스 재시작
      }
    } catch (e) {
      print("💥 음성 인식 시작 실패: $e");
      _resumeWakewordService(); // 예외 발생 시 웨이크워드 서비스 재시작
    }
  }

  void _stopListening() {
    print("🛑 음성 인식 중지");
    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
    });
    _speech.stop();
    _resumeWakewordService(); // 수동 중지 시 웨이크워드 서비스 재시작
  }

  void _sendMessage() async {
    if (_recognizedText.isNotEmpty) {
      print("📤 메시지 전송: $_recognizedText");

      setState(() {
        _messages.add("나: $_recognizedText");
        _isListening = false;
        _isSpeaking = true;
      });

      _speech.stop();

      // 간단한 응답
      String response = "네, '$_recognizedText'라고 말씀하셨군요!";

      setState(() {
        _messages.add("Soomi: $response");
      });

      // TTS로 응답 재생
      await _flutterTts.speak(response);

      setState(() {
        _recognizedText = "";
      });

      _resumeWakewordService(); // 메시지 전송 후 웨이크워드 서비스 재시작
    }
  }

  // 웨이크워드 서비스 일시 중지 (마이크 해제)
  Future<void> _pauseWakewordService() async {
    try {
      // Navigator를 통해 이전 화면(HomeScreen)의 WakewordService에 접근
      // 이 부분은 실제 구현에 따라 달라질 수 있습니다
      print("⏸️ 웨이크워드 서비스 일시 중지");
      // 실제로는 HomeScreen이나 상위 위젯에서 웨이크워드 서비스를 제어해야 합니다
    } catch (e) {
      print("⚠️ 웨이크워드 서비스 중지 실패: $e");
    }
  }

  // 웨이크워드 서비스 재시작
  Future<void> _resumeWakewordService() async {
    try {
      print("▶️ 웨이크워드 서비스 재시작");
      // 실제로는 HomeScreen이나 상위 위젯에서 웨이크워드 서비스를 제어해야 합니다
    } catch (e) {
      print("⚠️ 웨이크워드 서비스 재시작 실패: $e");
    }
  }

  @override
  void dispose() {
    print("🗑️ SoomiScreen dispose");
    _speech.stop();
    _flutterTts.stop();
    _resumeWakewordService(); // 화면 종료 시 웨이크워드 서비스 재시작
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopListening(); // 뒤로가기 시 음성 인식 중지
            Navigator.pop(context);
          },
        ),
        title: const Text('Soomi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 마이크 충돌 경고
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '웨이크워드 서비스와 마이크를 공유합니다. 음성 인식 중에는 웨이크워드가 일시 중지됩니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 메시지 목록
              Expanded(
                child: _messages.isEmpty
                    ? const Center(
                        child: Text(
                          '자동 음성 인식이 활성화되었습니다!\n\n5초마다 자동으로 음성을 인식합니다.\n말씀해 주세요!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          bool isUser = _messages[index].startsWith("나:");
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                _messages[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // 현재 인식된 텍스트 표시
              if (_recognizedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _recognizedText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 상태 표시
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  _isListening
                      ? '🎤 듣고 있습니다... 말씀해 주세요!'
                      : _isSpeaking
                          ? '🔊 응답 중...'
                          : '음성 인식 대기 중 (웨이크워드 활성화)',
                  style: TextStyle(
                    color: _isListening ? Colors.red : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 100), // FloatingActionButton 공간
            ],
          ),

          // 음성 파형 표시
          if (_isListening)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 60,
                  child: CustomPaint(
                    painter: SoundWavePainter(_soundLevel),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildRecordingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildRecordingButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 메인 버튼
          SizedBox(
            width: 80.0,
            height: 80.0,
            child: FloatingActionButton(
              heroTag: "main_button",
              onPressed: _isListening ? _sendMessage : _startListening,
              backgroundColor: _isListening ? Colors.green : Colors.blue,
              elevation: 4,
              child: Icon(
                _isListening ? Icons.send : Icons.mic,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          // 중지 버튼 (듣고 있을 때만 표시)
          if (_isListening)
            Positioned(
              bottom: 0,
              right: 90,
              child: SizedBox(
                width: 52.0,
                height: 52.0,
                child: FloatingActionButton(
                  heroTag: "stop_button",
                  onPressed: _stopListening,
                  backgroundColor: Colors.grey[300],
                  elevation: 2,
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 음성 파형을 그리는 CustomPainter
class SoundWavePainter extends CustomPainter {
  final double soundLevel;
  double smoothedSoundLevel = 0.0;

  SoundWavePainter(this.soundLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final barCount = 12;
    final barWidth = 8.0;
    final spacing = 4.0;
    final maxHeight = 30.0;
    final minHeight = 5.0;
    final cornerRadius = const Radius.circular(4.0);
    final random = Random();

    // 부드러운 애니메이션을 위한 스무딩
    smoothedSoundLevel = smoothedSoundLevel * 0.3 + soundLevel * 0.7;

    for (int i = 0; i < barCount; i++) {
      final randomFactor = 0.8 + random.nextDouble() * 0.4;
      final normalizedLevel = max(0.1, smoothedSoundLevel + 10) / 20; // 정규화
      final barHeight =
          max(minHeight, normalizedLevel * maxHeight * randomFactor);
      final x = i * (barWidth + spacing);
      final y = (size.height / 2) - (barHeight / 2);

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        cornerRadius,
      );

      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
