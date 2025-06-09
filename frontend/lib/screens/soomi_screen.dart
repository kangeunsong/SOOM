// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';

// class SoomiScreen extends StatefulWidget {
//   @override
//   _SoomiScreenState createState() => _SoomiScreenState();
// }

// class _SoomiScreenState extends State<SoomiScreen> {
//   final List<String> chatHistory = [];
//   final TextEditingController _controller = TextEditingController();
//   bool isLoading = false;
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _currentInput = '';
//   final FlutterTts _flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _startListening();
//   }

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       _speech.listen(
//         onResult: (val) {
//           setState(() {
//             _currentInput = val.recognizedWords;
//           });

//           if (val.hasConfidenceRating &&
//               val.confidence > 0.8 &&
//               val.finalResult) {
//             setState(() {
//               chatHistory.add("👤: $_currentInput");
//             });
//             _speech.stop();
//             sendToChatGPT(_currentInput);
//           }
//         },
//         localeId: 'ko_KR',
//       );
//       setState(() => _isListening = true);
//     }
//   }

//   Future<void> _speak(String text) async {
//     await _flutterTts.setLanguage("ko-KR");
//     await _flutterTts.speak(text);
//   }

//   Future<void> sendToChatGPT(String input) async {
//     setState(() {
//       chatHistory.add("👤: $input");
//       isLoading = true;
//     });

//     final response = await http.post(
//       Uri.parse("https://5912-113-198-180-200.ngrok-free.app"),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {'text': input},
//     );
//     print("🔁 서버 응답: ${response.statusCode}");
//     print("📦 응답 본문: ${response.body}");

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       String aiReply = jsonData['message'] ?? "응답이 없습니다.";
//       chatHistory.add("🤖 수미: $aiReply");
//       await _speak(aiReply);

//       setState(() {
//         isLoading = false;
//       });

//       // 응답 후 다시 듣기 시작
//       Future.delayed(Duration(milliseconds: 600), _startListening);
//     } else {
//       chatHistory.add("❌ 서버 오류");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _speech.stop();
//     _controller.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("수미와 대화하기"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatHistory.length,
//               itemBuilder: (context, index) => ListTile(
//                 title: Text(chatHistory[index]),
//               ),
//             ),
//           ),
//           if (isLoading) CircularProgressIndicator(),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     onSubmitted: (value) {
//                       sendToChatGPT(value);
//                       _controller.clear();
//                     },
//                     decoration: InputDecoration(hintText: "말씀해주세요..."),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     sendToChatGPT(_controller.text);
//                     _controller.clear();
//                   },
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;

// class SoomiScreen extends StatefulWidget {
//   const SoomiScreen({super.key});

//   @override
//   State<SoomiScreen> createState() => _SoomiScreenState();
// }

// class _SoomiScreenState extends State<SoomiScreen> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   final FlutterTts _flutterTts = FlutterTts();

//   bool _isListening = false;
//   String _text = "수미에게 말을 걸어보세요.";
//   List<Map<String, String>> _chat = [];

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         onResult: (result) {
//           if (result.finalResult) {
//             setState(() {
//               _isListening = false;
//               _text = result.recognizedWords;
//               _chat.add({"user": _text});
//             });
//             _processText(_text);
//           }
//         },
//       );
//     }
//   }

//   Future<void> _processText(String input) async {
//     try {
//       final uri = Uri.parse('http://localhost:8000/iot/chat-command');
//       final response = await http.post(uri, body: {"text": input});
//       final data = json.decode(response.body);

//       final reply = data["message"] ?? "응답을 이해하지 못했어요.";
//       setState(() {
//         _chat.add({"sumi": reply});
//       });
//       await _flutterTts.speak(reply);
//     } catch (e) {
//       setState(() {
//         _chat.add({"sumi": "⚠️ 서버 오류"});
//       });
//       await _flutterTts.speak("서버에 문제가 있어요.");
//     }
//   }

//   @override
//   void dispose() {
//     _speech.stop();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(),
//         title: const Text("수미와 대화 중"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: _chat
//                   .map((e) => Align(
//                         alignment: e.containsKey("user")
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           decoration: BoxDecoration(
//                             color: e.containsKey("user")
//                                 ? Colors.blue[100]
//                                 : Colors.green[100],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(e.values.first),
//                         ),
//                       ))
//                   .toList(),
//             ),
//           ),
//           const Divider(),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: ElevatedButton.icon(
//               onPressed: _isListening ? null : _startListening,
//               icon: const Icon(Icons.mic),
//               label: const Text("말하기"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart' as stt;

class SoomiScreen extends StatefulWidget {
  const SoomiScreen({super.key});

  @override
  State<SoomiScreen> createState() => _SoomiScreenState();
}

class _SoomiScreenState extends State<SoomiScreen> {
  // final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // bool _isListening = false;
  String _text = "";
  List<Map<String, String>> _chat = [];
  final TextEditingController _textController = TextEditingController();

  // Future<void> _startListening() async {
  //   bool available = await _speech.initialize();
  //   if (available) {
  //     setState(() => _isListening = true);
  //     _speech.listen(
  //       onResult: (result) {
  //         if (result.finalResult) {
  //           setState(() {
  //             _isListening = false;
  //             _text = result.recognizedWords;
  //             _chat.add({"user": _text});
  //           });
  //           _processText(_text);
  //         }
  //       },
  //     );
  //   }
  // }

  Future<void> _processText(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      _chat.add({"user": input});
      _textController.clear();
    });

    try {
      final uri = Uri.parse('http://172.20.10.3:8000/iot/chat-command');
      final response = await http.post(uri, body: {"text": input});
      final data = json.decode(response.body);

      final reply = data["message"] ?? "응답을 이해하지 못했어요.";
      setState(() {
        _chat.add({"sumi": reply});
      });
      await _flutterTts.speak(reply);
    } catch (e) {
      print("❌ 서버 요청 오류: $e");
      setState(() {
        _chat.add({"sumi": "⚠️ 서버 오류"});
      });
      // await _flutterTts.speak("서버에 문제가 있어요."); // 음성 출력 임시로 주석처리해놓음
    }
  }

  @override
  void dispose() {
    // _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("수미와 대화 중"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _chat
                  .map((e) => Align(
                        alignment: e.containsKey("user")
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: e.containsKey("user")
                                ? Colors.blue[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(e.values.first),
                        ),
                      ))
                  .toList(),
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
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _processText(_textController.text),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
