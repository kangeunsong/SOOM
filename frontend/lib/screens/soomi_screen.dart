import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class SoomiScreen extends StatefulWidget {
  const SoomiScreen({super.key});

  @override
  State<SoomiScreen> createState() => _SoomiScreenState();
}

class _SoomiScreenState extends State<SoomiScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Map<String, String>> _chat = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    // 초기 인사말 추가
    setState(() {
      _chat.add({"sumi": "안녕하세요! 저는 수미예요. 창문 제어나 환기에 대해 도움을 드릴 수 있어요."});
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _processText(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      _chat.add({"user": input});
      _textController.clear();
      _isLoading = true;
    });

    try {
      // 정확한 IP 주소로 직접 연결
      final url = 'http://192.168.0.5:8000/iot/chat-command';

      print("🔍 [FLUTTER] 서버 연결 시도 시작...");
      print("🔍 [FLUTTER] 보낼 텍스트: '$input'");
      print("🔍 [FLUTTER] 연결 URL: $url");

      final response = await http.post(
        Uri.parse(url),
        body: {"text": input},
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      ).timeout(Duration(seconds: 10)); // 10초 타임아웃

      print("📡 [FLUTTER] 응답 받음: ${response.statusCode}");
      print("📄 [FLUTTER] 응답 내용: ${response.body}");

      if (response.statusCode == 200) {
        // UTF-8로 디코딩 강제
        final decodedBody = utf8.decode(response.bodyBytes);
        print("🔄 [FLUTTER] UTF-8 디코딩 후: $decodedBody");

        final data = json.decode(decodedBody);
        final reply = data["message"] ?? "응답을 이해하지 못했어요.";
        final action = data["action"] ?? "none";

        print("✅ [FLUTTER] 파싱 성공: $reply");
        print("✅ [FLUTTER] 액션: $action");

        setState(() {
          _chat.add({"sumi": reply});
          _isLoading = false;
        });

        // 음성 출력
        await _flutterTts.speak(reply);

        // 액션에 따른 추가 처리 (UI 피드백)
        if (action == "open") {
          _showActionFeedback("창문을 열고 있어요 🪟");
        } else if (action == "close") {
          _showActionFeedback("창문을 닫고 있어요 🪟");
        } else if (action == "greet") {
          _showActionFeedback("인사 성공! 🎉");
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("💥 [FLUTTER] 최종 오류: $e");
      setState(() {
        _chat.add({"sumi": "⚠️ 서버 연결 실패: $e"});
        _isLoading = false;
      });
      await _flutterTts.speak("서버에 문제가 있어요.");
    }
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("수미와 대화 중"),
        backgroundColor: Colors.blue[50],
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final message = _chat[index];
                final isUser = message.containsKey("user");

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      message.values.first,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.blue[800] : Colors.green[800],
                        fontFamily: 'NotoSans', // 한글 폰트 명시
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("수미가 생각하고 있어요..."),
                ],
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _processText,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: "수미에게 메시지를 보내세요",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'NotoSans', // 입력창에도 한글 폰트
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _isLoading
                      ? null
                      : () => _processText(_textController.text),
                  backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
