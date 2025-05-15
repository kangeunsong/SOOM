// import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/home_screen.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter FastAPI Auth',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => LoginScreen(),
//         '/signup': (context) => SignupScreen(),
//         '/home': (context) => HomeScreen(),
//       },
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:flutter_fastapi_auth/screens/home_screen.dart';

// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await dotenv.load(fileName: ".env");
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: '날씨 & 미세먼지 앱',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //         brightness: Brightness.light,
// //         useMaterial3: true,
// //         appBarTheme: const AppBarTheme(
// //           centerTitle: true,
// //           elevation: 0,
// //         ),
// //         cardTheme: CardTheme(
// //           elevation: 4,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //         ),
// //       ),
// //       darkTheme: ThemeData(
// //         brightness: Brightness.dark,
// //         useMaterial3: true,
// //         appBarTheme: const AppBarTheme(
// //           centerTitle: true,
// //           elevation: 0,
// //         ),
// //         cardTheme: CardTheme(
// //           elevation: 4,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //         ),
// //       ),
// //       themeMode: ThemeMode.system,
// //       debugShowCheckedModeBanner: false,
// //       home: const HomeScreen(),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'screens/login_screen.dart';
// // import 'screens/signup_screen.dart';
// // import 'screens/home_screen.dart';

// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await dotenv.load(fileName: ".env");
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatefulWidget {
// //   const MyApp({Key? key}) : super(key: key);

// //   @override
// //   _MyAppState createState() => _MyAppState();
// // }

// // class _MyAppState extends State<MyApp> {
// //   bool _isLoggedIn = false;
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkLoginStatus();
// //   }

// //   Future<void> _checkLoginStatus() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       _isLoggedIn = prefs.getString('token') != null;
// //       _isLoading = false;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: '날씨 & 미세먼지 앱',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //         brightness: Brightness.light,
// //         useMaterial3: true,
// //         appBarTheme: const AppBarTheme(
// //           centerTitle: true,
// //           elevation: 0,
// //         ),
// //         cardTheme: CardTheme(
// //           elevation: 4,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //         ),
// //       ),
// //       darkTheme: ThemeData(
// //         brightness: Brightness.dark,
// //         useMaterial3: true,
// //         appBarTheme: const AppBarTheme(
// //           centerTitle: true,
// //           elevation: 0,
// //         ),
// //         cardTheme: CardTheme(
// //           elevation: 4,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //         ),
// //       ),
// //       themeMode: ThemeMode.system,
// //       debugShowCheckedModeBanner: false,
// //       home: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _isLoggedIn
// //               ? HomeScreen()
// //               : LoginScreen(),
// //       routes: {
// //         '/login': (context) => LoginScreen(),
// //         '/signup': (context) => SignupScreen(),
// //         '/home': (context) => const HomeScreen(),
// //       },
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '날씨 & 미세먼지 앱',
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// // import 'package:flutter/material.dart';
// // import 'screens/login_screen.dart';
// // import 'screens/signup_screen.dart';
// // import 'screens/home_screen.dart';

// // void main() => runApp(MyApp());

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter FastAPI Auth',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       initialRoute: '/login',
// //       routes: {
// //         '/login': (context) => LoginScreen(),
// //         '/signup': (context) => SignupScreen(),
// //         '/home': (context) => HomeScreen(),
// //       },
// //     );
// //   }
// // }

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // // import 'package:flutter_fastapi_auth/screens/home_screen.dart';

// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await dotenv.load(fileName: ".env");
// // //   runApp(const MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   const MyApp({Key? key}) : super(key: key);

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: '날씨 & 미세먼지 앱',
// // //       theme: ThemeData(
// // //         primarySwatch: Colors.blue,
// // //         brightness: Brightness.light,
// // //         useMaterial3: true,
// // //         appBarTheme: const AppBarTheme(
// // //           centerTitle: true,
// // //           elevation: 0,
// // //         ),
// // //         cardTheme: CardTheme(
// // //           elevation: 4,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(16),
// // //           ),
// // //         ),
// // //       ),
// // //       darkTheme: ThemeData(
// // //         brightness: Brightness.dark,
// // //         useMaterial3: true,
// // //         appBarTheme: const AppBarTheme(
// // //           centerTitle: true,
// // //           elevation: 0,
// // //         ),
// // //         cardTheme: CardTheme(
// // //           elevation: 4,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(16),
// // //           ),
// // //         ),
// // //       ),
// // //       themeMode: ThemeMode.system,
// // //       debugShowCheckedModeBanner: false,
// // //       home: const HomeScreen(),
// // //     );
// // //   }
// // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'screens/login_screen.dart';
// // // import 'screens/signup_screen.dart';
// // // import 'screens/home_screen.dart';

// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await dotenv.load(fileName: ".env");
// // //   runApp(const MyApp());
// // // }

// // // class MyApp extends StatefulWidget {
// // //   const MyApp({Key? key}) : super(key: key);

// // //   @override
// // //   _MyAppState createState() => _MyAppState();
// // // }

// // // class _MyAppState extends State<MyApp> {
// // //   bool _isLoggedIn = false;
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _checkLoginStatus();
// // //   }

// // //   Future<void> _checkLoginStatus() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     setState(() {
// // //       _isLoggedIn = prefs.getString('token') != null;
// // //       _isLoading = false;
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: '날씨 & 미세먼지 앱',
// // //       theme: ThemeData(
// // //         primarySwatch: Colors.blue,
// // //         brightness: Brightness.light,
// // //         useMaterial3: true,
// // //         appBarTheme: const AppBarTheme(
// // //           centerTitle: true,
// // //           elevation: 0,
// // //         ),
// // //         cardTheme: CardTheme(
// // //           elevation: 4,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(16),
// // //           ),
// // //         ),
// // //       ),
// // //       darkTheme: ThemeData(
// // //         brightness: Brightness.dark,
// // //         useMaterial3: true,
// // //         appBarTheme: const AppBarTheme(
// // //           centerTitle: true,
// // //           elevation: 0,
// // //         ),
// // //         cardTheme: CardTheme(
// // //           elevation: 4,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(16),
// // //           ),
// // //         ),
// // //       ),
// // //       themeMode: ThemeMode.system,
// // //       debugShowCheckedModeBanner: false,
// // //       home: _isLoading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : _isLoggedIn
// // //               ? HomeScreen()
// // //               : LoginScreen(),
// // //       routes: {
// // //         '/login': (context) => LoginScreen(),
// // //         '/signup': (context) => SignupScreen(),
// // //         '/home': (context) => const HomeScreen(),
// // //       },
// // //     );
// // //   }
// // // }

// import 'package:flutter/material.dart';
// import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/home_screen.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '날씨 & 미세먼지 앱',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           centerTitle: true,
//           elevation: 0,
//         ),
//         cardTheme: CardTheme(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => LoginScreen(),
//         '/signup': (context) => SignupScreen(),
//         '/home': (context) => HomeScreen(),
//       },
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart';
// import 'screens/home_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(); // ✅ 이 줄이 꼭 있어야 함
//   runApp(MyApp());
// }


// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '날씨 & 미세먼지 앱',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => LoginScreen(),
//         '/signup': (context) => SignupScreen(),
//         '/home': (context) => HomeScreen(),
//       },
//     );
//   }
// }