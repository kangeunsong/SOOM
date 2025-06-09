import 'package:flutter/material.dart';

class SoomiScreen extends StatefulWidget {
  const SoomiScreen({super.key});

  @override
  State<SoomiScreen> createState() => _SoomiScreenState();
}

class _SoomiScreenState extends State<SoomiScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 메인 콘텐츠 영역
          const Expanded(
            child: Center(
              child: Text(
                'Soomi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 하단 텍스트 입력 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    // 전송 버튼 클릭 시 처리
                    String message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      // 여기에 메시지 전송 로직 추가
                      print('전송된 메시지: $message');
                      _textController.clear();
                    }
                  },
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
