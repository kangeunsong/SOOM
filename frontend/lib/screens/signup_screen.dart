// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController userController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passController = TextEditingController();
//   final ApiService api = ApiService();
//   bool isLoading = false;

//   void signup() async {
//     setState(() => isLoading = true);
//     bool success = await api.signup(userController.text, emailController.text, passController.text);
//     setState(() => isLoading = false);
//     if (success) Navigator.pop(context);
//     else showDialog(context: context, builder: (_) => AlertDialog(title: Text('Signup Failed')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Sign up')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: userController, decoration: InputDecoration(labelText: 'Username')),
//             TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
//             TextField(controller: passController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: signup, child: isLoading ? CircularProgressIndicator() : Text('Sign up')),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final ApiService api = ApiService();
  bool isLoading = false;
  String? errorMessage;

  void signup() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      bool success = await api.signup(
        userController.text,
        emailController.text,
        passController.text,
      );
      
      if (success) {
        // 회원가입 성공시 로그인 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공! 로그인해 주세요.')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = '회원가입에 실패했습니다. 다른 사용자 이름을 시도해 보세요.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '회원가입 중 오류가 발생했습니다: $e';
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
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.person_add,
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
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
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
              onPressed: isLoading ? null : signup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('회원가입', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('이미 계정이 있으신가요? 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}