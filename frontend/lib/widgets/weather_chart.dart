import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/models/weather.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class WeatherChart extends StatelessWidget {
  final List<Weather> weatherHistory;
  final String title;
  final Color lineColor;

  const WeatherChart({
    Key? key,
    required this.weatherHistory,
    required this.title,
    this.lineColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weatherHistory.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('데이터가 없습니다')),
        ),
      );
    }

    // 시간순으로 정렬
    final sortedData = [...weatherHistory]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    double minTemp = double.infinity;
    double maxTemp = double.negativeInfinity;
    
    for (var weather in sortedData) {
      if (weather.temperature < minTemp) minTemp = weather.temperature;
      if (weather.temperature > maxTemp) maxTemp = weather.temperature;
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: TemperatureGraphView(
                temperatures: sortedData.map((e) => e.temperature).toList(),
                timeLabels: sortedData.map((e) => DateFormat('HH:mm').format(e.recordedAt)).toList(),
                lineColor: lineColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최저: ${minTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '최고: ${maxTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TemperatureGraphView extends StatelessWidget {
  final List<double> temperatures;
  final List<String> timeLabels;
  final Color lineColor;

  const TemperatureGraphView({
    Key? key,
    required this.temperatures,
    required this.timeLabels,
    required this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: TemperatureGraphPainter(
        temperatures: temperatures,
        timeLabels: timeLabels,
        lineColor: lineColor,
      ),
    );
  }
}

class TemperatureGraphPainter extends CustomPainter {
  final List<double> temperatures;
  final List<String> timeLabels;
  final Color lineColor;

  TemperatureGraphPainter({
    required this.temperatures,
    required this.timeLabels,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (temperatures.isEmpty) return;

    final double padding = 30.0;
    final double graphWidth = size.width - (padding * 2);
    final double graphHeight = size.height - (padding * 2);
    
    // 그래프 경계 그리기
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final graphRect = Rect.fromLTWH(padding, padding, graphWidth, graphHeight);
    canvas.drawRect(graphRect, borderPaint);
    
    // 데이터 범위 계산
    double minTemp = temperatures.reduce((a, b) => a < b ? a : b);
    double maxTemp = temperatures.reduce((a, b) => a > b ? a : b);
    
    // 온도 범위에 약간의 여백 추가
    double tempPadding = (maxTemp - minTemp) * 0.1;
    if (tempPadding == 0) tempPadding = 1.0; // 모든 값이 같을 경우
    
    minTemp -= tempPadding;
    maxTemp += tempPadding;
    
    final tempRange = maxTemp - minTemp;
    
    // 온도 그래프 그리기
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    for (int i = 0; i < temperatures.length; i++) {
      final x = padding + (i / (temperatures.length - 1)) * graphWidth;
      final y = padding + graphHeight - ((temperatures[i] - minTemp) / tempRange * graphHeight);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // 각 데이터 포인트에 점 그리기
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      
      // 시간 라벨 그리기
      if (i % (temperatures.length ~/ 5 + 1) == 0 || i == temperatures.length - 1) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: timeLabels[i],
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
          textDirection: ui.TextDirection.ltr
          // 수정된 부분: TextDirection.ltr -> TextDirection.ltr
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 20));
      }
      
      // 온도 라벨 그리기
      if (i % (temperatures.length ~/ 3 + 1) == 0 || i == temperatures.length - 1) {
        final tempText = '${temperatures[i].toStringAsFixed(1)}°C';
        final textPainter = TextPainter(
          text: TextSpan(
            text: tempText,
            style: TextStyle(color: lineColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          textDirection: ui.TextDirection.ltr

 // 수정된 부분: TextDirection.ltr -> TextDirection.ltr
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 20));
      }
    }
    
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(TemperatureGraphPainter oldDelegate) => true;
}