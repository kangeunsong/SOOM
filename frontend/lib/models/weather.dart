class Weather {
  final int? id;
  final String locationCode;
  final String locationName;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double precipitation;
  final String skyCondition;
  final DateTime recordedAt;
  
  final DateTime? createdAt;

  Weather({
    this.id,
    required this.locationCode,
    
    required this.locationName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitation,
    required this.skyCondition,
    required this.recordedAt,
    this.createdAt,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      locationCode: json['location_code'],
      locationName: json['location_name'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      windSpeed: json['wind_speed'].toDouble(),
      windDirection: json['wind_direction'],
      precipitation: json['precipitation'].toDouble(),
      skyCondition: json['sky_condition'],
      recordedAt: DateTime.parse(json['recorded_at']),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    );
  }

  String getWeatherIcon() {
    switch (skyCondition) {
      case '맑음':
        return '☀️';
      case '비':
        return '🌧️';
      case '비/눈':
        return '🌨️';
      case '눈':
        return '❄️';
      case '소나기':
        return '🌦️';
      default:
        return '☁️';
    }
  }
}