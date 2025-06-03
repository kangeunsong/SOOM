import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://5912-113-198-180-200.ngrok-free.app';

  static const Map<String, String> locationMap = {
    '60,127': '서울',
    '61,125': '경기북부',
    '62,126': '경기남부',

    // 강원권
    '92,131': '강원영동',
    '73,127': '강원영서',

    // 충청권
    '63,89': '대전',
    '68,87': '세종',
    '69,106': '충남_아산',
    '67,100': '충남_논산',
    '76,88': '충북', // 청주

    // 경상권
    '89,90': '대구',
    '98,76': '부산',
    '91,106': '경북',
    '80,70': '경남',

    // 전라권
    '58,64': '전북',
    '63,56': '전남',

    // 제주
    // 필요한 경우 더 많은 위치 추가
  };

  static Future<String> getDefaultLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('default_location') ?? '60,127'; // 기본값: 서울
  }

  static Future<void> setDefaultLocation(String locationCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_location', locationCode);
  }

  /// 현재 GPS 위치 기반으로 가장 가까운 행정 구역 코드 반환
  static Future<String> getNearestLocationCode() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('[위치] 서비스 비활성화, 기본값 사용');
      return '60,127';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('[위치] 권한 거부, 기본값 사용');
        return '60,127';
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 각 지역의 중심 좌표 (예시)
    Map<String, List<double>> gridLatLngMap = {
      '60,127': [37.5665, 126.9780], // 서울
      '61,125': [37.7500, 127.0], // 경기북부
      '62,126': [37.2500, 127.0], // 경기남부
      '63,89': [36.3500, 127.3845], // 대전
      '68,87': [36.4800, 127.2890], // 세종
      '92,131': [37.8000, 128.9], // 강원영동
      '73,127': [37.3000, 128.0], // 강원영서
      '76,88': [36.6424, 127.4890], // 충북 (청주)
      // 필요한 지역 추가
    };

    double minDistance = double.infinity;
    String closestCode = '60,127'; // 디폴트

    for (var entry in gridLatLngMap.entries) {
      final lat = entry.value[0];
      final lon = entry.value[1];

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lon,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestCode = entry.key;
      }
    }

    print('[위치] 현재 위치: ${position.latitude}, ${position.longitude}');
    print('[위치] 가장 가까운 지역 코드: $closestCode');

    return closestCode;
  }
}
