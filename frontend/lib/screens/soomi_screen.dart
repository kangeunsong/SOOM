import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:io';

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
  bool _isProcessing = false; // ChatGPT 처리 중 상태
  String _recognizedText = "";
  double _soundLevel = 0.0;
  List<String> _messages = [];

  // ChatGPT API 설정 (파일에서 읽어올 예정)
  String _apiKey = '';
  String _systemPrompt = '';
  bool _configLoadFailed = false; // 설정 로드 실패 상태
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _loadConfigFiles();
  }

  // 외부 파일에서 설정 읽어오기
  Future<void> _loadConfigFiles() async {
    try {
      // API 키 읽기
      final apiKeyContent = await rootBundle.loadString('assets/apikey.txt');
      _apiKey = apiKeyContent.trim();
      print("✅ API 키 로드 완료");

      // 프롬프트 읽기
      final promptContent = await rootBundle.loadString('assets/prompt.txt');
      _systemPrompt = promptContent.trim();
      print("✅ 프롬프트 로드 완료");

      // 설정 로드 성공 시 환영 메시지 재생 후 음성 인식 시작
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _playWelcomeMessage();
        }
      });
    } catch (e) {
      print("❌ 설정 파일 로드 실패: $e");
      print("⚠️ API 키와 프롬프트가 로드되지 않았습니다. 홈 화면으로 돌아갑니다.");

      setState(() {
        _configLoadFailed = true;
      });

      // 오류 발생시 홈 화면으로 돌아가기
      if (mounted) {
        // 잠시 대기 후 돌아가기 (오류 메시지를 보여주기 위해)
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
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

      // TTS 완료 후 자동으로 음성 인식 시작 (환영 메시지인 경우)
      if (!_isListening && !_isProcessing && _messages.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isListening && !_isProcessing) {
            _startListening();
          }
        });
      }
    });
  }

  // 환영 메시지 재생
  Future<void> _playWelcomeMessage() async {
    const welcomeMessage = "안녕하세요! 수미입니다. 무엇을 도와드릴까요?";

    setState(() {
      _isSpeaking = true;
      _messages.add("Soomi: $welcomeMessage");
    });

    print("🔊 환영 메시지 재생: $welcomeMessage");

    // TTS로 환영 메시지 재생
    await _flutterTts.speak(welcomeMessage);
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

  // ChatGPT API 호출 함수
  Future<Map<String, dynamic>?> _callChatGPT(String userMessage) async {
    try {
      print("🤖 ChatGPT API 호출 시작: $userMessage");

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
        body: utf8.encode(jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        })),
      );

      print("📡 ChatGPT API 응답 상태: ${response.statusCode}");

      if (response.statusCode == 200) {
        // UTF-8로 응답 디코딩
        final responseBody = utf8.decode(response.bodyBytes);
        print("🔄 UTF-8 디코딩된 응답: $responseBody");

        final data = jsonDecode(responseBody);
        final content = data['choices'][0]['message']['content'];
        print("🤖 ChatGPT 원본 응답: $content");

        // JSON 파싱 시도
        try {
          final jsonResponse = jsonDecode(content);
          print("✅ JSON 파싱 성공: $jsonResponse");

          // 메시지 내용도 올바르게 디코딩되었는지 확인
          final message = jsonResponse['message'] ?? '';
          print("📝 디코딩된 메시지: $message");

          return jsonResponse;
        } catch (e) {
          print("❌ JSON 파싱 실패: $e");
          print("📄 파싱 시도한 내용: $content");
          // JSON 파싱 실패 시 기본 응답
          return {'action': 'none', 'message': '죄송해요, 응답을 처리하는 중 오류가 발생했어요.'};
        }
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print("❌ ChatGPT API 오류: ${response.statusCode} - $errorBody");
        return {'action': 'none', 'message': '죄송해요, 서버와 연결하는 중 오류가 발생했어요.'};
      }
    } catch (e) {
      print("💥 ChatGPT API 호출 실패: $e");
      return {'action': 'none', 'message': '죄송해요, 네트워크 오류가 발생했어요.'};
    }
  }

  void _sendMessage() async {
    if (_recognizedText.isNotEmpty) {
      print("📤 메시지 전송: $_recognizedText");

      setState(() {
        _messages.add("나: $_recognizedText");
        _isListening = false;
        _isProcessing = true; // 처리 중 상태 시작
      });

      _speech.stop();

      // ChatGPT API 호출
      final chatGptResponse = await _callChatGPT(_recognizedText);

      if (chatGptResponse != null) {
        final String action = chatGptResponse['action'] ?? 'none';
        final String message = chatGptResponse['message'] ?? '응답을 받을 수 없습니다.';

        // 터미널에 action 출력
        print("🎯 ACTION: $action");

        setState(() {
          _messages.add("Soomi: $message");
          _isProcessing = false; // 처리 완료
          _isSpeaking = true;
        });

        // TTS로 응답 재생
        await _flutterTts.speak(message);

        // action에 따른 추가 동작 (필요한 경우)
        _handleAction(action);
      } else {
        setState(() {
          _messages.add("Soomi: 죄송해요, 응답을 받을 수 없습니다.");
          _isProcessing = false;
          _isSpeaking = true;
        });

        await _flutterTts.speak("죄송해요, 응답을 받을 수 없습니다.");
      }

      setState(() {
        _recognizedText = "";
      });

      _resumeWakewordService(); // 메시지 전송 후 웨이크워드 서비스 재시작
    }
  }

  // action에 따른 추가 처리
  void _handleAction(String action) {
    switch (action) {
      case 'open':
        print("🪟 창문 열기 동작 실행");
        // 여기에 실제 창문 제어 로직 추가
        break;
      case 'close':
        print("🪟 창문 닫기 동작 실행");
        // 여기에 실제 창문 제어 로직 추가
        break;
      case 'greet':
        print("👋 인사 동작");
        break;
      case 'none':
      default:
        print("❓ 알 수 없는 동작");
        break;
    }
  }

  // 웨이크워드 서비스 일시 중지 (마이크 해제)
  Future<void> _pauseWakewordService() async {
    try {
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
              // 설정 정보 표시
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _configLoadFailed ? Colors.red[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                      color: _configLoadFailed
                          ? Colors.red[200]!
                          : Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(_configLoadFailed ? Icons.error : Icons.smart_toy,
                        color: _configLoadFailed ? Colors.red : Colors.blue,
                        size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _configLoadFailed
                            ? '❌ 설정 파일 로드 실패\n2초 후 홈 화면으로 돌아갑니다...'
                            : 'ChatGPT와 연동된 음성 대화가 가능합니다.\nAPI 키: ${_apiKey.isNotEmpty ? "✅ 로드됨" : "❌ 로드 실패"} | 프롬프트: ${_systemPrompt.isNotEmpty ? "✅ 로드됨" : "❌ 로드 실패"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _configLoadFailed ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 메시지 목록
              Expanded(
                child: _configLoadFailed
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '설정 파일을 찾을 수 없습니다',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'assets/apikey.txt와 assets/prompt.txt\n파일을 확인해주세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Text(
                              '자동 음성 인식이 활성화되었습니다!\n\nChatGPT와 연동된 수미와 대화해보세요.\n"수미야", "창문 열어줘", "환기 해줘" 등을 말해보세요!',
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
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
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
              if (_recognizedText.isNotEmpty && !_configLoadFailed)
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
              if (!_configLoadFailed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    _isListening
                        ? '🎤 듣고 있습니다... 말씀해 주세요!'
                        : _isProcessing
                            ? '🤖 ChatGPT 처리 중...'
                            : _isSpeaking
                                ? '🔊 응답 중...'
                                : '음성 인식 대기 중 (웨이크워드 활성화)',
                    style: TextStyle(
                      color: _isListening
                          ? Colors.red
                          : _isProcessing
                              ? Colors.purple
                              : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 100), // FloatingActionButton 공간
            ],
          ),

          // 처리 중 로딩 표시
          if (_isProcessing && !_configLoadFailed)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ChatGPT가 생각하고 있어요...',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _configLoadFailed ? null : _buildRecordingButton(),
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
              onPressed: _isProcessing
                  ? null
                  : (_isListening ? _sendMessage : _startListening),
              backgroundColor: _isListening ? Colors.green : Colors.blue,
              elevation: 4,
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _isListening ? Icons.send : Icons.mic,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),

          // 중지 버튼 (듣고 있을 때만 표시)
          if (_isListening && !_isProcessing)
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
