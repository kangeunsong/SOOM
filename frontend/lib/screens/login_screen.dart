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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/png/login_screen.png'),
            fit: BoxFit.cover,
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
                  // 로그인 폼 - 상단 여백 추가
                  const SizedBox(height: 100),

                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 사용자 이름 입력칸 - 크기 증가 및 테두리 색상 연하게
                        Container(
                          height: 80,
                          child: TextField(
                            controller: userController,
                            decoration: InputDecoration(
                              labelText: '사용자 이름',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4DD0E1),
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 비밀번호 입력칸 - 크기 증가 및 테두리 색상 연하게
                        Container(
                          height: 80,
                          child: TextField(
                            controller: passController,
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4DD0E1),
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            obscureText: true,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        // 자동로그인 체크박스 - 비밀번호 칸 왼쪽 밑에 작은 크기로
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: Checkbox(
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
                                activeColor: const Color(0xFF00BCD4),
                              ),
                            ),
                            const Text(
                              '자동로그인',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        // 에러 메시지
                        if (errorMessage != null &&
                            errorMessage!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (errorMessage?.startsWith('✅') ?? false)
                                  ? const Color(0xFFC1F2B2).withOpacity(0.3)
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      (errorMessage?.startsWith('✅') ?? false)
                                          ? const Color(0xFFC1F2B2)
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

                        // 로그인 버튼 - 00BCD4 색상으로
                        ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            disabledBackgroundColor:
                                const Color(0xFF00BCD4).withOpacity(0.6),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
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
