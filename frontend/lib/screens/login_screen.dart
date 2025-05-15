// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController userController = TextEditingController();
//   final TextEditingController passController = TextEditingController();
//   final ApiService api = ApiService();
//   bool isLoading = false;

//   void login() async {
//     setState(() => isLoading = true);
//     bool success = await api.login(userController.text, passController.text);
//     setState(() => isLoading = false);
//     if (success) Navigator.pushReplacementNamed(context, '/home');
//     else showDialog(context: context, builder: (_) => AlertDialog(title: Text('Login Failed')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: userController, decoration: InputDecoration(labelText: 'Username')),
//             TextField(controller: passController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: login, child: isLoading ? CircularProgressIndicator() : Text('Login')),
//             TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: Text('Sign up'))
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final ApiService api = ApiService();
  bool isLoading = false;
  String? errorMessage;

  void login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      bool success = await api.login(userController.text, passController.text);
      
      if (success) {
        // 로그인 성공시 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = '로그인에 실패했습니다. 사용자 이름과 비밀번호를 확인하세요.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '로그인 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
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
}