// import 'package:flutter/material.dart';
// import 'package:flutter_fastapi_auth/models/air_quality.dart';
// import 'package:flutter_fastapi_auth/services/api_service.dart';
// import 'package:flutter_fastapi_auth/config.dart';
// import 'package:intl/intl.dart';

// class AirQualityDetailScreen extends StatefulWidget {
//   final String locationCode;
//   final AirQuality airQuality;

//   const AirQualityDetailScreen({
//     Key? key,
//     required this.locationCode,
//     required this.airQuality,
//   }) : super(key: key);

//   @override
//   State<AirQualityDetailScreen> createState() => _AirQualityDetailScreenState();
// }

// class _AirQualityDetailScreenState extends State<AirQualityDetailScreen> {
//   final ApiService _apiService = ApiService();
//   List<AirQuality> _airQualityHistory = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadHistoryData();
//   }

//   Future<void> _loadHistoryData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final airQualityHistory = await _apiService.getAirQualityHistory(
//         widget.locationCode,
//         days: 1,
//       );
//       setState(() {
//         _airQualityHistory = airQualityHistory;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = '미세먼지 이력을 불러오는 중 오류가 발생했습니다: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locationName = AppConfig.locationMap[widget.locationCode] ?? '알 수 없는 위치';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$locationName 미세먼지 상세'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(_error!, textAlign: TextAlign.center),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadHistoryData,
//                         child: const Text('다시 시도'),
//                       ),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Card(
//                         elevation: 4,
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '현재 미세먼지 상태',
//                                     style: Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   Text(
//                                     DateFormat('yyyy-MM-dd HH:mm').format(widget.airQuality.recordedAt),
//                                     style: Theme.of(context).textTheme.bodySmall,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 24),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Text(
//                                         widget.airQuality.getAirQualityEmoji(),
//                                         style: const TextStyle(fontSize: 80),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         widget.airQuality.airQualityIndex,
//                                         style: TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                           color: widget.airQuality.getAirQualityColor(),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 24),
//                               const Divider(),
//                               const SizedBox(height: 16),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   _buildAirQualityDetailItem(
//                                     '미세먼지\n(PM10)',
//                                     '${widget.airQuality.pm10.toStringAsFixed(0)}',
//                                     'μg/m³',
//                                     _getPm10Color(widget.airQuality.pm10),
//                                   ),
//                                   _buildAirQualityDetailItem(
//                                     '초미세먼지\n(PM2.5)',
//                                     '${widget.airQuality.pm25.toStringAsFixed(0)}',
//                                     'μg/m³',
//                                     _getPm25Color(widget.airQuality.pm25),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       if (_airQualityHistory.isNotEmpty) ...[
//                         Card(
//                           elevation: 4,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   '미세먼지 이력',
//                                   style: Theme.of(context).textTheme.titleLarge,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 SizedBox(
//                                   height: 200,
//                                   child: _buildAirQualityHistoryChart(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Card(
//                           elevation: 4,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   '미세먼지 정보',
//                                   style: Theme.of(context).textTheme.titleLarge,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   '미세먼지(PM10) 등급 기준:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _buildInfoRow('좋음', '0~30 μg/m³', Colors.green),
//                                 _buildInfoRow('보통', '31~80 μg/m³', Colors.yellow.shade700),
//                                 _buildInfoRow('나쁨', '81~150 μg/m³', Colors.orange),
//                                 _buildInfoRow('매우 나쁨', '151 μg/m³ 이상', Colors.red),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   '초미세먼지(PM2.5) 등급 기준:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _buildInfoRow('좋음', '0~15 μg/m³', Colors.green),
//                                 _buildInfoRow('보통', '16~35 μg/m³', Colors.yellow.shade700),
//                                 _buildInfoRow('나쁨', '36~75 μg/m³', Colors.orange),
//                                 _buildInfoRow('매우 나쁨', '76 μg/m³ 이상', Colors.red),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildAirQualityDetailItem(String label, String value, String unit, Color color) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodyMedium,
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.baseline,
//           textBaseline: TextBaseline.alphabetic,
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(width: 4),
//             Text(
//               unit,
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String grade, String range, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 16,
//             height: 16,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 80,
//             child: Text(grade),
//           ),
//           Text(range),
//         ],
//       ),
//     );
//   }

//   Widget _buildAirQualityHistoryChart() {
//     if (_airQualityHistory.isEmpty) {
//       return const Center(child: Text('미세먼지 이력 데이터가 없습니다'));
//     }

//     // 가장 최근 24개 또는 전체 데이터 사용
//     final historyData = _airQualityHistory.length > 24
//         ? _airQualityHistory.sublist(0, 24)
//         : _airQualityHistory;

//     // 시간 순으로 정렬
//     historyData.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

//     return Column(
//       children: [
//         Expanded(
//           child: Row(
//             children: [
//               // Y축 라벨
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text('150', style: Theme.of(context).textTheme.bodySmall),
//                   Text('100', style: Theme.of(context).textTheme.bodySmall),
//                   Text('50', style: Theme.of(context).textTheme.bodySmall),
//                   Text('0', style: Theme.of(context).textTheme.bodySmall),
//                 ],
//               ),
//               const SizedBox(width: 8),
//               // 차트 영역
//               Expanded(
//                 child: CustomPaint(
//                   size: Size.infinite,
//                   painter: AirQualityChartPainter(
//                     pm10Values: historyData.map((e) => e.pm10).toList(),
//                     pm25Values: historyData.map((e) => e.pm25).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         // X축 라벨
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               DateFormat('HH:mm').format(historyData.first.recordedAt),
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//             Text(
//               DateFormat('HH:mm').format(historyData.last.recordedAt),
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//        const SizedBox(height: 8),
//         // X축 라벨
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               DateFormat('HH:mm').format(historyData.first.recordedAt),
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//             Text(
//               DateFormat('HH:mm').format(historyData.last.recordedAt),
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         // 범례
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 12,
//               height: 12,
//               color: Colors.red,
//             ),
//             const SizedBox(width: 4),
//             const Text('미세먼지(PM10)'),
//             const SizedBox(width: 16),
//             Container(
//               width: 12,
//               height: 12,
//               color: Colors.blue,
//             ),
//             const SizedBox(width: 4),
//             const Text('초미세먼지(PM2.5)'),
//           ],
//         ),
//       ],
//     );
//   }

//   Color _getPm10Color(double value) {
//     if (value <= 30) return Colors.green;
//     if (value <= 80) return Colors.yellow.shade700;
//     if (value <= 150) return Colors.orange;
//     return Colors.red;
//   }

//   Color _getPm25Color(double value) {
//     if (value <= 15) return Colors.green;
//     if (value <= 35) return Colors.yellow.shade700;
//     if (value <= 75) return Colors.orange;
//     return Colors.red;
//   }
// }

// class AirQualityChartPainter extends CustomPainter {
//   final List<double> pm10Values;
//   final List<double> pm25Values;

//   AirQualityChartPainter({
//     required this.pm10Values,
//     required this.pm25Values,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final pm10Paint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
    
//     final pm25Paint = Paint()
//       ..color = Colors.blue
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
    
//     final gridPaint = Paint()
//       ..color = Colors.grey.withOpacity(0.3)
//       ..strokeWidth = 1;
    
//     // 그리드 라인 그리기
//     for (int i = 0; i <= 3; i++) {
//       final y = size.height - (i * size.height / 3);
//       canvas.drawLine(
//         Offset(0, y),
//         Offset(size.width, y),
//         gridPaint,
//       );
//     }
    
//     if (pm10Values.isEmpty || pm25Values.isEmpty) return;
    
//     final pm10Path = Path();
//     final pm25Path = Path();
    
//     const maxValue = 150.0; // 그래프 최대 값
    
//     // PM10 경로 그리기
//     for (int i = 0; i < pm10Values.length; i++) {
//       final x = i * size.width / (pm10Values.length - 1);
//       final y = size.height - (pm10Values[i] / maxValue * size.height);
      
//       if (i == 0) {
//         pm10Path.moveTo(x, y);
//       } else {
//         pm10Path.lineTo(x, y);
//       }
//     }
    
//     // PM2.5 경로 그리기
//     for (int i = 0; i < pm25Values.length; i++) {
//       final x = i * size.width / (pm25Values.length - 1);
//       final y = size.height - (pm25Values[i] / maxValue * size.height);
      
//       if (i == 0) {
//         pm25Path.moveTo(x, y);
//       } else {
//         pm25Path.lineTo(x, y);
//       }
//     }
    
//     canvas.drawPath(pm10Path, pm10Paint);
//     canvas.drawPath(pm25Path, pm25Paint);
    
//     // 데이터 포인트 표시
//     for (int i = 0; i < pm10Values.length; i++) {
//       final x = i * size.width / (pm10Values.length - 1);
//       final y = size.height - (pm10Values[i] / maxValue * size.height);
      
//       canvas.drawCircle(
//         Offset(x, y),
//         3,
//         Paint()..color = Colors.red,
//       );
//     }
    
//     for (int i = 0; i < pm25Values.length; i++) {
//       final x = i * size.width / (pm25Values.length - 1);
//       final y = size.height - (pm25Values[i] / maxValue * size.height);
      
//       canvas.drawCircle(
//         Offset(x, y),
//         3,
//         Paint()..color = Colors.blue,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/models/air_quality.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:flutter_fastapi_auth/config.dart';
import 'package:intl/intl.dart';

class AirQualityDetailScreen extends StatefulWidget {
  final String locationCode;
  final AirQuality airQuality;

  const AirQualityDetailScreen({
    Key? key,
    required this.locationCode,
    required this.airQuality,
  }) : super(key: key);

  @override
  State<AirQualityDetailScreen> createState() => _AirQualityDetailScreenState();
}

class _AirQualityDetailScreenState extends State<AirQualityDetailScreen> {
  final ApiService _apiService = ApiService();
  List<AirQuality> _airQualityHistory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final airQualityHistory = await _apiService.getAirQualityHistory(
        widget.locationCode,
        days: 1,
      );
      setState(() {
        _airQualityHistory = airQualityHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '미세먼지 이력을 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationName = AppConfig.locationMap[widget.locationCode] ?? '알 수 없는 위치';

    return Scaffold(
      appBar: AppBar(
        title: Text('$locationName 미세먼지 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
            tooltip: '데이터 새로고침',
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
                        onPressed: _loadHistoryData,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistoryData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 현재 미세먼지 상태 카드
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '현재 미세먼지 상태',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm').format(widget.airQuality.recordedAt),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          widget.airQuality.getAirQualityEmoji(),
                                          style: const TextStyle(fontSize: 80),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.airQuality.airQualityIndex,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: widget.airQuality.getAirQualityColor(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildAirQualityDetailItem(
                                      '미세먼지\n(PM10)',
                                      '${widget.airQuality.pm10.toStringAsFixed(0)}',
                                      'μg/m³',
                                      _getPm10Color(widget.airQuality.pm10),
                                    ),
                                    _buildAirQualityDetailItem(
                                      '초미세먼지\n(PM2.5)',
                                      '${widget.airQuality.pm25.toStringAsFixed(0)}',
                                      'μg/m³',
                                      _getPm25Color(widget.airQuality.pm25),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 건강 영향 정보 카드
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '건강 영향 정보',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                _buildHealthImpactItem(
                                  '좋음',
                                  '대기오염 관련 질환자군에서도 영향이 유발되지 않을 수 있는 수준',
                                  Colors.green,
                                ),
                                const SizedBox(height: 8),
                                _buildHealthImpactItem(
                                  '보통',
                                  '환자군에게 만성 노출시 경미한 영향이 유발될 수 있는 수준',
                                  Colors.yellow.shade700,
                                ),
                                const SizedBox(height: 8),
                                _buildHealthImpactItem(
                                  '나쁨',
                                  '환자군 및 민감군에게 유해한 영향이 유발될 수 있는 수준',
                                  Colors.orange,
                                ),
                                const SizedBox(height: 8),
                                _buildHealthImpactItem(
                                  '매우 나쁨',
                                  '환자군 및 민감군에게 급성노출시 심각한 영향 유발될 수 있는 수준',
                                  Colors.red,
                                ),
                                const SizedBox(height: 16),
                                _buildCurrentHealthAdvice(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
// Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   '미세먼지 기준 정보',
//                                   style: Theme.of(context).textTheme.titleLarge,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   '미세먼지(PM10) 등급 기준:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _buildInfoRow('좋음', '0~30 μg/m³', Colors.green),
//                                 _buildInfoRow('보통', '31~80 μg/m³', Colors.yellow.shade700),
//                                 _buildInfoRow('나쁨', '81~150 μg/m³', Colors.orange),
//                                 _buildInfoRow('매우 나쁨', '151 μg/m³ 이상', Colors.red),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   '초미세먼지(PM2.5) 등급 기준:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _buildInfoRow('좋음', '0~15 μg/m³', Colors.green),
//                                 _buildInfoRow('보통', '16~35 μg/m³', Colors.yellow.shade700),
//                                 _buildInfoRow('나쁨', '36~75 μg/m³', Colors.orange),
//                                 _buildInfoRow('매우 나쁨', '76 μg/m³ 이상', Colors.red),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   '※ 미세먼지 정보는 환경부 대기환경정보 기준을 따릅니다.',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                     fontStyle: FontStyle.italic,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // 미세먼지 대응 행동 요령 카드
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '미세먼지 대응 행동 요령',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                _buildTipItem(
                                  Icons.home,
                                  '실내 활동',
                                  '창문을 닫고 공기청정기를 가동하세요.',
                                ),
                                _buildTipItem(
                                  Icons.masks,
                                  '마스크 착용',
                                  '외출 시 식약처 인증 마스크를 착용하세요.',
                                ),
                                _buildTipItem(
                                  Icons.water_drop,
                                  '수분 섭취',
                                  '물을 충분히 마셔 호흡기를 보호하세요.',
                                ),
                                _buildTipItem(
                                  Icons.cleaning_services,
                                  '귀가 후 세척',
                                  '외출 후 손과 얼굴을 깨끗이 씻으세요.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 미세먼지 정보 카드 (기존 코드)
                        
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAirQualityDetailItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String grade, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(grade),
          ),
          Text(range),
        ],
      ),
    );
  }

  Widget _buildHealthImpactItem(String grade, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grade,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentHealthAdvice() {
    String advice = '';
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.blue;
    
    // 현재 미세먼지 상태에 따른 건강 조언
    if (widget.airQuality.pm10 > 150 || widget.airQuality.pm25 > 75) {
      advice = '미세먼지가 매우 나쁨 수준입니다. 가능하면 외출을 자제하고, 외출 시 마스크를 착용하세요.';
      icon = Icons.masks;
      iconColor = Colors.red;
    } else if (widget.airQuality.pm10 > 80 || widget.airQuality.pm25 > 35) {
      advice = '미세먼지가 나쁨 수준입니다. 호흡기 질환이 있으신 분들은 실외활동을 줄이고 마스크를 착용하세요.';
      icon = Icons.healing;
      iconColor = Colors.orange;
    } else if (widget.airQuality.pm10 > 30 || widget.airQuality.pm25 > 15) {
      advice = '미세먼지가 보통 수준입니다. 민감군은 장시간 실외 활동 시 주의하세요.';
      icon = Icons.sentiment_neutral;
      iconColor = Colors.yellow.shade800;
    } else {
      advice = '미세먼지가 좋음 수준입니다. 실외활동에 제약이 없어요.';
      icon = Icons.sentiment_very_satisfied;
      iconColor = Colors.green;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPm10Color(double value) {
    if (value <= 30) return Colors.green;
    if (value <= 80) return Colors.yellow.shade700;
    if (value <= 150) return Colors.orange;
    return Colors.red;
  }

  Color _getPm25Color(double value) {
    if (value <= 15) return Colors.green;
    if (value <= 35) return Colors.yellow.shade700;
    if (value <= 75) return Colors.orange;
    return Colors.red;
  }
}