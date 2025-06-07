import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ApiService _apiService = ApiService();

  // 자동로그인 확인 함수
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

      // 자동로그인이 활성화되어 있고 토큰이 존재하는 경우
      if (rememberMe == 'true' && token != null && token.trim().isNotEmpty) {
        print('🔄 [MAIN] 토큰 유효성 검증 중...');

        // FlutterSecureStorage의 토큰을 SharedPreferences에 복사 (API 호출용)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        String? username = await secureStorage.read(key: 'username');
        if (username != null) {
          await prefs.setString('username', username);
        }

        // ApiService를 통해 토큰 유효성 검증
        final isValidToken = await _apiService.validateToken();

        if (isValidToken) {
          print('✅ [MAIN] 토큰 유효, 자동로그인 성공 - 홈 화면으로 이동');
          return '/home';
        } else {
          print('❌ [MAIN] 토큰 무효, 저장된 데이터 정리 후 로그인 화면으로 이동');
          // 무효한 토큰 정리
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
      // 오류 발생 시 안전하게 로그인 화면으로
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [MAIN] Widget build 시작');

    return FutureBuilder<String>(
      future: _checkAutoLogin(),
      builder: (context, snapshot) {
        // 로딩 중일 때 - 스플래시 스크린 형태
        if (snapshot.connectionState != ConnectionState.done) {
          print('⏳ [MAIN] 자동로그인 확인 중...');
          return MaterialApp(
            title: '스마트 환기 시스템',
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.blue.shade50,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.air,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '스마트 환기 시스템',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '로그인 상태 확인 중...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 에러가 발생한 경우
        if (snapshot.hasError) {
          print('💥 [MAIN] FutureBuilder 에러: ${snapshot.error}');
          return MaterialApp(
            title: '스마트 환기 시스템',
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('앱 초기화에 실패했습니다'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // 앱 재시작 로직 (실제로는 다른 방법 필요)
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 기본값으로 로그인 화면 설정
        final initialRoute = snapshot.data ?? '/login';
        print('🎯 [MAIN] 최종 결정된 초기 라우트: $initialRoute');

        // 자동로그인 결과에 따라 다른 화면 표시
        Widget homeWidget;
        if (initialRoute == '/home') {
          // 자동로그인 성공 시 HomeScreen 표시
          homeWidget = const HomeScreen();
        } else {
          // 로그인 화면
          homeWidget = LoginScreen();
        }

        return MaterialApp(
          title: '스마트 환기 시스템',
          debugShowCheckedModeBanner: false,
          home: homeWidget,
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
      },
    );
  }
}
