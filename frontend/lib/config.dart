import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';
  
  static const Map<String, String> locationMap = {
   '60,127': '서울',

    '61,125': '경기북부',

    '62,126': '경기남부',


    // 강원권

    '92,131': '속초',
    '73,127': '춘천',

    // 충청권
    '63,89': '대전',
    '68,87': '세종',

    '69,106': '충남_아산',
    '67,100': '충남_논산',

    '76,88': '충북',

    // 경상권
    '89,90': '대구',
    '98,76': '부산',

    '91,106': '경북',
    '80,70': '경남',


    // 전라권

    '58,64': '전북',
    '63,56': '전남',

    // 제주

    // 더 많은 위치 추가
  };
  
  static Future<String> getDefaultLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('default_location') ?? '60,127'; // 기본값은 서울
  }
  
  static Future<void> setDefaultLocation(String locationCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_location', locationCode);
  }
}