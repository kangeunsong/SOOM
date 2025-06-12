import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_fastapi_auth/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';
import '../models/air_quality.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://5912-113-198-180-200.ngrok-free.app';
  String? lastErrorMessage;

  Future<bool> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'), // /token → /signup으로 변경
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json', // JSON으로 변경
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('회원가입 응답: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        Map<String, dynamic> responseBody = {};
        try {
          responseBody = jsonDecode(response.body);
        } catch (e) {
          // JSON이 아닌 경우
        }

        // detail이 배열인 경우 처리
        if (responseBody['detail'] is List) {
          List<dynamic> errors = responseBody['detail'];
          lastErrorMessage = errors.map((e) => e['msg'] ?? '').join(', ');
        } else {
          lastErrorMessage =
              responseBody['detail']?.toString() ?? '회원가입 실패: 알 수 없는 오류';
        }
        return false;
      }
    } catch (e) {
      print('회원가입 중 예외 발생: $e');
      lastErrorMessage = '네트워크 오류: $e';
      return false;
    }
  }

  // 로그인 메서드
  // Future<bool> login(String username, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/token'),
  //       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //       body: 'username=$username&password=$password',
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', data['access_token']);
  //       await prefs.setString('username', username);
  //       return true;
  //     } else {
  //       print('로그인 실패: ${response.statusCode} - ${response.body}');
  //       lastErrorMessage = '로그인 실패: 사용자 이름 또는 비밀번호가 잘못되었습니다';
  //       return false;
  //     }
  //   } catch (e) {
  //     print('로그인 중 예외 발생: $e');
  //     lastErrorMessage = '네트워크 오류: $e';
  //     return false;
  //   }
  // }

// login 메서드를 FlutterSecureStorage 사용으로 변경
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'ngrok-skip-browser-warning': 'true',
        },
        body: 'username=$username&password=$password',
      );

      print('🌐 [API] 로그인 요청 - 응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];

        print('✅ [API] 로그인 성공, 토큰 저장 중...');
        print('🔍 [API] 받은 토큰 길이: ${accessToken?.length ?? 0}자');

        // ✨ FlutterSecureStorage 사용으로 변경
        const storage = FlutterSecureStorage();
        await storage.write(key: 'token', value: accessToken);
        await storage.write(key: 'username', value: username);

        // SharedPreferences에도 저장 (기존 API 호출들 호환성 위해)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', accessToken);
        await prefs.setString('username', username);

        print('💾 [API] FlutterSecureStorage와 SharedPreferences 모두 저장 완료');

        // 저장 확인 (디버깅용)
        String? savedSecureToken = await storage.read(key: 'token');
        String? savedSharedToken = prefs.getString('token');
        print(
            '🔍 [API] 저장 확인 - SecureStorage: ${savedSecureToken != null ? "성공(${savedSecureToken.length}자)" : "실패"}');
        print(
            '🔍 [API] 저장 확인 - SharedPreferences: ${savedSharedToken != null ? "성공(${savedSharedToken.length}자)" : "실패"}');

        return true;
      } else {
        print('❌ [API] 로그인 실패: ${response.statusCode} - ${response.body}');

        // 에러 메시지 파싱
        try {
          final errorData = jsonDecode(response.body);
          lastErrorMessage = errorData['detail']?.toString() ??
              '로그인 실패: 사용자 이름 또는 비밀번호가 잘못되었습니다';
        } catch (e) {
          lastErrorMessage = '로그인 실패: 사용자 이름 또는 비밀번호가 잘못되었습니다';
        }

        return false;
      }
    } catch (e) {
      print('💥 [API] 로그인 중 예외 발생: $e');
      lastErrorMessage = '네트워크 오류: $e';
      return false;
    }
  }

  // 로그아웃 메서드
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');
      return true;
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      return false;
    }
  }

  // 사용자 프로필 조회
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('프로필 조회 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('프로필 조회 중 예외 발생: $e');
      return null;
    }
  }

  // 특정 위치의 현재 날씨 조회
  Future<Weather> getCurrentWeather(String locationCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/weather/current/$locationCode'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('날씨 정보를 불러오는데 실패했습니다');
    }
  }

  // 특정 위치의 날씨 이력 조회
  Future<List<Weather>> getWeatherHistory(String locationCode,
      {int days = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/weather/history/$locationCode?days=$days'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Weather.fromJson(json)).toList();
    } else {
      throw Exception('날씨 이력을 불러오는데 실패했습니다');
    }
  }

  Future<AirQuality> getCurrentAirQuality(String locationCode) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/dust/current/$locationCode'));

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return AirQuality.fromJson(decoded);
    } else {
      throw Exception('Failed to load air quality data');
    }
  }

  Future<bool> triggerManualFetch() async {
    final url = Uri.parse('$baseUrl/fetch-now');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // 특정 위치의 미세먼지 이력 조회
  Future<List<AirQuality>> getAirQualityHistory(String locationCode,
      {int days = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dust/history/$locationCode?days=$days'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AirQuality.fromJson(json)).toList();
    } else {
      throw Exception('미세먼지 이력을 불러오는데 실패했습니다');
    }
  }

  // 저장된 토큰이 유효한지 검증
  // api_service.dart의 validateToken 메서드
  Future<bool> validateToken() async {
    print('🔍 [API] 토큰 유효성 검사 시작');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('❌ [API] SharedPreferences에 토큰이 없음');
        return false;
      }

      print('🌐 [API] 서버에 토큰 유효성 검사 요청 중...');
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      print('📡 [API] 서버 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [API] 토큰이 유효함');
        return true;
      } else {
        print('❌ [API] 토큰이 무효함 (응답 코드: ${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('💥 [API] 토큰 검증 중 오류: $e');
      return false;
    }
  }
}
