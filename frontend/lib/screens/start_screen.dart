import 'package:flutter/material.dart';
import 'dart:async';

import 'home_screen.dart';
import 'login_screen.dart';

class StartScreen extends StatefulWidget {
  final Future<String> Function() checkAutoLogin;

  const StartScreen({Key? key, required this.checkAutoLogin}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartSequence();
  }

  Future<void> _handleStartSequence() async {
    print('🎬 [START] 시작화면 시퀀스 시작');

    // 최소 3초는 시작화면을 보여주되, 자동로그인 체크도 동시에 진행
    final Future<void> minimumDelay = Future.delayed(Duration(seconds: 3));
    final Future<String> autoLoginCheck = widget.checkAutoLogin();

    // 둘 다 완료될 때까지 기다림
    final results = await Future.wait([
      minimumDelay.then((_) => 'delay_complete'),
      autoLoginCheck,
    ]);

    final route = results[1] as String;
    print('🎯 [START] 자동로그인 결과: $route');

    // 결과에 따라 화면 이동
    if (mounted) {
      Widget nextScreen;
      if (route == '/home') {
        print('🏠 [START] 홈 화면으로 이동');
        nextScreen = const HomeScreen();
      } else {
        print('🔐 [START] 로그인 화면으로 이동');
        nextScreen = LoginScreen();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
  }

  Widget _buildFallbackScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade50,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.air,
                size: 80,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 40),
            Text(
              '숨',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'BREATH',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue.shade600,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '스마트 환기 시스템',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'PNG 이미지를 불러올 수 없습니다',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [START] StartScreen build');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/png/start_screen.png',
          fit: BoxFit.cover, // 전체 화면 꽉 채우기
          width: double.infinity,
          height: double.infinity,
          // PNG 로드 실패 시 대체 위젯
          errorBuilder: (context, error, stackTrace) {
            print('🚨 [START] PNG 로드 실패: $error');
            return _buildFallbackScreen();
          },
          // loadingBuilder 제거됨 - Image.asset에서는 지원하지 않음
        ),
      ),
    );
  }
}
