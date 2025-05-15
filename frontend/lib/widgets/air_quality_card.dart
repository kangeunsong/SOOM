import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/models/air_quality.dart';
import 'package:intl/intl.dart';

class AirQualityCard extends StatelessWidget {
  final AirQuality airQuality;
  final VoidCallback? onTap;

  const AirQualityCard({Key? key, required this.airQuality, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${airQuality.locationName} 미세먼지',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MM/dd HH:mm').format(airQuality.recordedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airQuality.airQualityIndex,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: airQuality.getAirQualityColor(),
                        ),
                      ),
                      // Text(
                      //   '미세먼지(PM10): ${airQuality.pm10.toStringAsFixed(0)}µg/m³',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey[700],
                      //   ),
                      // ),
                      // Text(
                      //   '초미세먼지(PM2.5): ${airQuality.pm25.toStringAsFixed(0)}µg/m³',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey[700],
                      //   ),
                      // ),
                    ],
                  ),
                  Text(
                    airQuality.getAirQualityEmoji(),
                    style: const TextStyle(fontSize: 50),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}