import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_fastapi_auth/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';
import '../models/air_quality.dart';

class ApiService {
  static const String baseUrl = 'https://5912-113-198-180-200.ngrok-free.app';

  // static const String baseUrl = 'http://10.0.2.2:8000';
   String? lastErrorMessage;
  // Future<bool> signup(String username, String email, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/token'),
  //       headers: {
  //         'ngrok-skip-browser-warning': 'true',
  //         'Content-Type': 'application/x-www-form-urlencoded', // 필요시
  //       },
  //       body: jsonEncode({
  //         'username': username,
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     print('회원가입 응답: ${response.statusCode} - ${response.body}');

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       Map<String, dynamic> responseBody = {};
  //       try {
  //         responseBody = jsonDecode(response.body);
  //       } catch (e) {
  //         // JSON이 아닌 경우
  //       }

  //       lastErrorMessage = responseBody['detail'] ?? '회원가입 실패: 알 수 없는 오류';
  //       return false;
  //     }
  //   } catch (e) {
  //     print('회원가입 중 예외 발생: $e');
  //     lastErrorMessage = '네트워크 오류: $e';
  //     return false;
  //   }
  // }
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
        lastErrorMessage = responseBody['detail']?.toString() ?? '회원가입 실패: 알 수 없는 오류';
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
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'username=$username&password=$password',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('username', username);
        return true;
      } else {
        print('로그인 실패: ${response.statusCode} - ${response.body}');
        lastErrorMessage = '로그인 실패: 사용자 이름 또는 비밀번호가 잘못되었습니다';
        return false;
      }
    } catch (e) {
      print('로그인 중 예외 발생: $e');
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
}
