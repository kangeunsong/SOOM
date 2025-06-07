import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';  // 임시로 주석처리
// import 'screens/home_screen.dart';    // 임시로 주석처리
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // 초기 라우트를 결정하는 비동기 함수
  Future<String> _getInitialRoute() async {
    print('🚀 [MAIN] 앱 초기화 시작');

    try {
      // 여기서 새로운 인스턴스 생성
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final ApiService apiService = ApiService();

      print('📱 [MAIN] SecureStorage에서 데이터 읽는 중...');
      String? token = await secureStorage.read(key: 'token');
      String? rememberMe = await secureStorage.read(key: 'rememberMe');

      print(
          '🔑 [MAIN] 저장된 토큰: ${token != null ? '${token.substring(0, 10)}...' : 'null'}');
      print('✅ [MAIN] 자동로그인 설정: $rememberMe');

      // rememberMe가 'true'이고 token이 존재하고 비어있지 않은 경우
      if (rememberMe == 'true' && token != null && token.trim().isNotEmpty) {
        print('🔍 [MAIN] 자동로그인 조건 만족, 토큰 유효성 검사 중...');

        // 🔥 중요: 토큰이 실제로 유효한지 검증
        bool isTokenValid = await apiService.validateToken();

        if (isTokenValid) {
          print('✅ [MAIN] 토큰 유효함! 홈 화면으로 이동');
          return '/home'; // 토큰이 유효하면 자동 로그인
        } else {
          print('❌ [MAIN] 토큰이 무효함, 저장된 데이터 삭제 중...');
          // 토큰이 무효하면 저장된 데이터 삭제
          await secureStorage.deleteAll();
          print('🗑️ [MAIN] 저장된 데이터 삭제 완료, 로그인 화면으로 이동');
          return '/login'; // 로그인 화면으로
        }
      } else {
        if (rememberMe != 'true') {
          print('🔒 [MAIN] 자동로그인이 설정되지 않음, 로그인 화면으로 이동');
        } else {
          print('🔒 [MAIN] 저장된 토큰이 없음, 로그인 화면으로 이동');
        }
        return '/login'; // 수동 로그인
      }
    } catch (e) {
      print('💥 [MAIN] 오류 발생: $e');
      // 오류 발생 시 기본적으로 로그인 화면으로
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [MAIN] Widget build 시작');

    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        // 로딩 중일 때
        if (snapshot.connectionState != ConnectionState.done) {
          print('⏳ [MAIN] 초기화 로딩 중...');
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 에러가 발생한 경우
        if (snapshot.hasError) {
          print('💥 [MAIN] FutureBuilder 에러: ${snapshot.error}');
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('초기화 실패')),
            ),
          );
        }

        // 기본값으로 로그인 화면 설정
        final initialRoute = snapshot.data ?? '/login';
        print('🎯 [MAIN] 최종 결정된 초기 라우트: $initialRoute');

        return MaterialApp(
          title: '날씨 & 미세먼지 앱',
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            '/login': (context) {
              try {
                print('🎯 [MAIN] LoginScreen 생성 중...');
                return LoginScreen();
              } catch (e) {
                print('💥 [MAIN] LoginScreen 생성 오류: $e');
                return Scaffold(
                  body: Center(
                    child: Text('로그인 화면 로드 실패: $e'),
                  ),
                );
              }
            },
            '/signup': (context) {
              return Scaffold(
                appBar: AppBar(title: Text('회원가입')),
                body: Center(
                  child: Text('회원가입 화면 (임시)'),
                ),
              );
            },
            '/home': (context) {
              return Scaffold(
                appBar: AppBar(title: Text('홈')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('홈 화면 (임시)'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('로그아웃'),
                      ),
                    ],
                  ),
                ),
              );
            },
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
