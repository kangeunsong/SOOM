import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/start_screen.dart'; // 👈 추가

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ApiService _apiService = ApiService();

  // 자동로그인 확인 함수 (기존 코드 그대로)
  Future<String> _checkAutoLogin() async {
    print('🚀 [MAIN] 앱 초기화 및 자동로그인 확인 시작');

    try {
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();

      print('📱 [MAIN] FlutterSecureStorage에서 자동로그인 설정 확인 중...');
      String? rememberMe = await secureStorage.read(key: 'rememberMe');
      String? token = await secureStorage.read(key: 'token');
      String? username = await secureStorage.read(key: 'username');

      print('🔒 [MAIN] 자동로그인 설정: $rememberMe');
      print('🔑 [MAIN] 저장된 토큰 존재: ${token != null}');
      print('👤 [MAIN] 저장된 사용자명: $username');

      if (token != null) {
        print('🔍 [MAIN] 토큰 길이: ${token.length}자');
        print(
            '🔍 [MAIN] 토큰 시작: ${token.length > 10 ? token.substring(0, 10) : token}...');
      }

      if (rememberMe == 'true' && token != null && token.trim().isNotEmpty) {
        print('🔄 [MAIN] 토큰 유효성 검증 중...');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        String? username = await secureStorage.read(key: 'username');
        if (username != null) {
          await prefs.setString('username', username);
        }

        final isValidToken = await _apiService.validateToken();

        if (isValidToken) {
          print('✅ [MAIN] 토큰 유효, 자동로그인 성공 - 홈 화면으로 이동');
          return '/home';
        } else {
          print('❌ [MAIN] 토큰 무효, 저장된 데이터 정리 후 로그인 화면으로 이동');
          await secureStorage.delete(key: 'token');
          await secureStorage.delete(key: 'rememberMe');
          await prefs.remove('token');
          await prefs.remove('username');
          return '/login';
        }
      } else {
        if (rememberMe != 'true') {
          print('🔒 [MAIN] 자동로그인이 비활성화됨, 로그인 화면으로 이동');
        } else {
          print('🔒 [MAIN] 저장된 토큰이 없음, 로그인 화면으로 이동');
        }
        return '/login';
      }
    } catch (e) {
      print('💥 [MAIN] 자동로그인 확인 중 오류 발생: $e');
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [MAIN] Widget build 시작');

    return MaterialApp(
      title: '스마트 환기 시스템',
      debugShowCheckedModeBanner: false,
      // 👇 기존 FutureBuilder 대신 바로 StartScreen으로
      home: StartScreen(checkAutoLogin: _checkAutoLogin),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
