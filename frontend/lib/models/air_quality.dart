import 'dart:ui';

import 'package:flutter/material.dart';

class AirQuality {
  final int? id;
  final String locationCode;
  final String locationName;
  final double pm10;
  final double pm25;
  final String airQualityIndex;
  final DateTime recordedAt;
  final DateTime? createdAt;

  AirQuality({
    this.id,
    required this.locationCode,
    required this.locationName,
    required this.pm10,
    required this.pm25,
    required this.airQualityIndex,
    required this.recordedAt,
    this.createdAt,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    return AirQuality(
      id: json['id'],
      locationCode: json['location_code'],
      locationName: json['location_name'],
      pm10: json['pm10'].toDouble(),
      pm25: json['pm25'].toDouble(),
      airQualityIndex: json['air_quality_index'],
      recordedAt: DateTime.parse(json['recorded_at']),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    );
  }

  String getAirQualityEmoji() {
    switch (airQualityIndex) {
      case '좋음':
        return '😊';
      case '보통':
        return '😐';
      case '나쁨':
        return '😷';
      case '매우 나쁨':
        return '🤢';
      default:
        return '❓';
    }
  }

  Color getAirQualityColor() {
    switch (airQualityIndex) {
      case '좋음':
        return Colors.green;
      case '보통':
        return Colors.yellow.shade700;
      case '나쁨':
        return Colors.orange;
      case '매우 나쁨':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}