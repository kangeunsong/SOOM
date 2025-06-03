import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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

class SensorService {
  Timer? _sensorCheckTimer;
  SensorData? _lastSensorData;
  SensorData? _previousSensorData;
  final List<SensorData> _sensorHistory = [];
  bool _isMonitoringActive = true;

  SensorData? get lastSensorData => _lastSensorData;
  List<SensorData> get sensorHistory => _sensorHistory;
  bool get isMonitoringActive => _isMonitoringActive;

  static const int LIGHT_THRESHOLD_DARK = 150;
  static const int LIGHT_THRESHOLD_BRIGHT = 400;
  static const int LIGHT_CHANGE_THRESHOLD = 100;
  static const int GAS_THRESHOLD_HIGH = 300;
  static const int GAS_THRESHOLD_NORMAL = 100;
  static const int GAS_CHANGE_THRESHOLD = 50;

  void toggleMonitoring(
      {required Function(SensorAnalysis) onAnalysisDetected}) {
    _isMonitoringActive = !_isMonitoringActive;
    if (_isMonitoringActive) {
      startMonitoring(onAnalysisDetected: onAnalysisDetected);
    } else {
      stopMonitoring();
    }
  }

  // 센서 모니터링 시작
  void startMonitoring({
    required Function(SensorAnalysis) onAnalysisDetected,
  }) {
    _sensorCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      final newSensorData = await _fetchSensorData();
      if (newSensorData != null) {
        _previousSensorData = _lastSensorData;
        _lastSensorData = newSensorData;
        _sensorHistory.insert(0, newSensorData);
        if (_sensorHistory.length > 20) {
          _sensorHistory.removeLast();
        }

        if (_previousSensorData != null) {
          final analysis =
              _analyzeSensorChanges(_previousSensorData!, newSensorData);
          if (analysis != null) {
            onAnalysisDetected(analysis); // UI 팝업 등은 화면에서 처리
          }
        }
      }
    });
  }

  // 센서 데이터 수집
  Future<SensorData?> _fetchSensorData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://5912-113-198-180-200.ngrok-free.app/iot/data/latest'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SensorData.fromJson(data);
      } else {
        print('❌ 센서 데이터 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 센서 데이터 조회 오류: $e');
    }
    return null;
  }

  // 센서 변화 분석
  SensorAnalysis? _analyzeSensorChanges(SensorData old, SensorData current) {
    // 1️⃣ 급격한 가스 농도 변화
    if (old.gas != null && current.gas != null) {
      int gasChange = current.gas! - old.gas!;

      if (gasChange > GAS_CHANGE_THRESHOLD &&
          current.gas! > GAS_THRESHOLD_HIGH) {
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason:
              "🚨 실내 공기질이 급격히 악화되었습니다!\n가스 농도: ${old.gas} → ${current.gas}\n즉시 환기가 필요합니다.",
          urgency: "high",
          color: Colors.red,
        );
      }

      if ((current.pir ?? 0) == 1 && current.gas! > GAS_THRESHOLD_HIGH) {
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason:
              "👤 움직임이 감지되었고 실내 공기질이 나쁩니다.\n가스 농도: ${current.gas}\n환기를 권장합니다.",
          urgency: "high",
          color: Colors.orange,
        );
      }
    }

    // 2️⃣ 조도 기반 창문 제어
    if (old.light != null && current.light != null) {
      int lightChange = current.light! - old.light!;

      if (lightChange < -LIGHT_CHANGE_THRESHOLD &&
          current.light! < LIGHT_THRESHOLD_DARK) {
        return SensorAnalysis(
          shouldOpenWindow: false,
          reason: "🌙 어두워졌습니다.\n창문을 닫는 것을 권장합니다.",
          urgency: "medium",
          color: Colors.blue,
        );
      } else if (lightChange > LIGHT_CHANGE_THRESHOLD &&
          current.light! > LIGHT_THRESHOLD_BRIGHT) {
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason: "☀️ 밝아졌습니다!\n창문을 여는 것을 권장합니다.",
          urgency: "low",
          color: Colors.green,
        );
      }
    }

    // 3️⃣ 공기질 개선 후 외부 상황 고려 (예제 단순화)
    if (old.gas != null && current.gas != null) {
      if (old.gas! > GAS_THRESHOLD_HIGH &&
          current.gas! < GAS_THRESHOLD_NORMAL) {
        return SensorAnalysis(
          shouldOpenWindow: false,
          reason: "✅ 실내 공기질이 개선되었습니다.\n창문을 닫는 것을 권장합니다.",
          urgency: "medium",
          color: Colors.amber,
        );
      }
    }

    return null;
  }

  // 환기 명령 전송
  Future<void> sendVentilationCommand(bool openWindow) async {
    final uri = Uri.parse(openWindow
        ? "https://5912-113-198-180-200.ngrok-free.app/iot/send/open"
        : "https://5912-113-198-180-200.ngrok-free.app/iot/send/close");

    try {
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        print("✅ 명령 전송 성공");
      } else {
        print("❌ 명령 전송 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 네트워크 오류: $e");
    }
  }

  void stopMonitoring() {
    _sensorCheckTimer?.cancel();
  }
}
