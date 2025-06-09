import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/models/weather.dart';
import 'package:flutter_fastapi_auth/models/air_quality.dart';
import 'package:flutter_fastapi_auth/screens/air_quality_detail_screen.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
import 'package:flutter_fastapi_auth/config.dart';
import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // MyApp을 위해

import '../services/wakeword_service.dart';
import './soomi_screen.dart';

final WakewordService _wakewordService = WakewordService();

// 센서 데이터 모델
class SensorData {
  final String deviceId;
  final int? pir;
  final int? light;
  final int? gas;
  final DateTime timestamp;

  SensorData({
    required this.deviceId,
    this.pir,
    this.light,
    this.gas,
    required this.timestamp,
  });

  // 안전한 정수 변환 헬퍼 함수
  static int? _safeToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt();
    }
    return null;
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['device_id']?.toString() ?? '',
      pir: _safeToInt(json['pir']),
      light: _safeToInt(json['light']),
      gas: _safeToInt(json['gas']),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// 센서 상태 분석 결과
class SensorAnalysis {
  final bool shouldOpenWindow;
  final String reason;
  final String urgency; // "high", "medium", "low"
  final Color color;

  SensorAnalysis({
    required this.shouldOpenWindow,
    required this.reason,
    required this.urgency,
    required this.color,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<String> _defaultLocationFuture;
  late String _currentLocation;
  String? _username;
  Weather? _currentWeather;
  AirQuality? _currentAirQuality;
  bool _isLoading = true;
  String? _error;
  bool _isVentilationRecommended = false;
  String _ventilationMessage = "";

  // HomeScreen State 클래스 내에 선언

  bool _realPopupShown = false; // 실제 데이터 팝업 표시 여부

  // 센서 관련 변수들
  SensorData? _lastSensorData;
  SensorData? _previousSensorData;
  Timer? _sensorCheckTimer;
  bool _isMonitoringActive = true;
  List<SensorData> _sensorHistory = [];
  bool _autoControlEnabled = true; // 자동 제어 활성화 여부
  bool _windowCurrentlyOpen = false; // 현재 창문 상태
  DateTime? _lastAutoAction; // 마지막 자동 동작 시간
  static const Duration AUTO_ACTION_COOLDOWN =
      Duration(minutes: 10); // 자동 동작 간격

  // 센서 임계값 설정 (더 세밀하게 조정)
  static const int LIGHT_THRESHOLD_DARK = 150; // 어두워지는 기준 (낮아짐)
  // static const int LIGHT_THRESHOLD_BRIGHT = 400; // 밝아지는 기준 (높아짐)
  // static const int LIGHT_CHANGE_THRESHOLD = 100; // 급격한 조도 변화 기준
  static const int LIGHT_DIGITAL_DARK = 0; // 어두움
  static const int LIGHT_DIGITAL_BRIGHT = 1; // 밝음
  static const int GAS_THRESHOLD_HIGH = 300; // 가스 농도 높음 기준 (낮춤)
  static const int GAS_THRESHOLD_NORMAL = 100; // 가스 농도 정상 기준
  static const int GAS_CHANGE_THRESHOLD = 50; // 급격한 가스 변화 기준

  // 웨이크워드 감지 관련 변수들
  PorcupineManager? _porcupineManager;
  bool _isListening = false;

// 움직임 감지 시 즉시 창문 닫기 여부 판단
  bool _shouldCloseWindowOnMovement(SensorData current) {
    final hour = DateTime.now().hour;

    // 1. 야간 시간대 (22시~6시)
    bool isNightTime = hour >= 22 || hour <= 6;

    // 2. 외부 공기질이 매우 나쁨
    bool veryBadAirQuality = _currentAirQuality != null &&
        (_currentAirQuality!.pm10 > 100 || _currentAirQuality!.pm25 > 50);

    // 3. 극한 날씨 (매우 춥거나 더움)
    bool extremeWeather = _currentWeather != null &&
        (_currentWeather!.temperature < 0 || _currentWeather!.temperature > 35);

    // 4. 비나 눈이 오는 중
    bool badWeather = _currentWeather != null &&
        (_currentWeather!.precipitation > 1.0 ||
            (_currentWeather!.skyCondition?.contains('비') == true) ||
            (_currentWeather!.skyCondition?.contains('눈') == true));

    // 5. 실내 가스 농도는 정상이지만 외부 조건이 나쁠 때
    bool indoorAirOk =
        current.gas == null || current.gas! < GAS_THRESHOLD_NORMAL;

    print("🔍 움직임 닫기 조건 체크:");
    print("  - 야간: $isNightTime");
    print("  - 나쁜 공기질: $veryBadAirQuality");
    print("  - 극한 날씨: $extremeWeather");
    print("  - 나쁜 날씨: $badWeather");
    print("  - 실내 공기 양호: $indoorAirOk");

    return (isNightTime || veryBadAirQuality || extremeWeather || badWeather) &&
        indoorAirOk;
  }

// 움직임 감지 시 창문 닫기 이유 설명
  String _getMovementCloseReason() {
    final hour = DateTime.now().hour;
    List<String> reasons = [];

    // 야간 시간대
    if (hour >= 22 || hour <= 6) {
      reasons.add("야간 시간대입니다");
    }

    // 외부 공기질
    if (_currentAirQuality != null) {
      if (_currentAirQuality!.pm10 > 100 || _currentAirQuality!.pm25 > 50) {
        reasons.add("외부 미세먼지가 매우 나쁩니다");
      }
    }

    // 날씨 조건
    if (_currentWeather != null) {
      if (_currentWeather!.temperature < 0) {
        reasons.add("매우 추운 날씨입니다");
      } else if (_currentWeather!.temperature > 35) {
        reasons.add("매우 더운 날씨입니다");
      }

      if (_currentWeather!.precipitation > 1.0) {
        reasons.add("비/눈이 오고 있습니다");
      }
    }

    if (reasons.isEmpty) {
      return "에너지 절약을 위해";
    }

    return reasons.join(", ");
  }

// 개선된 사용자 활동 감지 시 조정 필요 여부
  bool _shouldAdjustForOccupancy(SensorData current) {
    // 실내 공기질이 경계선에 있거나, 외부 환경이 변화했을 때
    bool airQualityBorderline = current.gas != null &&
        current.gas! > GAS_THRESHOLD_NORMAL &&
        current.gas! < GAS_THRESHOLD_HIGH;

    bool timeForAdjustment = _lastAutoAction == null ||
        DateTime.now().difference(_lastAutoAction!) >
            const Duration(minutes: 30);

    // 움직임이 감지되면 더 적극적으로 조정 고려
    bool movementDetected = current.pir == 1;

    print("🔍 조정 필요 여부 체크:");
    print("  - 공기질 경계선: $airQualityBorderline");
    print("  - 시간 경과: $timeForAdjustment");
    print("  - 움직임 감지: $movementDetected");

    return airQualityBorderline || timeForAdjustment || movementDetected;
  }

// 사용자 활동 시 최적 동작 계산 (움직임 감지에 최적화)
  bool _calculateOptimalActionForOccupancy(SensorData current) {
    // 복합적 판단
    double score = 0.0;
    final hour = DateTime.now().hour;

    print("🧮 점수 계산 시작:");

    // 시간대별 가중치 (움직임 감지 시 더 보수적으로)
    if (hour >= 22 || hour <= 6) {
      score -= 2.0; // 야간에는 강하게 닫기 권장
      print("  - 야간 시간: -2.0");
    } else if (hour >= 6 && hour <= 9) {
      score += 1.0; // 아침에는 환기 권장
      print("  - 아침 시간: +1.0");
    } else if (hour >= 18 && hour <= 22) {
      score -= 0.5; // 저녁에는 약간 닫기 권장
      print("  - 저녁 시간: -0.5");
    }

    // 실내 공기질 점수 (가스 농도)
    if (current.gas != null) {
      if (current.gas! < GAS_THRESHOLD_NORMAL) {
        score += 0.5; // 좋음
        print("  - 실내 공기질 좋음: +0.5");
      } else if (current.gas! < GAS_THRESHOLD_HIGH) {
        score += 0.0; // 보통
        print("  - 실내 공기질 보통: +0.0");
      } else {
        score += 2.0; // 나쁘면 강하게 열기 권장
        print("  - 실내 공기질 나쁨: +2.0");
      }
    }

    // 외부 공기질 점수 (더 엄격하게)
    if (_currentAirQuality != null) {
      if (_currentAirQuality!.pm10 < 20) {
        score += 1.0; // 매우 좋음
        print("  - 외부 공기질 매우 좋음: +1.0");
      } else if (_currentAirQuality!.pm10 < 50) {
        score += 0.3; // 좋음
        print("  - 외부 공기질 좋음: +0.3");
      } else if (_currentAirQuality!.pm10 < 100) {
        score -= 0.5; // 보통
        print("  - 외부 공기질 보통: -0.5");
      } else {
        score -= 2.0; // 나쁨
        print("  - 외부 공기질 나쁨: -2.0");
      }
    }

    // 날씨 점수 (보수적으로)
    if (_currentWeather != null) {
      if (_currentWeather!.precipitation > 0.5) {
        score -= 1.5; // 비/눈
        print("  - 비/눈: -1.5");
      }

      if (_currentWeather!.temperature < 5 ||
          _currentWeather!.temperature > 30) {
        score -= 1.0; // 극한 온도
        print("  - 극한 온도: -1.0");
      } else if (_currentWeather!.temperature >= 18 &&
          _currentWeather!.temperature <= 25) {
        score += 0.5; // 적정 온도
        print("  - 적정 온도: +0.5");
      }
    }

    // 창문이 이미 열려있다면 닫기에 약간 가산점 (에너지 절약)
    if (_windowCurrentlyOpen) {
      score -= 0.3;
      print("  - 창문 이미 열림: -0.3");
    }

    print("📊 최종 점수: $score");
    print("🔽 결정: ${score > 0.5 ? '창문 열기' : '창문 닫기'}");

    return score > 0.5; // 더 높은 임계값으로 신중하게 판단
  }

  @override
  void initState() {
    super.initState();

    // 1️⃣ SharedPreferences에서 기존 위치 불러오기 (기본값: 서울)
    AppConfig.getDefaultLocation().then((location) {
      setState(() {
        _currentLocation = location;
      });
      _loadWeatherData(); // 초기 날씨 로딩
    });

    // 2️⃣ 실제 GPS 위치 받아서 가장 가까운 지역으로 자동 설정
    _autoSetNearestLocation();

    _loadUsername();
    _startSensorMonitoring();

    _wakewordService.initWakeWord((index) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SoomiScreen()),
      );
    });
  }

  // void _showWakeWordPopup() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('웨이크워드 감지!'),
  //       content: const Text('안녕하세요!'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('확인'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// 위치 기반으로 가장 가까운 지역 자동 설정
  void _autoSetNearestLocation() async {
    try {
      final locationCode = await AppConfig.getNearestLocationCode();
      await AppConfig.setDefaultLocation(locationCode);

      setState(() {
        _currentLocation = locationCode;
      });

      _loadWeatherData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치 기반으로 지역을 자동 설정했습니다')),
      );
    } catch (e) {
      print('[위치 업데이트 에러] $e');
    }
  }

  @override
  void dispose() {
    _sensorCheckTimer?.cancel();
    _wakewordService.stop();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final profile = await _apiService.getProfile();
    if (profile != null) {
      setState(() {
        _username = profile['username'];
      });
    }
  }

  void _changeLocation(String locationCode) {
    setState(() {
      _currentLocation = locationCode;
    });
    AppConfig.setDefaultLocation(locationCode);
    _loadWeatherData();
  }

  void _logout() async {
    print('🚪 [HOME] 로그아웃 시작');

    try {
      // 1️⃣ API 서버 로그아웃
      final success = await _apiService.logout();
      if (success) {
        print('✅ [HOME] 서버 로그아웃 성공');
      } else {
        print('⚠️ [HOME] 서버 로그아웃 실패 (계속 진행)');
      }

      // 2️⃣ 로컬 저장소 완전 삭제
      const storage = FlutterSecureStorage();
      await storage.deleteAll(); // 모든 FlutterSecureStorage 데이터 삭제

      // SharedPreferences도 삭제 (API 호출용 토큰)
      final prefs = await SharedPreferences.getInstance();
      await prefs
          .clear(); // 또는 개별 삭제: prefs.remove('token'), prefs.remove('username')

      print('🗑️ [HOME] 모든 저장된 데이터 삭제 완료');

      // 3️⃣ 로그인 화면으로 이동 (앱 재시작과 같은 효과)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false, // 모든 이전 화면 제거
        );
      }
    } catch (e) {
      print('💥 [HOME] 로그아웃 중 오류: $e');

      // 오류가 있어도 강제 로그아웃
      const storage = FlutterSecureStorage();
      await storage.deleteAll();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
      }
    }
  }

  // 센서 모니터링 시작
  void _startSensorMonitoring() {
    _sensorCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isMonitoringActive) {
        _checkSensorData();
      }
    });
  }

// 센서 데이터 확인 및 팝업 트리거
  Future<void> _checkSensorData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://5912-113-198-180-200.ngrok-free.app/iot/data/latest'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newSensorData = SensorData.fromJson(data);

        setState(() {
          _previousSensorData = _lastSensorData;
          _lastSensorData = newSensorData;
          _sensorHistory.insert(0, newSensorData);
          if (_sensorHistory.length > 20) {
            _sensorHistory = _sensorHistory.take(20).toList();
          }
        });

        if (_previousSensorData != null) {
          final analysis =
              _analyzeSensorChanges(_previousSensorData!, newSensorData);
          // 팝업이 필요하고 아직 띄우지 않았다면
          if (analysis != null && !_realPopupShown) {
            _realPopupShown = true;
            _showSmartVentilationPopup(analysis);
          }
          // 분석 결과가 없으면(정상 상태), 다음 이벤트를 위해 플래그 초기화
          if (analysis == null && _realPopupShown) {
            _realPopupShown = false;
          }
        }
      } else {
        print('센서 데이터 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('센서 데이터 확인 오류: $e');
    }
  }

  SensorAnalysis? _analyzeSensorChanges(SensorData old, SensorData current) {
    // 1. 급격한 가스 농도 증가 (최우선 - 즉시 창문 열기)
    if (old.gas != null && current.gas != null) {
      int gasChange = current.gas! - old.gas!;

      // 위험 수준의 가스 농도 증가
      if (gasChange > GAS_CHANGE_THRESHOLD &&
          current.gas! > GAS_THRESHOLD_HIGH) {
        if (_autoControlEnabled && _shouldPerformAutoAction()) {
          // 비동기 함수는 별도로 호출
          Future.microtask(() => _performAutoWindowControl(true, "가스 농도 급증"));
        }
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason:
              "🚨 실내 공기질이 급격히 악화되었습니다!\n가스 농도: ${old.gas} → ${current.gas}\n즉시 환기가 필요합니다.",
          urgency: "high",
          color: Colors.red,
        );
      }

      // 가스 농도가 높은 상태에서 움직임 감지
      if ((current.pir ?? 0) == 1 && current.gas! > GAS_THRESHOLD_HIGH) {
        if (_autoControlEnabled && _shouldPerformAutoAction()) {
          Future.microtask(
              () => _performAutoWindowControl(true, "움직임 감지 + 공기질 나쁨"));
        }
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason:
              "👤 움직임이 감지되었고 실내 공기질이 나쁩니다.\n가스 농도: ${current.gas}\n환기를 권장합니다.",
          urgency: "high",
          color: Colors.orange,
        );
      }

      // 가스 농도가 정상으로 돌아왔을 때 (외부 공기질 확인 후 닫기)
      if (old.gas! > GAS_THRESHOLD_HIGH &&
          current.gas! < GAS_THRESHOLD_NORMAL) {
        if (_shouldCloseWindowAfterImprovement()) {
          if (_autoControlEnabled && _shouldPerformAutoAction()) {
            Future.microtask(
                () => _performAutoWindowControl(false, "실내 공기질 개선"));
          }
          return SensorAnalysis(
            shouldOpenWindow: false,
            reason: "✅ 실내 공기질이 개선되었지만\n외부 미세먼지를 고려하여 창문을 닫는 것을 권장합니다.",
            urgency: "medium",
            color: Colors.amber,
          );
        }
      }
    }

    // 기존 조도 변화 분석 부분을 다음과 같이 교체:
    if (old.light != null && current.light != null) {
      // 어두워짐 감지 (1 → 0)
      if (old.light == LIGHT_DIGITAL_BRIGHT &&
          current.light == LIGHT_DIGITAL_DARK) {
        if (_shouldCloseWindowAtNight()) {
          if (_autoControlEnabled && _shouldPerformAutoAction()) {
            Future.microtask(() => _performAutoWindowControl(false, "야간 시간대"));
          }
          return SensorAnalysis(
            shouldOpenWindow: false,
            reason: "🌙 어두워졌습니다.\n${_getCloseWindowReason()}\n창문을 닫는 것을 권장합니다.",
            urgency: "medium",
            color: Colors.blue,
          );
        }
      }

      // 밝아짐 감지 (0 → 1)
      else if (old.light == LIGHT_DIGITAL_DARK &&
          current.light == LIGHT_DIGITAL_BRIGHT) {
        if (_shouldOpenWindowInMorning(current)) {
          if (_autoControlEnabled && _shouldPerformAutoAction()) {
            Future.microtask(() => _performAutoWindowControl(true, "아침 환기"));
          }
          return SensorAnalysis(
            shouldOpenWindow: true,
            reason:
                "☀️ 밝아졌습니다!\n실내 공기질이 양호하고 환기하기 좋은 시간입니다.\n신선한 공기를 위해 창문을 여는 것을 권장합니다.",
            urgency: "low",
            color: Colors.green,
          );
        }
      }
    }

// 3. 움직임 감지 시 적응형 제어 (완전히 개선된 버전)
    if (old.pir != current.pir && current.pir == 1) {
      print("👤 움직임 감지됨 - 분석 시작");

      // 움직임 감지 시 즉시 창문 닫기가 필요한 상황들
      if (_shouldCloseWindowOnMovement(current)) {
        print("🔒 즉시 창문 닫기 조건 만족");
        if (_autoControlEnabled && _shouldPerformAutoAction()) {
          Future.microtask(
              () => _performAutoWindowControl(false, "움직임 감지 - 즉시 닫기"));
        }
        return SensorAnalysis(
          shouldOpenWindow: false,
          reason:
              "👤 움직임이 감지되었습니다.\n${_getMovementCloseReason()}\n창문을 닫는 것을 권장합니다.",
          urgency: "high",
          color: Colors.orange,
        );
      }

      // 일반적인 움직임 감지 시 환경 체크
      else if (_shouldAdjustForOccupancy(current)) {
        print("⚖️ 환경 기반 판단 시작");
        bool shouldOpen = _calculateOptimalActionForOccupancy(current);
        if (_autoControlEnabled && _shouldPerformAutoAction()) {
          String reason = shouldOpen ? "사용자 활동 감지 - 환기" : "사용자 활동 감지 - 절약";
          Future.microtask(() => _performAutoWindowControl(shouldOpen, reason));
        }
        return SensorAnalysis(
          shouldOpenWindow: shouldOpen,
          reason: shouldOpen
              ? "👤 활동이 감지되었습니다.\n현재 실내 환경을 고려하여 환기를 권장합니다."
              : "👤 활동이 감지되었습니다.\n현재 외부 환경을 고려하여 창문을 닫아두는 것을 권장합니다.",
          urgency: "medium",
          color: shouldOpen ? Colors.green : Colors.orange,
        );
      }

      // 단순 움직임 알림 (조건을 만족하지 않더라도 알림 표시)
      else {
        print("ℹ️ 단순 움직임 감지 알림");
        return SensorAnalysis(
          shouldOpenWindow: false,
          reason: "👤 움직임이 감지되었습니다.\n현재 환경 조건상 창문 상태 변경이 권장되지 않습니다.",
          urgency: "low",
          color: Colors.blue,
        );
      }
    }
    return null; // 특별한 변화 없음
  }

// 자동 동작 수행 가능 여부 확인
  bool _shouldPerformAutoAction() {
    if (_lastAutoAction == null) return true;
    return DateTime.now().difference(_lastAutoAction!) > AUTO_ACTION_COOLDOWN;
  }

// 수정된 환기 버튼 액션 메서드
  Future<void> _handleVentilationAction(bool openWindow) async {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인

    // 창문 상태 업데이트
    setState(() {
      _windowCurrentlyOpen = openWindow;
    });

    String message = openWindow ? "창문을 열어 환기를 시작합니다." : "창문을 닫습니다.";

    // 사용자에게 메시지 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                openWindow ? Icons.window : Icons.window_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: openWindow ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // 백엔드 서버의 API 주소
    final uri = Uri.parse(openWindow
        ? "https://5912-113-198-180-200.ngrok-free.app/iot/send/open"
        : "https://5912-113-198-180-200.ngrok-free.app/iot/send/close");

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("✅ 명령 전송 성공: ${responseData['status']}");

        // 성공 시 추가 피드백
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text("✅ 창문 ${openWindow ? '열기' : '닫기'} 완료"),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("❌ 명령 전송 실패: ${response.statusCode}, ${response.body}");

        // 실패 시 창문 상태 원복
        if (mounted) {
          setState(() {
            _windowCurrentlyOpen = !openWindow;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text("❌ 명령 전송에 실패했습니다."),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("❌ 네트워크 오류: $e");

      // 실패 시 창문 상태 원복
      if (mounted) {
        setState(() {
          _windowCurrentlyOpen = !openWindow;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 8),
                Text("❌ 네트워크 연결을 확인해주세요."),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// 자동 창문 제어 실행
  Future<void> _performAutoWindowControl(bool openWindow, String reason) async {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인

    setState(() {
      _lastAutoAction = DateTime.now();
      _windowCurrentlyOpen = openWindow;
    });

    print("🤖 자동 제어: ${openWindow ? '창문 열기' : '창문 닫기'} - $reason");

    // 사용자에게 자동 제어 알림
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    "🤖 자동 제어: ${openWindow ? '창문 열기' : '창문 닫기'}\n사유: $reason"),
              ),
            ],
          ),
          backgroundColor: openWindow ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '취소',
            textColor: Colors.white,
            onPressed: () {
              // 사용자가 취소하면 반대 동작 수행
              _handleVentilationAction(!openWindow);
            },
          ),
        ),
      );
    }

    // 실제 창문 제어 API 호출
    await _handleVentilationAction(openWindow);
  }

// 공기질 개선 후 창문 닫기 여부 결정
  bool _shouldCloseWindowAfterImprovement() {
    if (_currentAirQuality != null) {
      // 외부 미세먼지가 나쁘면 닫기
      return _currentAirQuality!.pm10 > 50 || _currentAirQuality!.pm25 > 25;
    }
    return false; // 공기질 정보가 없으면 열어둠
  }

// 자동 제어 설정 토글 메서드
  void _toggleAutoControl() {
    setState(() {
      _autoControlEnabled = !_autoControlEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _autoControlEnabled ? Icons.smart_toy : Icons.smart_toy_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _autoControlEnabled ? '🤖 자동 창문 제어 활성화됨' : '🔧 자동 창문 제어 비활성화됨',
            ),
          ],
        ),
        backgroundColor: _autoControlEnabled ? Colors.white : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _shouldCloseWindowAtNight() {
    if (_currentAirQuality != null) {
      return _currentAirQuality!.pm10 > 50 || _currentAirQuality!.pm25 > 25;
    }
    return true; // 공기질 정보가 없으면 기본적으로 닫기 권장
  }

  String _getCloseWindowReason() {
    if (_currentAirQuality != null) {
      if (_currentAirQuality!.pm10 > 80 || _currentAirQuality!.pm25 > 35) {
        return "외부 미세먼지가 나쁩니다.";
      } else if (_currentAirQuality!.pm10 > 50 ||
          _currentAirQuality!.pm25 > 25) {
        return "외부 미세먼지가 보통 수준입니다.";
      }
    }
    return "밤시간 환기를 위해";
  }

  bool _shouldOpenWindowInMorning(SensorData current) {
    // 실내 공기질이 양호하고 외부 공기질도 괜찮을 때만
    bool indoorAirGood =
        current.gas == null || current.gas! < GAS_THRESHOLD_NORMAL;
    bool outdoorAirGood = _currentAirQuality == null ||
        (_currentAirQuality!.pm10 < 50 && _currentAirQuality!.pm25 < 25);

    return indoorAirGood && outdoorAirGood;
  }

  // 스마트 환기 팝업 표시
  void _showSmartVentilationPopup(SensorAnalysis analysis) {
    showDialog(
      context: context,
      barrierDismissible: analysis.urgency != "high", // 긴급한 경우 터치로 닫기 불가
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: analysis.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  analysis.shouldOpenWindow
                      ? Icons.window
                      : Icons.window_outlined,
                  color: analysis.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis.shouldOpenWindow ? '창문 열기 권장' : '창문 닫기 권장',
                        style: TextStyle(
                          color: analysis.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (analysis.urgency == "high")
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '긴급',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                analysis.reason,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),

              // 현재 센서 상태 표시
              if (_lastSensorData != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 현재 센서 상태',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      _buildSensorStatusRow(),
                    ],
                  ),
                ),
              ],

              // 외부 날씨 정보
              if (_currentWeather != null && _currentAirQuality != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🌤️ 외부 환경',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('기온: ${_currentWeather!.temperature}°C'),
                      Text(
                          '미세먼지: ${_currentAirQuality!.pm10.toStringAsFixed(0)}㎍/㎥ (${_getAirQualityStatus(_currentAirQuality!.pm10)})'),
                      Text(
                          '초미세먼지: ${_currentAirQuality!.pm25.toStringAsFixed(0)}㎍/㎥'),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (analysis.urgency != "high")
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('나중에'),
              ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _handleVentilationAction(analysis.shouldOpenWindow);
              },
              icon: Icon(analysis.shouldOpenWindow
                  ? Icons.window
                  : Icons.window_outlined),
              label: Text(analysis.shouldOpenWindow ? '창문 열기' : '창문 닫기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: analysis.color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

// _buildSensorStatusRow() 함수를 완전히 새로 작성:
// _buildMiniTrendChart() 함수 아래에 추가
  Widget _buildModernSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorStatusRow() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // _buildCompactSensorItem에서 조도 값 표시 수정
          if (_lastSensorData!.light != null)
            Expanded(
              child: _buildCompactSensorItem(
                icon: Icons.lightbulb,
                label: '조도',
                value:
                    _lastSensorData!.light == 1 ? '밝음' : '어두움', // 숫자 대신 텍스트로 표시
                color: _getLightColor(_lastSensorData!.light!),
              ),
            ),
          if (_lastSensorData!.gas != null)
            Expanded(
              child: _buildCompactSensorItem(
                icon: Icons.air,
                label: '공기질',
                value: _lastSensorData!.gas.toString(),
                color: _getGasColor(_lastSensorData!.gas!),
              ),
            ),
          if (_lastSensorData!.pir != null)
            Expanded(
              child: _buildCompactSensorItem(
                icon: Icons.person,
                label: '움직임',
                value: _lastSensorData!.pir == 1 ? '감지' : '없음',
                color: _lastSensorData!.pir == 1 ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

// 새로운 컴팩트 센서 아이템 함수 (기존 _buildSensorItem 대신 사용):
  Widget _buildCompactSensorItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 66, // 고정 높이
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// _buildSensorItem 함수도 완전히 새로 작성:
  Widget _buildSensorItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 18, // 크기 더 축소
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9, // 더 작게
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Flexible(
            // Flexible로 텍스트 크기 조절
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 10, // 더 작게
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

// 또는 더 간단한 해결책 - 가로 배치로 변경:
  Widget _buildSensorStatusRowHorizontal() {
    List<Widget> items = [];

    if (_lastSensorData!.light != null) {
      items.add(_buildHorizontalSensorItem(
        icon: Icons.lightbulb,
        label: '조도',
        value: _lastSensorData!.light.toString(),
        color: _getLightColor(_lastSensorData!.light!),
      ));
    }

    if (_lastSensorData!.gas != null) {
      items.add(_buildHorizontalSensorItem(
        icon: Icons.air,
        label: '공기질',
        value: _lastSensorData!.gas.toString(),
        color: _getGasColor(_lastSensorData!.gas!),
      ));
    }

    if (_lastSensorData!.pir != null) {
      items.add(_buildHorizontalSensorItem(
        icon: Icons.person,
        label: '움직임',
        value: _lastSensorData!.pir == 1 ? '감지' : '없음',
        color: _lastSensorData!.pir == 1 ? Colors.blue : Colors.grey,
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((item) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: item,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHorizontalSensorItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

// 가장 안전한 해결책 - 텍스트만 사용:
  Widget _buildSensorStatusRowText() {
    List<String> statusTexts = [];

    if (_lastSensorData!.light != null) {
      statusTexts.add('조도 ${_lastSensorData!.light}');
    }

    if (_lastSensorData!.gas != null) {
      statusTexts.add('공기질 ${_lastSensorData!.gas}');
    }

    if (_lastSensorData!.pir != null) {
      statusTexts.add('움직임 ${_lastSensorData!.pir == 1 ? '감지' : '없음'}');
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusTexts.join(' • '),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

// 또는 더 간단한 해결책 - 센서 상태를 가로 스크롤로 변경:
  Widget _buildSensorStatusRowScrollable() {
    return SizedBox(
      height: 50, // 고정 높이
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_lastSensorData!.light != null)
            Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              child: _buildCompactSensorItem(
                icon: Icons.lightbulb,
                label: '조도',
                value: _lastSensorData!.light.toString(),
                color: _getLightColor(_lastSensorData!.light!),
              ),
            ),
          if (_lastSensorData!.gas != null)
            Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              child: _buildCompactSensorItem(
                icon: Icons.air,
                label: '공기질',
                value: _lastSensorData!.gas.toString(),
                color: _getGasColor(_lastSensorData!.gas!),
              ),
            ),
          if (_lastSensorData!.pir != null)
            Container(
              width: 70,
              child: _buildCompactSensorItem(
                icon: Icons.person,
                label: '움직임',
                value: _lastSensorData!.pir == 1 ? '감지' : '없음',
                color: _lastSensorData!.pir == 1 ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Color _getLightColor(int light) {
    if (light == LIGHT_DIGITAL_DARK) return Colors.indigo; // 어두움
    if (light == LIGHT_DIGITAL_BRIGHT) return Colors.amber; // 밝음
    return Colors.grey; // 기본값
  }

  Color _getGasColor(int gas) {
    if (gas > GAS_THRESHOLD_HIGH) return Colors.red;
    if (gas > GAS_THRESHOLD_NORMAL) return Colors.orange;
    return Colors.green;
  }

  String _getAirQualityStatus(double pm10) {
    if (pm10 <= 30) return '좋음';
    if (pm10 <= 80) return '보통';
    if (pm10 <= 150) return '나쁨';
    return '매우나쁨';
  }

  // 나머지 기존 메서드들...
  void _showLocationSelectionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '지역 선택',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        final allLocations = AppConfig.locationMap.entries.toList();

        return SafeArea(
          child: Center(
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 400,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '지역을 선택하세요',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        itemCount: allLocations.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 3,
                        ),
                        itemBuilder: (context, index) {
                          final entry = allLocations[index];
                          final isSelected = _currentLocation == entry.key;

                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _changeLocation(entry.key);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.favorite,
                                        color: Colors.blue, size: 18),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToWeatherDetail() {
    if (_currentWeather != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDetailScreen(
            locationCode: _currentLocation,
            weather: _currentWeather!,
          ),
        ),
      );
    }
  }

  void _navigateToAirQualityDetail() {
    if (_currentAirQuality != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AirQualityDetailScreen(
            locationCode: _currentLocation,
            airQuality: _currentAirQuality!,
          ),
        ),
      );
    }
  }

  void _calculateVentilationStatus() {
    if (_currentWeather == null || _currentAirQuality == null) return;

    final now = DateTime.now();
    final hour = now.hour;

    bool badWeather = _currentWeather!.precipitation > 0.5 ||
        (_currentWeather!.skyCondition?.contains('비') == true) ||
        (_currentWeather!.skyCondition?.contains('눈') == true);

    bool extremeTemperature =
        _currentWeather!.temperature < 5 || _currentWeather!.temperature > 30;

    bool highDust =
        _currentAirQuality!.pm10 > 80 || _currentAirQuality!.pm25 > 35;

    bool isNightTime = hour < 6 || hour >= 22;

    _isVentilationRecommended =
        !badWeather && !extremeTemperature && !highDust && !isNightTime;

    if (isNightTime) {
      _ventilationMessage = "늦은 밤에는 환기를 삼가는 것이 좋아요.";
    } else if (badWeather) {
      _ventilationMessage = "비/눈이 오고 있어요. 창문을 닫아두세요.";
    } else if (extremeTemperature) {
      _ventilationMessage = _currentWeather!.temperature < 5
          ? "날씨가 춥습니다. 창문을 닫아두세요."
          : "날씨가 덥습니다. 에어컨 사용 시 창문을 닫아두세요.";
    } else if (highDust) {
      _ventilationMessage = "미세먼지가 나쁨 상태입니다. 창문을 닫아두세요.";
    } else {
      _ventilationMessage = "환기하기 좋은 날씨입니다. 창문을 열어 신선한 공기를 들이세요.";
    }
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _apiService.getCurrentWeather(_currentLocation);
      final airQuality =
          await _apiService.getCurrentAirQuality(_currentLocation);
      setState(() {
        _currentWeather = weather;
        _currentAirQuality = airQuality;
        _isLoading = false;

        // 환기 권장 여부 계산 추가
        _calculateVentilationStatus();
      });
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오는 중 오류 발생: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

    return Scaffold(
      appBar: AppBar(
        title: Text('$locationName 스마트 환기'),
        actions: [
          // 센서 모니터링 토글 버튼
          IconButton(
            icon: Icon(
              _isMonitoringActive ? Icons.sensors : Icons.sensors_off,
              color: _isMonitoringActive ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                // 모니터링 상태 토글
                _isMonitoringActive = !_isMonitoringActive;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        _isMonitoringActive ? Icons.sensors : Icons.sensors_off,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isMonitoringActive
                            ? '스마트 모니터링 활성화됨'
                            : '스마트 모니터링 비활성화됨',
                      ),
                    ],
                  ),
                  backgroundColor:
                      _isMonitoringActive ? Colors.green : Colors.grey,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _showLocationSelectionDialog),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadWeatherData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWeatherData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 사용자 인사 카드
                      if (_username != null)
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.person,
                                      size: 24, color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '안녕하세요, $_username님!',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '스마트 환기 시스템이 실시간으로 모니터링 중입니다',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
// 실시간 센서 상태 카드 (완전히 새로 디자인됨)
                      if (_lastSensorData != null)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  _isMonitoringActive
                                      ? Colors.green.shade50
                                      : Colors.grey.shade50,
                                  Colors.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 헤더 부분
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _isMonitoringActive
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _isMonitoringActive
                                              ? Icons.sensors
                                              : Icons.sensors_off,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '실시간 센서 모니터링',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _isMonitoringActive
                                                    ? Colors.green
                                                        .withOpacity(0.3)
                                                    : Colors.red
                                                        .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _isMonitoringActive
                                                      ? Colors.green
                                                      : Colors.red,
                                                  width: 1,
                                                ),
                                              ),
                                              // 변경할 코드:
                                              child: Text(
                                                _isMonitoringActive
                                                    ? '🟢 활성화'
                                                    : '🔴 비활성화',
                                                style: TextStyle(
                                                  color: _isMonitoringActive
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 실시간 애니메이션 점
                                      if (_isMonitoringActive)
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                blurRadius: 4,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // 센서 데이터 카드들
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule,
                                                color: Colors.grey, size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              '마지막 업데이트: ${_formatTime(_lastSensorData!.timestamp)}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // 센서 데이터 그리드
                                        Row(
                                          children: [
                                            // 조도 센서
                                            if (_lastSensorData!.light != null)
                                              Expanded(
                                                child: _buildModernSensorCard(
                                                  icon: Icons.lightbulb_outline,
                                                  label: '조도',
                                                  value:
                                                      _lastSensorData!.light ==
                                                              1
                                                          ? '밝음'
                                                          : '어두움',
                                                  color: _getLightColor(
                                                      _lastSensorData!.light!),
                                                  bgColor: _getLightColor(
                                                          _lastSensorData!
                                                              .light!)
                                                      .withOpacity(0.1),
                                                ),
                                              ),

                                            if (_lastSensorData!.light !=
                                                    null &&
                                                _lastSensorData!.gas != null)
                                              const SizedBox(width: 12),

                                            // 공기질 센서
                                            if (_lastSensorData!.gas != null)
                                              Expanded(
                                                child: _buildModernSensorCard(
                                                  icon: Icons.air,
                                                  label: '공기질',
                                                  value:
                                                      '${_lastSensorData!.gas}',
                                                  color: _getGasColor(
                                                      _lastSensorData!.gas!),
                                                  bgColor: _getGasColor(
                                                          _lastSensorData!.gas!)
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // PIR 센서 (전체 폭)
                                        if (_lastSensorData!.pir != null)
                                          _buildModernSensorCard(
                                            icon: _lastSensorData!.pir == 1
                                                ? Icons.person
                                                : Icons.person_outline,
                                            label: '움직임 감지',
                                            value: _lastSensorData!.pir == 1
                                                ? '감지됨'
                                                : '감지 안됨',
                                            color: _lastSensorData!.pir == 1
                                                ? Colors.blue
                                                : Colors.grey,
                                            bgColor: (_lastSensorData!.pir == 1
                                                    ? Colors.blue
                                                    : Colors.grey)
                                                .withOpacity(0.1),
                                            isFullWidth: true,
                                          ),
                                      ],
                                    ),
                                  ),

                                  // 센서 히스토리 미니 차트 (개선됨)
                                  if (_sensorHistory.length >= 3) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '📈 최근 변화 추이',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildMiniTrendChart(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // 실시간 센서 상태 카드 (개선됨)
//                       if (_lastSensorData != null)
//                         Card(
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   _isMonitoringActive
//                                       ? Colors.green.shade50
//                                       : Colors.grey.shade50,
//                                   Colors.white,
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(20.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: _isMonitoringActive
//                                               ? Colors.green
//                                               : Colors.grey,
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Icon(
//                                           _isMonitoringActive
//                                               ? Icons.sensors
//                                               : Icons.sensors_off,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             const Text(
//                                               '실시간 센서 모니터링',
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               '마지막 업데이트: ${_formatTime(_lastSensorData!.timestamp)}',
//                                               style: TextStyle(
//                                                 color: Colors.grey.shade600,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 20),
//                                   SizedBox(

//   child: _buildSensorStatusRow(),
// ),

//                                   // 센서 히스토리 미니 차트 (선택적)
//                                   if (_sensorHistory.length >= 3) ...[
//                                     const SizedBox(height: 16),
//                                     const Divider(),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       '최근 변화 추이',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.grey.shade700,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     _buildMiniTrendChart(),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       const SizedBox(height: 10),

                      // 날씨 카드
                      if (_currentWeather != null)
                        InkWell(
                          onTap: _navigateToWeatherDetail,
                          child: WeatherCard(weather: _currentWeather!),
                        ),
                      const SizedBox(height: 16),

                      // 공기질 카드
                      if (_currentAirQuality != null)
                        InkWell(
                          onTap: _navigateToAirQualityDetail,
                          child:
                              AirQualityCard(airQuality: _currentAirQuality!),
                        ),
                      const SizedBox(height: 16),

                      // 스마트 환기 권장 카드 (개선됨)
                      if (_currentWeather != null && _currentAirQuality != null)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _isVentilationRecommended
                                  ? Colors.green
                                  : Colors.orange,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  (_isVentilationRecommended
                                          ? Colors.green
                                          : Colors.orange)
                                      .withOpacity(0.1),
                                  Colors.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _isVentilationRecommended
                                              ? Colors.green
                                              : Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _isVentilationRecommended
                                              ? Icons.window
                                              : Icons.window_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _isVentilationRecommended
                                                  ? '✅ 환기 권장'
                                                  : '⚠️ 창문 닫기 권장',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _isVentilationRecommended
                                                    ? Colors.green.shade700
                                                    : Colors.orange.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '종합 환경 분석 결과',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      _ventilationMessage,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // 창문 제어 버튼들
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _handleVentilationAction(true),
                                          icon: const Icon(Icons.window,
                                              size: 20),
                                          label: const Text('창문 열기',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                _isVentilationRecommended
                                                    ? Colors.green
                                                    : Colors.grey.shade400,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: _isVentilationRecommended
                                                ? 3
                                                : 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _handleVentilationAction(false),
                                          icon: const Icon(
                                              Icons.window_outlined,
                                              size: 20),
                                          label: const Text('창문 닫기',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                !_isVentilationRecommended
                                                    ? Colors.orange
                                                    : Colors.grey.shade400,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation:
                                                !_isVentilationRecommended
                                                    ? 3
                                                    : 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('데이터 새로고침 중...'),
                ],
              ),
            ),
          );

          final success = await _apiService.triggerManualFetch();

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('✅ 데이터 수집을 요청했습니다'),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text('❌ 데이터 수집 요청 실패'),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          }

          // UI 갱신
          _loadWeatherData();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('새로고침'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  // 유틸리티 메서드들
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  List<Widget> _buildImprovedChartBars() {
    final recentData = _sensorHistory.take(8).toList().reversed.toList();

    return recentData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isLatest = index == recentData.length - 1;

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 움직임 감지 표시 (상단)
              Flexible(
                flex: 2,
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data.pir == 1 ? Colors.blue : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            data.pir == 1 ? Colors.white : Colors.grey.shade400,
                        width: 1.2,
                      ),
                      boxShadow: [
                        if (data.pir == 1)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 2,
                            spreadRadius: 0.5,
                          ),
                      ],
                    ),
                    child: Icon(
                      data.pir == 1 ? Icons.person : Icons.person_outline,
                      color:
                          data.pir == 1 ? Colors.white : Colors.grey.shade600,
                      size: 8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 공기질 상태 카드 (중앙)
              Flexible(
                flex: 5,
                child: Container(
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          isLatest ? Colors.grey.shade700 : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: data.gas != null
                      ? _buildAirQualityStatusCard(data.gas!, isLatest)
                      : _buildNoDataCard(),
                ),
              ),

              const SizedBox(height: 4),

              // 조도 상태 표시
              Flexible(
                flex: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: data.light != null
                        ? _getLightColor(data.light!)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isLatest ? Colors.grey.shade600 : Colors.transparent,
                      width: 1.2,
                    ),
                    boxShadow: [
                      if (data.light != null)
                        BoxShadow(
                          color: _getLightColor(data.light!).withOpacity(0.4),
                          blurRadius: 2,
                          spreadRadius: 0.5,
                        ),
                    ],
                  ),
                  child: data.light != null
                      ? Icon(
                          data.light == 1 ? Icons.wb_sunny : Icons.nights_stay,
                          color: Colors.white,
                          size: 10,
                        )
                      : const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 10,
                        ),
                ),
              ),

              const SizedBox(height: 4),

              // 시간 표시
              Flexible(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 1.5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isLatest ? Colors.blue.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _getRelativeTime(data.timestamp),
                    style: TextStyle(
                      color: isLatest
                          ? Colors.blue.shade700
                          : Colors.grey.shade500,
                      fontSize: 7,
                      fontWeight:
                          isLatest ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

// 공기질 상태 카드 생성
  Widget _buildAirQualityStatusCard(int gasValue, bool isLatest) {
    final status = _getGasStatusText(gasValue);
    final color = _getGasColor(gasValue);
    final statusIcon = _getGasStatusIcon(gasValue);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 상태 아이콘
          Icon(
            statusIcon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(height: 2),

          // 상태 텍스트
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 2),

          // 수치 (작게)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$gasValue',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

// 데이터 없음 카드
  Widget _buildNoDataCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '데이터\n없음',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

// 공기질 상태별 아이콘 반환
  IconData _getGasStatusIcon(int gas) {
    if (gas > GAS_THRESHOLD_HIGH) return Icons.warning; // 나쁨
    if (gas > GAS_THRESHOLD_NORMAL) return Icons.info; // 보통
    return Icons.check_circle; // 좋음
  }

  Widget _buildMiniTrendChart() {
    if (_sensorHistory.length < 3) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 차트 범례
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildChartLegend('조도', Colors.amber, Icons.wb_sunny),
                  _buildChartLegend('움직임', Colors.blue, Icons.person),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAirQualityLegend('좋음', Colors.green),
                  const SizedBox(width: 16),
                  _buildAirQualityLegend('보통', Colors.orange),
                  const SizedBox(width: 16),
                  _buildAirQualityLegend('나쁨', Colors.red),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 메인 차트 영역 (높이 제한 → 유연하게)
        Container(
          constraints: const BoxConstraints(minHeight: 160, maxHeight: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 차트 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '실내 환경 변화 추이',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '최근 ${_sensorHistory.length}회',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 차트 바는 유연하게 확장
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildImprovedChartBars(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 시간 축
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_sensorHistory.length}회 전',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '현재',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// 공기질 상태별 범례
  Widget _buildAirQualityLegend(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// 공기질 상태 텍스트 반환
  String _getGasStatusText(int gas) {
    if (gas > GAS_THRESHOLD_HIGH) return '나쁨';
    if (gas > GAS_THRESHOLD_NORMAL) return '보통';
    return '좋음';
  }

  Widget _buildChartLegend(String label, Color color, IconData icon) {
    String description = '';
    if (label == '공기질') description = '(좋음/보통/나쁨)';
    if (label == '움직임') description = '(감지/비감지)';
    if (label == '조도') description = '(밝음/어두움)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 10,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars() {
    final recentData = _sensorHistory.take(8).toList().reversed.toList();

    return recentData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isLatest = index == recentData.length - 1;

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 움직임 표시 - 감지/비감지 명확하게 표시
              Container(
                height: 20,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: data.pir == 1 ? Colors.blue : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color:
                            data.pir == 1 ? Colors.white : Colors.grey.shade400,
                        width: 2),
                    boxShadow: [
                      if (data.pir == 1)
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Icon(
                    data.pir == 1 ? Icons.person : Icons.person_outline,
                    color: data.pir == 1 ? Colors.white : Colors.grey.shade600,
                    size: 12,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 공기질 막대 - 좋음/나쁨 텍스트 표시
              // 공기질 막대 - 오버플로우 해결
              Flexible(
                flex: 3,
                child: Container(
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _getGasColor(data.gas ?? 0),
                        _getGasColor(data.gas ?? 0).withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getGasColor(data.gas ?? 0).withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: data.gas != null
                      ? FractionallySizedBox(
                          heightFactor: _normalizeGasValue(data.gas!),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: _getGasColor(data.gas!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min, // 추가: 최소 크기 사용
                              children: [
                                // 높이가 충분할 때만 숫자 표시
                                if (_normalizeGasValue(data.gas!) > 0.2)
                                  Flexible(
                                    // Expanded 대신 Flexible 사용
                                    child: FittedBox(
                                      // 텍스트 크기 자동 조절
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${data.gas}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                // 높이가 매우 충분할 때만 상태 텍스트 표시
                                if (_normalizeGasValue(data.gas!) > 0.5)
                                  Flexible(
                                    // Expanded 대신 Flexible 사용
                                    child: FittedBox(
                                      // 텍스트 크기 자동 조절
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _getGasStatusText(data.gas!),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 6,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: Colors.grey.shade300,
                          ),
                          child: const Center(
                            child: FittedBox(
                              // 여기도 FittedBox 적용
                              child: Text(
                                '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),

              // 조도 표시 (기존과 동일)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: data.light != null
                      ? _getLightColor(data.light!)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLatest ? Colors.grey.shade700 : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    if (data.light != null)
                      BoxShadow(
                        color: _getLightColor(data.light!).withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: data.light != null
                    ? Icon(
                        data.light == 1 ? Icons.wb_sunny : Icons.nights_stay,
                        color: Colors.white,
                        size: 14,
                      )
                    : const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 14,
                      ),
              ),

              const SizedBox(height: 6),

              // 시간 표시 (기존과 동일)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: isLatest ? Colors.blue.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getRelativeTime(data.timestamp),
                  style: TextStyle(
                    color:
                        isLatest ? Colors.blue.shade700 : Colors.grey.shade500,
                    fontSize: 8,
                    fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

// 가스 값 정규화 (0.1 ~ 1.0)
  double _normalizeGasValue(int gasValue) {
    if (gasValue == 0) return 0.1;
    if (gasValue > 500) return 1.0;
    return (gasValue / 500.0).clamp(0.1, 1.0);
  }

// 상대 시간 표시
  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '지금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분';
    if (diff.inHours < 24) return '${diff.inHours}시간';
    return '${diff.inDays}일';
  }
}
