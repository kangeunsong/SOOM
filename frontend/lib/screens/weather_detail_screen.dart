import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/config.dart';
import 'package:flutter_fastapi_auth/models/air_quality.dart';
import 'package:flutter_fastapi_auth/models/weather.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
import 'package:flutter_fastapi_auth/widgets/weather_chart.dart';
import 'package:intl/intl.dart';

class WeatherDetailScreen extends StatefulWidget {
  final String locationCode;
  final Weather weather;

  const WeatherDetailScreen({
    Key? key, 
    required this.locationCode, 
    required this.weather
  }) : super(key: key);

  @override
  _WeatherDetailScreenState createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  final ApiService _apiService = ApiService();
  Weather? _currentWeather;
  Map<String, dynamic>? _forecastData; // 예보 데이터 저장 변수 추가
  List<Weather> _weatherHistory = [];
  List<AirQuality> _airQualityHistory = [];
  bool _isLoading = true;
  String? _error;
  bool _isVentilationRecommended = false;  // 환기 권장 여부
  String _ventilationMessage = "";         // 환기 관련 메시지
  
  @override
  void initState() {
    super.initState();
    _currentWeather = widget.weather;
    _loadWeatherData();
  }


  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 현재 날씨 데이터 가져오기
      final weather = await _apiService.getCurrentWeather(widget.locationCode);
      
      // 날씨 예보 데이터 가져오기 (API 구현 필요)
      
      // 이력 데이터 가져오기
      final weatherHistory = await _apiService.getWeatherHistory(widget.locationCode, days: 1);
      final airQualityHistory = await _apiService.getAirQualityHistory(widget.locationCode, days: 1);
      
     setState(() {
        _currentWeather = weather;
        _weatherHistory = weatherHistory;
        _airQualityHistory = airQualityHistory;
        _isLoading = false;
        
        // 환기 권장 여부 계산
       
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최신 날씨 데이터를 가져왔습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }
void _handleVentilationAction(bool openWindow) {
    String message = openWindow 
        ? "창문을 열어 환기를 시작합니다." 
        : "창문을 닫습니다.";
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
    
    // 여기에 실제 스마트홈 연동 로직을 추가할 수 있습니다.
    // 예: _apiService.controlWindow(widget.locationCode, openWindow);
  }
  @override
  Widget build(BuildContext context) {
    final locationName = AppConfig.locationMap[widget.locationCode] ?? '알 수 없는 위치';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$locationName 상세 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
            tooltip: '날씨 데이터 새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWeatherData,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWeatherData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 현재 날씨 카드
                        if (_currentWeather != null) ...[
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '현재 날씨',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('yyyy-MM-dd HH:mm').format(_currentWeather!.recordedAt)} 수집',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  WeatherCard(weather: _currentWeather!),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // 오늘의 날씨 상세 정보 카드 추가
                        if (_currentWeather != null) ...[
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '오늘의 날씨 상세',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // 날씨 상세 정보 그리드
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    childAspectRatio: 2.5,
                                    children: [
                                      _buildWeatherInfoTile('체감 온도', '${_currentWeather!.temperature.toStringAsFixed(1)}°C', Icons.thermostat),
                                      _buildWeatherInfoTile('습도', '${_currentWeather!.humidity.toStringAsFixed(0)}%', Icons.water_drop),
                                      _buildWeatherInfoTile('바람', '${_currentWeather!.windDirection} ${_currentWeather!.windSpeed.toStringAsFixed(1)}m/s', Icons.air),
                                      _buildWeatherInfoTile('강수량', '${_currentWeather!.precipitation.toStringAsFixed(1)}mm', Icons.umbrella),
                                      
                                      // 예보 데이터가 있을 경우 추가 정보 표시
                                      if(_forecastData != null) ...[
                                        _buildWeatherInfoTile('강수 확률', '${_forecastData!['rainProbability'] ?? 0}%', Icons.water),
                                        _buildWeatherInfoTile('하늘 상태', _forecastData!['skyCondition'] ?? '정보 없음', Icons.cloud),
                                        _buildWeatherInfoTile('최저 기온', '${_forecastData!['minTemp'] ?? '-'}°C', Icons.arrow_downward),
                                        _buildWeatherInfoTile('최고 기온', '${_forecastData!['maxTemp'] ?? '-'}°C', Icons.arrow_upward),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // 일기 예보 카드 (구현 필요)
                        if (_forecastData != null) ...[
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '일기 예보',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // 일기 예보 리스트
                                  _buildForecastList(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // 날씨 변화 그래프
                        if (_weatherHistory.length > 1)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '온도 변화',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  WeatherChart(
                                    weatherHistory: _weatherHistory,
                                    title: '온도 변화 (°C)',
                                    lineColor: Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // 날씨 관련 추가 정보 또는 조언
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '날씨 정보',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildWeatherAdvice(),
                                const SizedBox(height: 8),
                         
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // 날씨 정보 타일 위젯
  Widget _buildWeatherInfoTile(String label, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24, color: Theme.of(context).primaryColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 일기 예보 리스트 위젯 (API 연동 필요)
  Widget _buildForecastList() {
    // 실제 구현 시에는 API에서 가져온 예보 데이터를 사용
    List<Map<String, dynamic>> forecastList = [
      {'time': '오늘', 'temp': '${_currentWeather?.temperature.toStringAsFixed(1)}°C', 'condition': _currentWeather?.skyCondition ?? '맑음', 'rainProb': '10%'},
      {'time': '내일', 'temp': '${(_currentWeather?.temperature ?? 0) + 1}°C', 'condition': '구름많음', 'rainProb': '30%'},
      {'time': '모레', 'temp': '${(_currentWeather?.temperature ?? 0) + 2}°C', 'condition': '비', 'rainProb': '80%'},
    ];

    return Column(
      children: forecastList.map((forecast) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                forecast['time'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _getWeatherIcon(forecast['condition']),
                  const SizedBox(width: 8),
                  Text(forecast['condition']),
                ],
              ),
              Text('강수 확률: ${forecast['rainProb']}'),
              Text(
                forecast['temp'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ).toList(),
    );
  }

  // 날씨 조건에 따른 아이콘 반환
  Widget _getWeatherIcon(String condition) {
    IconData iconData;
    Color iconColor;
    
    switch (condition.toLowerCase()) {
      case '맑음':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case '구름많음':
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case '비':
        iconData = Icons.umbrella;
        iconColor = Colors.blue;
        break;
      case '눈':
        iconData = Icons.ac_unit;
        iconColor = Colors.lightBlue;
        break;
      case '비/눈':
        iconData = Icons.snowing;
        iconColor = Colors.blueGrey;
        break;
      case '소나기':
        iconData = Icons.grain;
        iconColor = Colors.blueAccent;
        break;
      default:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.grey;
    }
    
    return Icon(iconData, color: iconColor);
  }

  // 날씨에 따른 조언 위젯
  Widget _buildWeatherAdvice() {
    String advice = '날씨 정보가 없습니다.';
    IconData adviceIcon = Icons.info_outline;
    
    if (_currentWeather != null) {
      final temp = _currentWeather!.temperature;
      final skyCondition = _currentWeather!.skyCondition?.toLowerCase() ?? '';
      final precipitation = _currentWeather!.precipitation;
      
      if (skyCondition.contains('비') || precipitation > 0.5) {
        advice = '비가 오고 있어요. 우산을 챙기세요!';
        adviceIcon = Icons.umbrella;
      } else if (skyCondition.contains('눈')) {
        advice = '눈이 오고 있어요. 미끄러움에 주의하세요!';
        adviceIcon = Icons.ac_unit;
      } else if (temp < 5) {
        advice = '추운 날씨입니다. 따뜻하게 입고 나가세요!';
        adviceIcon = Icons.ac_unit;
      } else if (temp > 28) {
        advice = '더운 날씨입니다. 수분 섭취와 열사병에 주의하세요!';
        adviceIcon = Icons.wb_sunny;
      } else if (skyCondition.contains('맑음')) {
        advice = '화창한 날씨입니다. 좋은 하루 되세요!';
        adviceIcon = Icons.wb_sunny;
      } else {
        advice = '오늘은 구름이 많습니다.';
        adviceIcon = Icons.cloud;
      }
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(adviceIcon, color: Theme.of(context).primaryColor, size: 30),
      title: Text(
        advice,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 미세먼지 정보 아이템 위젯
  Widget _buildDustInfoItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // PM10 색상 반환
  Color _getPM10Color(double value) {
    if (value <= 30) return Colors.green;
    if (value <= 80) return Colors.yellow.shade700;
    if (value <= 150) return Colors.orange;
    return Colors.red;
  }

  // PM2.5 색상 반환
  Color _getPM25Color(double value) {
    if (value <= 15) return Colors.green;
    if (value <= 35) return Colors.yellow.shade700;
    if (value <= 75) return Colors.orange;
    return Colors.red;
  }
}