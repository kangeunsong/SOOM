import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final ApiService api = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
    } catch (e) {
      print('Error loading rememberMe state: $e');
    }
  }

  void login() async {
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
      final token =
          await api.login(userController.text.trim(), passController.text);

      if (token != null && token.trim().isNotEmpty) {
        // 기존 저장된 데이터 초기화
        await storage.deleteAll();

        // 새로운 토큰과 자동로그인 설정 저장
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'rememberMe', value: rememberMe.toString());

        print('Login success - token saved, rememberMe: $rememberMe');

        // 홈 화면으로 이동
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          errorMessage = '로그인에 실패했습니다. 사용자 이름과 비밀번호를 확인하세요.';
        });
      }
    } catch (e) {
      print('Login error: $e');
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
      appBar: AppBar(title: const Text('날씨 & 미세먼지 앱 로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: userController,
              decoration: const InputDecoration(
                labelText: '사용자 이름',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Row(
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
                            key: 'rememberMe', value: rememberMe.toString());
                        print('RememberMe state changed to: $rememberMe');
                      } catch (e) {
                        print('Error saving rememberMe state: $e');
                      }
                    }
                  },
                ),
                const Text('자동로그인'),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('로그인', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('계정이 없으신가요? 회원가입'),
            ),
          ],
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
