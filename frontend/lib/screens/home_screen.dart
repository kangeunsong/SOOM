// // import 'package:flutter/material.dart';
// // import 'package:flutter_fastapi_auth/models/weather.dart';
// // import 'package:flutter_fastapi_auth/models/air_quality.dart';
// // import 'package:flutter_fastapi_auth/services/api_service.dart';
// // import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
// // import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
// // import 'package:flutter_fastapi_auth/config.dart';
// // import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';
// // import 'package:flutter_fastapi_auth/screens/settings_screen.dart';

// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({Key? key}) : super(key: key);

// //   @override
// //   _HomeScreenState createState() => _HomeScreenState();
// // }

// // class _HomeScreenState extends State<HomeScreen> {
// //   final ApiService _apiService = ApiService();
// //   late Future<String> _defaultLocationFuture;
// //   late String _currentLocation;
// //   String? _username;
  
// //   Weather? _currentWeather;
// //   AirQuality? _currentAirQuality;
// //   bool _isLoading = true;
// //   String? _error;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _defaultLocationFuture = AppConfig.getDefaultLocation();
// //     _defaultLocationFuture.then((location) {
// //       _currentLocation = location;
// //       _loadWeatherData();
// //     });
// //     _loadUsername();
// //   }

// //   Future<void> _loadUsername() async {
// //     final profile = await _apiService.getProfile();
// //     if (profile != null) {
// //       setState(() {
// //         _username = profile['username'];
// //       });
// //     }
// //   }

// //   Future<void> _loadWeatherData() async {
// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //     });

// //     try {
// //       final weather = await _apiService.getCurrentWeather(_currentLocation);
// //       final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
      
// //       setState(() {
// //         _currentWeather = weather;
// //         _currentAirQuality = airQuality;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _error = '데이터를 불러오는 중 오류가 발생했습니다: $e';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   void _changeLocation(String locationCode) {
// //     setState(() {
// //       _currentLocation = locationCode;
// //     });
// //     AppConfig.setDefaultLocation(locationCode);
// //     _loadWeatherData();
// //   }

// //   void _logout() async {
// //     final success = await _apiService.logout();
// //     if (success) {
// //       Navigator.pushReplacementNamed(context, '/login');
// //     }
// //   }

// //   void _showLocationSelectionDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: const Text('지역 선택'),
// //           content: SizedBox(
// //             width: double.maxFinite,
// //             height: 400,
// //             child: ListView(
// //               shrinkWrap: true,
// //               children: [
// //                 _buildRegionCategory('수도권', [
// //                   '60,127', '55,124', '61,125', '62,120', '62,126', '61,131', '65,130'
// //                 ]),
// //                 _buildRegionCategory('강원권', [
// //                   '73,134', '84,135', '92,131', '73,127'
// //                 ]),
// //                 _buildRegionCategory('충청권', [
// //                   '63,89', '68,87', '68,107', '69,106', '67,100', '68,83', '76,88'
// //                 ]),
// //                 _buildRegionCategory('경상권', [
// //                   '89,90', '98,76', '91,77', '91,106', '80,70', '87,68', '81,75', '102,84'
// //                 ]),
// //                 _buildRegionCategory('전라권', [
// //                   '51,67', '59,74', '56,71', '58,64', '56,53', '63,56'
// //                 ]),
// //                 _buildRegionCategory('제주', [
// //                   '52,38'
// //                 ]),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildRegionCategory(String categoryName, List<String> locationCodes) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 8.0),
// //           child: Text(
// //             categoryName,
// //             style: const TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //         Wrap(
// //           spacing: 8.0,
// //           runSpacing: 8.0,
// //           children: locationCodes.map((code) {
// //             final name = AppConfig.locationMap[code] ?? '알 수 없음';
// //             return ActionChip(
// //               label: Text(name),
// //               backgroundColor: _currentLocation == code 
// //                 ? Theme.of(context).primaryColor.withOpacity(0.3) 
// //                 : null,
// //               onPressed: () {
// //                 Navigator.pop(context);
// //                 _changeLocation(code);
// //               },
// //             );
// //           }).toList(),
// //         ),
// //         const Divider(),
// //       ],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: GestureDetector(
// //           onTap: _showLocationSelectionDialog,
// //           child: Row(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Flexible(
// //                 child: FutureBuilder<String>(
// //                   future: _defaultLocationFuture,
// //                   builder: (context, snapshot) {
// //                     if (snapshot.hasData) {
// //                       final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';
// //                       return Text(
// //                         '$locationName 날씨',
// //                         overflow: TextOverflow.ellipsis,
// //                       );
// //                     }
// //                     return const Text('날씨 정보');
// //                   },
// //                 ),
// //               ),
// //               const SizedBox(width: 4),
// //               const Icon(Icons.arrow_drop_down, size: 20),
// //             ],
// //           ),
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.settings),
// //             onPressed: () async {
// //               final result = await Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => const SettingsScreen(),
// //                 ),
// //               );
              
// //               if (result != null && result is String) {
// //                 _changeLocation(result);
// //               }
// //             },
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: _logout,
// //           ),
// //         ],
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _error != null
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Text(_error!, textAlign: TextAlign.center),
// //                       const SizedBox(height: 16),
// //                       ElevatedButton(
// //                         onPressed: _loadWeatherData,
// //                         child: const Text('다시 시도'),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : RefreshIndicator(
// //                   onRefresh: _loadWeatherData,
// //                   child: SingleChildScrollView(
// //                     physics: const AlwaysScrollableScrollPhysics(),
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.stretch,
// //                       children: [
// //                         if (_username != null)
// //                           Padding(
// //                             padding: const EdgeInsets.only(bottom: 16.0),
// //                             child: Card(
// //                               child: Padding(
// //                                 padding: const EdgeInsets.all(16.0),
// //                                 child: Row(
// //                                   children: [
// //                                     const Icon(Icons.person, size: 32),
// //                                     const SizedBox(width: 16),
// //                                     Text(
// //                                       '안녕하세요, $_username님!',
// //                                       style: const TextStyle(
// //                                         fontSize: 18,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         if (_currentWeather != null)
// //                           WeatherCard(
// //                             weather: _currentWeather!,
// //                             onTap: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (context) => WeatherDetailScreen(
// //                                     locationCode: _currentLocation,
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         const SizedBox(height: 16),
// //                         if (_currentAirQuality != null)
// //                           AirQualityCard(
// //                             airQuality: _currentAirQuality!,
// //                           ),
// //                         const SizedBox(height: 16),
// //                         ElevatedButton.icon(
// //                           icon: const Icon(Icons.location_on),
// //                           label: const Text('지역 변경'),
// //                           onPressed: _showLocationSelectionDialog,
// //                           style: ElevatedButton.styleFrom(
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _loadWeatherData,
// //         tooltip: '새로고침',
// //         child: const Icon(Icons.refresh),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_fastapi_auth/models/weather.dart';
// import 'package:flutter_fastapi_auth/models/air_quality.dart';
// import 'package:flutter_fastapi_auth/services/api_service.dart';
// import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
// import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
// import 'package:flutter_fastapi_auth/config.dart';
// import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';
// import 'package:flutter_fastapi_auth/screens/settings_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ApiService _apiService = ApiService();
//   late Future<String> _defaultLocationFuture;
//   late String _currentLocation;
//   String? _username;
//   Weather? _currentWeather;
//   AirQuality? _currentAirQuality;
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _defaultLocationFuture = AppConfig.getDefaultLocation();
//     _defaultLocationFuture.then((location) {
//       _currentLocation = location;
//       _loadWeatherData();
//     });
//     _loadUsername();
//   }

//   Future<void> _loadUsername() async {
//     final profile = await _apiService.getProfile();
//     if (profile != null) {
//       setState(() {
//         _username = profile['username'];
//       });
//     }
//   }

//   Future<void> _loadWeatherData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final weather = await _apiService.getCurrentWeather(_currentLocation);
//       final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
//       setState(() {
//         _currentWeather = weather;
//         _currentAirQuality = airQuality;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = '데이터를 불러오는 중 오류 발생: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _changeLocation(String locationCode) {
//     setState(() {
//       _currentLocation = locationCode;
//     });
//     AppConfig.setDefaultLocation(locationCode);
//     _loadWeatherData();
//   }

//   void _logout() async {
//     final success = await _apiService.logout();
//     if (success) {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   void _showLocationSelectionDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('지역 선택'),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 400,
//           child: ListView(
//             children: AppConfig.locationMap.entries.map((entry) {
//               return ListTile(
//                 title: Text(entry.value),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _changeLocation(entry.key);
//                 },
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$locationName 날씨'),
//         actions: [
//           IconButton(icon: const Icon(Icons.location_on), onPressed: _showLocationSelectionDialog),
//           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
//         ],
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
//                         onPressed: _loadWeatherData,
//                         child: const Text('다시 시도'),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadWeatherData,
//                   child: ListView(
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       if (_username != null)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: Text('안녕하세요, $_username님!', style: const TextStyle(fontSize: 18)),
//                         ),
//                       if (_currentWeather != null)
//                         WeatherCard(weather: _currentWeather!),
//                       const SizedBox(height: 16),
//                       if (_currentAirQuality != null)
//                         AirQualityCard(airQuality: _currentAirQuality!),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.place),
//                         label: const Text('지역 변경'),
//                         onPressed: _showLocationSelectionDialog,
//                       ),
//                     ],
//                   ),
//                 ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _loadWeatherData,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/models/weather.dart';
import 'package:flutter_fastapi_auth/models/air_quality.dart';
import 'package:flutter_fastapi_auth/screens/air_quality_detail_screen.dart';
import 'package:flutter_fastapi_auth/services/api_service.dart';
import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
import 'package:flutter_fastapi_auth/config.dart';
import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';


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
  
  @override
  void initState() {
    super.initState();
    _defaultLocationFuture = AppConfig.getDefaultLocation();
    _defaultLocationFuture.then((location) {
      _currentLocation = location;
      _loadWeatherData();
    });
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final profile = await _apiService.getProfile();
    if (profile != null) {
      setState(() {
        _username = profile['username'];
      });
    }
  }

  // Future<void> _loadWeatherData() async {
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });

  //   try {
  //     final weather = await _apiService.getCurrentWeather(_currentLocation);
  //     final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
  //     setState(() {
  //       _currentWeather = weather;
  //       _currentAirQuality = airQuality;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = '데이터를 불러오는 중 오류 발생: $e';
  //       _isLoading = false;
  //     });
  //   }
  // }

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: allLocations.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.blue : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.favorite, color: Colors.blue, size: 18),
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

  // void _showLocationSelectionDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('지역 선택'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         height: 400,
  //         child: ListView(
  //           children: AppConfig.locationMap.entries.map((entry) {
  //             return ListTile(
  //               title: Text(entry.value),
  //               selected: _currentLocation == entry.key,
  //               selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _changeLocation(entry.key);
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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

  bool extremeTemperature = _currentWeather!.temperature < 5 ||
      _currentWeather!.temperature > 30;

  bool highDust = _currentAirQuality!.pm10 > 80 ||
      _currentAirQuality!.pm25 > 35;

  bool isNightTime = hour < 6 || hour >= 22;

  _isVentilationRecommended = !badWeather && !extremeTemperature && !highDust && !isNightTime;

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

  // // 환기 권장 여부 계산 메서드 추가
  // void _calculateVentilationStatus() {
  //   if (_currentWeather == null || _currentAirQuality == null) return;
    
  //   // 날씨 조건 확인 (비/눈이 오는 경우)
  //   bool badWeather = _currentWeather!.precipitation > 0.5 ||
  //                     (_currentWeather!.skyCondition?.contains('비') == true) ||
  //                     (_currentWeather!.skyCondition?.contains('눈') == true);
    
  //   // 온도 조건 확인 (너무 춥거나 너무 더운 경우)
  //   bool extremeTemperature = _currentWeather!.temperature < 5 || 
  //                            _currentWeather!.temperature > 30;
    
  //   // 미세먼지 조건 확인
  //   bool highDust = _currentAirQuality!.pm10 > 80 || _currentAirQuality!.pm25 > 35;
    
  //   // 환기 권장 여부 결정
  //   _isVentilationRecommended = !badWeather && !extremeTemperature && !highDust;
    
  //   // 메시지 설정
  //   if (badWeather) {
  //     _ventilationMessage = "비/눈이 오고 있어요. 창문을 닫아두세요.";
  //   } else if (extremeTemperature) {
  //     _ventilationMessage = _currentWeather!.temperature < 5 
  //         ? "날씨가 춥습니다. 창문을 닫아두세요." 
  //         : "날씨가 덥습니다. 에어컨 사용 시 창문을 닫아두세요.";
  //   } else if (highDust) {
  //     _ventilationMessage = "미세먼지가 나쁨 상태입니다. 창문을 닫아두세요.";
  //   } else {
  //     _ventilationMessage = "환기하기 좋은 날씨입니다. 창문을 열어 신선한 공기를 들이세요.";
  //   }
  // }

  // 환기 버튼 액션 메서드
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
    // 예: _apiService.controlWindow(_currentLocation, openWindow);
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _apiService.getCurrentWeather(_currentLocation);
      final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
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
        title: Text('$locationName 날씨'),
        actions: [
          IconButton(icon: const Icon(Icons.location_on), onPressed: _showLocationSelectionDialog),
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
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_username != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 32),
                                  const SizedBox(width: 16),
                                  Text(
                                    '안녕하세요, $_username님!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_currentWeather != null)
                        InkWell(
                          onTap: _navigateToWeatherDetail,
                          child: WeatherCard(weather: _currentWeather!),
                        ),
                      const SizedBox(height: 16),
                      if (_currentAirQuality != null)
                        InkWell(
                          onTap: _navigateToAirQualityDetail,
                          child: AirQualityCard(airQuality: _currentAirQuality!),
                        ),
                      const SizedBox(height: 16),
                      
                      // 환기 상태 카드 추가
                      if (_currentWeather != null && _currentAirQuality != null)
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _isVentilationRecommended ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _isVentilationRecommended ? Icons.window : Icons.window_outlined,
                                      color: _isVentilationRecommended ? Colors.green : Colors.red,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _isVentilationRecommended ? '환기 권장' : '창문 닫기 권장',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // 환기 조건 요약
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        // children: [
                                        //   // Icon(Icons.thermostat, 
                                        //   //     color: _currentWeather!.temperature > 30 || _currentWeather!.temperature < 5 
                                        //   //         ? Colors.red : Colors.green, 
                                        //   //     size: 16),
                                        //   const SizedBox(width: 4),
                                        //   Text('온도: ${_currentWeather!.temperature.toStringAsFixed(1)}°C'),
                                        // ],
                                      ),
                                      // const SizedBox(height: 4),
                                      // Row(
                                      //   children: [
                                      //     Icon(Icons.air, 
                                      //         color: _currentAirQuality!.pm10 > 80 ? Colors.red : Colors.green, 
                                      //         size: 16),
                                      //     const SizedBox(width: 4),
                                      //     Text('미세먼지: ${_currentAirQuality!.pm10.toStringAsFixed(0)}μg/m³'),
                                      //   ],
                                      // ),
                                      // const SizedBox(height: 4),
                                      // Row(
                                      //   children: [
                                      //     Icon(Icons.water_drop, 
                                      //         color: _currentWeather!.precipitation > 0.5 ? Colors.red : Colors.green, 
                                      //         size: 16),
                                      //     const SizedBox(width: 4),
                                      //     Text('강수량: ${_currentWeather!.precipitation.toStringAsFixed(1)}mm'),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                Text(
                                  _ventilationMessage,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _isVentilationRecommended ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // 창문 열기/닫기 버튼
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleVentilationAction(true),
                                        icon: const Icon(Icons.window),
                                        label: const Text('창문 열기'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isVentilationRecommended ? Colors.green : Colors.grey,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleVentilationAction(false),
                                        icon: const Icon(Icons.window_outlined),
                                        label: const Text('창문 닫기'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: !_isVentilationRecommended ? Colors.red : Colors.grey,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      // ElevatedButton.icon(
                      //   icon: const Icon(Icons.place),
                      //   label: const Text('지역 변경'),
                      //   onPressed: _showLocationSelectionDialog,
                      // ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadWeatherData,
        tooltip: '새로고침',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$locationName 날씨'),
//         actions: [
//           IconButton(icon: const Icon(Icons.location_on), onPressed: _showLocationSelectionDialog),
//           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
//         ],
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
//                         onPressed: _loadWeatherData,
//                         child: const Text('다시 시도'),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadWeatherData,
//                   child: ListView(
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       if (_username != null)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: Card(
//                             child: Padding(
//                               padding: const EdgeInsets.all(16.0),
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.person, size: 32),
//                                   const SizedBox(width: 16),
//                                   Text(
//                                     '안녕하세요, $_username님!',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       if (_currentWeather != null)
//                         InkWell(
//                           onTap: _navigateToWeatherDetail,
//                           child: WeatherCard(weather: _currentWeather!),
//                         ),
//                       const SizedBox(height: 16),
//                       if (_currentAirQuality != null)
//                         InkWell(
//                           onTap: _navigateToAirQualityDetail,
//                           child: AirQualityCard(airQuality: _currentAirQuality!),
//                         ),
//                       const SizedBox(height: 16),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.place),
//                         label: const Text('지역 변경'),
//                         onPressed: _showLocationSelectionDialog,
//                       ),
//                     ],
//                   ),
//                 ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _loadWeatherData,
//         tooltip: '새로고침',
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }