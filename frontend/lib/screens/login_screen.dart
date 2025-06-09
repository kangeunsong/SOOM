import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  bool rememberMe = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRememberMeState();
  }

  // 저장된 자동로그인 상태 불러오기
  void _loadRememberMeState() async {
    try {
      String? rememberMeValue = await storage.read(key: 'rememberMe');
      if (rememberMeValue != null) {
        setState(() {
          rememberMe = rememberMeValue == 'true';
        });
      }
      print('📱 [LOGIN] 자동로그인 상태 로드: $rememberMe');
    } catch (e) {
      print('💥 [LOGIN] 자동로그인 상태 로드 오류: $e');
    }
  }

  void login() async {
    print('🔐 [LOGIN] 로그인 시도 시작');

    // 입력값 검증
    if (userController.text.trim().isEmpty ||
        passController.text.trim().isEmpty) {
      setState(() {
        errorMessage = '사용자 이름과 비밀번호를 입력해 주세요.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 실제 API 로그인 시도
      final success = await _apiService.login(
        userController.text.trim(),
        passController.text.trim(),
      );

      if (success) {
        print('✅ [LOGIN] 실제 API 로그인 성공');

        // 자동로그인 설정 저장
        await storage.write(key: 'rememberMe', value: rememberMe.toString());
        await storage.write(key: 'username', value: userController.text.trim());

        print('💾 [LOGIN] 자동로그인 데이터 저장 완료 - rememberMe: $rememberMe');

        // HomeScreen으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        print('❌ [LOGIN] API 로그인 실패');
        setState(() {
          errorMessage = '로그인에 실패했습니다. 사용자명과 비밀번호를 확인해주세요.';
        });
      }
    } catch (e) {
      print('💥 [LOGIN] 로그인 오류: $e');
      setState(() {
        errorMessage = '로그인 중 오류가 발생했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스마트 환기 시스템'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 로고 및 타이틀
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.air,
                            size: 60,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '스마트 환기 시스템',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'IoT 센서 기반 자동 환기 관리',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 로그인 폼
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: userController,
                          decoration: InputDecoration(
                            labelText: '사용자 이름',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passController,
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),

                        // 자동로그인 체크박스
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    setState(() {
                                      rememberMe = value;
                                    });

                                    try {
                                      // 체크박스 상태 변경 시에만 rememberMe 값 저장
                                      await storage.write(
                                          key: 'rememberMe',
                                          value: rememberMe.toString());
                                      print(
                                          '🔄 [LOGIN] 자동로그인 설정 변경: $rememberMe');
                                    } catch (e) {
                                      print('💥 [LOGIN] 자동로그인 설정 저장 오류: $e');
                                    }
                                  }
                                },
                                activeColor: Colors.blue,
                              ),
                              const Text(
                                '자동로그인',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),

                        if (errorMessage != null &&
                            errorMessage!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (errorMessage?.startsWith('✅') ?? false)
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      (errorMessage?.startsWith('✅') ?? false)
                                          ? Colors.green.shade200
                                          : Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (errorMessage?.startsWith('✅') ?? false)
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color:
                                      (errorMessage?.startsWith('✅') ?? false)
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage ?? '',
                                    style: TextStyle(
                                        color: (errorMessage?.startsWith('✅') ??
                                                false)
                                            ? Colors.green.shade700
                                            : Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔍 디버깅 섹션 추가
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔍 디버깅 도구',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // 저장된 모든 데이터 확인
                            String? token = await storage.read(key: 'token');
                            String? remember =
                                await storage.read(key: 'rememberMe');
                            String? username =
                                await storage.read(key: 'username');

                            final prefs = await SharedPreferences.getInstance();
                            String? sharedToken = prefs.getString('token');
                            String? sharedUsername =
                                prefs.getString('username');

                            setState(() {
                              errorMessage = '🔍 디버깅 정보:\n'
                                  '📱 FlutterSecureStorage:\n'
                                  '  - 토큰: ${token != null ? "있음(${token.length}자)" : "없음"}\n'
                                  '  - 자동로그인: $remember\n'
                                  '  - 사용자명: $username\n\n'
                                  '🗂️ SharedPreferences:\n'
                                  '  - 토큰: ${sharedToken != null ? "있음(${sharedToken.length}자)" : "없음"}\n'
                                  '  - 사용자명: $sharedUsername';
                            });
                          },
                          child: Text('저장된 데이터 전체 확인'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // 모든 데이터 삭제
                            await storage.deleteAll();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            setState(() {
                              rememberMe = false;
                              errorMessage = '🗑️ 모든 저장된 데이터가 완전히 삭제되었습니다';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('모든 데이터 완전 삭제',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 추가 정보
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security,
                                color: Colors.grey.shade600, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '안전한 자동로그인',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '로그인 정보는 안전하게 암호화되어 저장됩니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }
}
