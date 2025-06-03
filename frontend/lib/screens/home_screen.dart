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

import '../services/wakeword_service.dart';
import '../services/sensor_service.dart';

final WakewordService _wakewordService = WakewordService();
final SensorService _sensorService = SensorService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late String _currentLocation;
  String? _username;
  Weather? _currentWeather;
  AirQuality? _currentAirQuality;
  bool _isLoading = true;
  String? _error;
  bool _isVentilationRecommended = false;
  String _ventilationMessage = "";

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

    _wakewordService.initWakeWord((index) {
      _showWakeWordPopup(); // 웨이크워드 감지 시 UI(팝업창) 처리
    });

    _sensorService.startMonitoring(
      onAnalysisDetected: (analysis) {
        _showSmartVentilationPopup(analysis); // UI 처리
      },
    );
  }

  void _handleVentilationAction(bool openWindow) {
    _sensorService.sendVentilationCommand(openWindow);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              openWindow ? Icons.window : Icons.window_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(openWindow ? '창문 열기 명령 전송됨' : '창문 닫기 명령 전송됨'),
          ],
        ),
        backgroundColor: openWindow ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWakeWordPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('웨이크워드 감지!'),
        content: const Text('안녕하세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showSmartVentilationPopup(SensorAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스마트 환기 권장!'),
        content: Text(analysis.reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _sensorService.sendVentilationCommand(analysis.shouldOpenWindow);
            },
            icon: Icon(analysis.shouldOpenWindow
                ? Icons.window
                : Icons.window_outlined),
            label: Text(analysis.shouldOpenWindow ? '창문 열기' : '창문 닫기'),
          ),
        ],
      ),
    );
  }

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
    _sensorService.stopMonitoring();
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
    final success = await _apiService.logout();
    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
    bool indoorAirGood = current.gas == null ||
        current.gas! < SensorService.GAS_THRESHOLD_NORMAL;
    bool outdoorAirGood = _currentAirQuality == null ||
        (_currentAirQuality!.pm10 < 50 && _currentAirQuality!.pm25 < 25);

    return indoorAirGood && outdoorAirGood;
  }

  Widget _buildSensorStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_sensorService.lastSensorData?.light != null)
          _buildSensorItem(
            icon: Icons.lightbulb,
            label: '조도',
            value: _sensorService.lastSensorData!.light.toString(),
            color: _getLightColor(_sensorService.lastSensorData!.light!),
          ),
        if (_sensorService.lastSensorData?.gas != null)
          _buildSensorItem(
            icon: Icons.air,
            label: '공기질',
            value: _sensorService.lastSensorData!.gas.toString(),
            color: _getGasColor(_sensorService.lastSensorData!.gas!),
          ),
        if (_sensorService.lastSensorData?.pir != null)
          _buildSensorItem(
            icon: Icons.person,
            label: '움직임',
            value: _sensorService.lastSensorData!.pir == 1 ? '감지' : '없음',
            color: _sensorService.lastSensorData!.pir == 1
                ? Colors.blue
                : Colors.grey,
          ),
      ],
    );
  }

  Widget _buildSensorItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Color _getLightColor(int light) {
    if (light < SensorService.LIGHT_THRESHOLD_DARK) return Colors.indigo;
    if (light > SensorService.LIGHT_THRESHOLD_BRIGHT) return Colors.amber;
    return Colors.orange;
  }

  Color _getGasColor(int gas) {
    if (gas > SensorService.GAS_THRESHOLD_HIGH) return Colors.red;
    if (gas > SensorService.GAS_THRESHOLD_NORMAL) return Colors.orange;
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
              _sensorService.isMonitoringActive
                  ? Icons.sensors
                  : Icons.sensors_off,
              color: _sensorService.isMonitoringActive
                  ? Colors.green
                  : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _sensorService.toggleMonitoring(
                  onAnalysisDetected: (analysis) {
                    _showSmartVentilationPopup(analysis);
                  },
                );
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        _sensorService.isMonitoringActive
                            ? Icons.sensors
                            : Icons.sensors_off,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sensorService.isMonitoringActive
                            ? '스마트 모니터링 활성화됨'
                            : '스마트 모니터링 비활성화됨',
                      ),
                    ],
                  ),
                  backgroundColor: _sensorService.isMonitoringActive
                      ? Colors.green
                      : Colors.grey,
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

                      // 실시간 센서 상태 카드 (개선됨)
                      if (_sensorService.lastSensorData != null)
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  _sensorService.isMonitoringActive
                                      ? Colors.green.shade50
                                      : Colors.grey.shade50,
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
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              _sensorService.isMonitoringActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _sensorService.isMonitoringActive
                                              ? Icons.sensors
                                              : Icons.sensors_off,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '실시간 센서 모니터링',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '마지막 업데이트: ${_formatTime(_sensorService.lastSensorData!.timestamp)}',
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
                                  const SizedBox(height: 20),
                                  _buildSensorStatusRow(),

                                  // 센서 히스토리 미니 차트 (선택적)
                                  if (_sensorService.sensorHistory.length >=
                                      3) ...[
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Text(
                                      '최근 변화 추이',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildMiniTrendChart(),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

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

  Widget _buildMiniTrendChart() {
    if (_sensorService.sensorHistory.length < 3) return const SizedBox();

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrendItem(
              '조도',
              _sensorService.sensorHistory
                  .take(5)
                  .map((e) => e.light ?? 0)
                  .toList()),
          _buildTrendItem(
              '공기질',
              _sensorService.sensorHistory
                  .take(5)
                  .map((e) => e.gas ?? 0)
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, List<int> values) {
    if (values.isEmpty) return const SizedBox();

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: values.take(5).map((value) {
            final normalizedHeight = range > 0
                ? ((value - minValue) / range * 20 + 5).toDouble()
                : 15.0;
            return Container(
              width: 4,
              height: normalizedHeight,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: label == '조도' ? Colors.amber : Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 2),
        Text('${values.first}', style: const TextStyle(fontSize: 8)),
      ],
    );
  }
}
