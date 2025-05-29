// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_fastapi_auth/models/weather.dart';
// // // // import 'package:flutter_fastapi_auth/models/air_quality.dart';
// // // // import 'package:flutter_fastapi_auth/services/api_service.dart';
// // // // import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
// // // // import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
// // // // import 'package:flutter_fastapi_auth/config.dart';
// // // // import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';
// // // // import 'package:flutter_fastapi_auth/screens/settings_screen.dart';

// // // // class HomeScreen extends StatefulWidget {
// // // //   const HomeScreen({Key? key}) : super(key: key);

// // // //   @override
// // // //   _HomeScreenState createState() => _HomeScreenState();
// // // // }

// // // // class _HomeScreenState extends State<HomeScreen> {
// // // //   final ApiService _apiService = ApiService();
// // // //   late Future<String> _defaultLocationFuture;
// // // //   late String _currentLocation;
// // // //   String? _username;
  
// // // //   Weather? _currentWeather;
// // // //   AirQuality? _currentAirQuality;
// // // //   bool _isLoading = true;
// // // //   String? _error;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _defaultLocationFuture = AppConfig.getDefaultLocation();
// // // //     _defaultLocationFuture.then((location) {
// // // //       _currentLocation = location;
// // // //       _loadWeatherData();
// // // //     });
// // // //     _loadUsername();
// // // //   }

// // // //   Future<void> _loadUsername() async {
// // // //     final profile = await _apiService.getProfile();
// // // //     if (profile != null) {
// // // //       setState(() {
// // // //         _username = profile['username'];
// // // //       });
// // // //     }
// // // //   }

// // // //   Future<void> _loadWeatherData() async {
// // // //     setState(() {
// // // //       _isLoading = true;
// // // //       _error = null;
// // // //     });

// // // //     try {
// // // //       final weather = await _apiService.getCurrentWeather(_currentLocation);
// // // //       final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
      
// // // //       setState(() {
// // // //         _currentWeather = weather;
// // // //         _currentAirQuality = airQuality;
// // // //         _isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         _error = '데이터를 불러오는 중 오류가 발생했습니다: $e';
// // // //         _isLoading = false;
// // // //       });
// // // //     }
// // // //   }

// // // //   void _changeLocation(String locationCode) {
// // // //     setState(() {
// // // //       _currentLocation = locationCode;
// // // //     });
// // // //     AppConfig.setDefaultLocation(locationCode);
// // // //     _loadWeatherData();
// // // //   }

// // // //   void _logout() async {
// // // //     final success = await _apiService.logout();
// // // //     if (success) {
// // // //       Navigator.pushReplacementNamed(context, '/login');
// // // //     }
// // // //   }

// // // //   void _showLocationSelectionDialog() {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (BuildContext context) {
// // // //         return AlertDialog(
// // // //           title: const Text('지역 선택'),
// // // //           content: SizedBox(
// // // //             width: double.maxFinite,
// // // //             height: 400,
// // // //             child: ListView(
// // // //               shrinkWrap: true,
// // // //               children: [
// // // //                 _buildRegionCategory('수도권', [
// // // //                   '60,127', '55,124', '61,125', '62,120', '62,126', '61,131', '65,130'
// // // //                 ]),
// // // //                 _buildRegionCategory('강원권', [
// // // //                   '73,134', '84,135', '92,131', '73,127'
// // // //                 ]),
// // // //                 _buildRegionCategory('충청권', [
// // // //                   '63,89', '68,87', '68,107', '69,106', '67,100', '68,83', '76,88'
// // // //                 ]),
// // // //                 _buildRegionCategory('경상권', [
// // // //                   '89,90', '98,76', '91,77', '91,106', '80,70', '87,68', '81,75', '102,84'
// // // //                 ]),
// // // //                 _buildRegionCategory('전라권', [
// // // //                   '51,67', '59,74', '56,71', '58,64', '56,53', '63,56'
// // // //                 ]),
// // // //                 _buildRegionCategory('제주', [
// // // //                   '52,38'
// // // //                 ]),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   Widget _buildRegionCategory(String categoryName, List<String> locationCodes) {
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         Padding(
// // // //           padding: const EdgeInsets.symmetric(vertical: 8.0),
// // // //           child: Text(
// // // //             categoryName,
// // // //             style: const TextStyle(
// // // //               fontSize: 16,
// // // //               fontWeight: FontWeight.bold,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         Wrap(
// // // //           spacing: 8.0,
// // // //           runSpacing: 8.0,
// // // //           children: locationCodes.map((code) {
// // // //             final name = AppConfig.locationMap[code] ?? '알 수 없음';
// // // //             return ActionChip(
// // // //               label: Text(name),
// // // //               backgroundColor: _currentLocation == code 
// // // //                 ? Theme.of(context).primaryColor.withOpacity(0.3) 
// // // //                 : null,
// // // //               onPressed: () {
// // // //                 Navigator.pop(context);
// // // //                 _changeLocation(code);
// // // //               },
// // // //             );
// // // //           }).toList(),
// // // //         ),
// // // //         const Divider(),
// // // //       ],
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: GestureDetector(
// // // //           onTap: _showLocationSelectionDialog,
// // // //           child: Row(
// // // //             mainAxisSize: MainAxisSize.min,
// // // //             children: [
// // // //               Flexible(
// // // //                 child: FutureBuilder<String>(
// // // //                   future: _defaultLocationFuture,
// // // //                   builder: (context, snapshot) {
// // // //                     if (snapshot.hasData) {
// // // //                       final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';
// // // //                       return Text(
// // // //                         '$locationName 날씨',
// // // //                         overflow: TextOverflow.ellipsis,
// // // //                       );
// // // //                     }
// // // //                     return const Text('날씨 정보');
// // // //                   },
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 4),
// // // //               const Icon(Icons.arrow_drop_down, size: 20),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         centerTitle: true,
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.settings),
// // // //             onPressed: () async {
// // // //               final result = await Navigator.push(
// // // //                 context,
// // // //                 MaterialPageRoute(
// // // //                   builder: (context) => const SettingsScreen(),
// // // //                 ),
// // // //               );
              
// // // //               if (result != null && result is String) {
// // // //                 _changeLocation(result);
// // // //               }
// // // //             },
// // // //           ),
// // // //           IconButton(
// // // //             icon: const Icon(Icons.logout),
// // // //             onPressed: _logout,
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       body: _isLoading
// // // //           ? const Center(child: CircularProgressIndicator())
// // // //           : _error != null
// // // //               ? Center(
// // // //                   child: Column(
// // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // //                     children: [
// // // //                       Text(_error!, textAlign: TextAlign.center),
// // // //                       const SizedBox(height: 16),
// // // //                       ElevatedButton(
// // // //                         onPressed: _loadWeatherData,
// // // //                         child: const Text('다시 시도'),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 )
// // // //               : RefreshIndicator(
// // // //                   onRefresh: _loadWeatherData,
// // // //                   child: SingleChildScrollView(
// // // //                     physics: const AlwaysScrollableScrollPhysics(),
// // // //                     padding: const EdgeInsets.all(16.0),
// // // //                     child: Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.stretch,
// // // //                       children: [
// // // //                         if (_username != null)
// // // //                           Padding(
// // // //                             padding: const EdgeInsets.only(bottom: 16.0),
// // // //                             child: Card(
// // // //                               child: Padding(
// // // //                                 padding: const EdgeInsets.all(16.0),
// // // //                                 child: Row(
// // // //                                   children: [
// // // //                                     const Icon(Icons.person, size: 32),
// // // //                                     const SizedBox(width: 16),
// // // //                                     Text(
// // // //                                       '안녕하세요, $_username님!',
// // // //                                       style: const TextStyle(
// // // //                                         fontSize: 18,
// // // //                                         fontWeight: FontWeight.bold,
// // // //                                       ),
// // // //                                     ),
// // // //                                   ],
// // // //                                 ),
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         if (_currentWeather != null)
// // // //                           WeatherCard(
// // // //                             weather: _currentWeather!,
// // // //                             onTap: () {
// // // //                               Navigator.push(
// // // //                                 context,
// // // //                                 MaterialPageRoute(
// // // //                                   builder: (context) => WeatherDetailScreen(
// // // //                                     locationCode: _currentLocation,
// // // //                                   ),
// // // //                                 ),
// // // //                               );
// // // //                             },
// // // //                           ),
// // // //                         const SizedBox(height: 16),
// // // //                         if (_currentAirQuality != null)
// // // //                           AirQualityCard(
// // // //                             airQuality: _currentAirQuality!,
// // // //                           ),
// // // //                         const SizedBox(height: 16),
// // // //                         ElevatedButton.icon(
// // // //                           icon: const Icon(Icons.location_on),
// // // //                           label: const Text('지역 변경'),
// // // //                           onPressed: _showLocationSelectionDialog,
// // // //                           style: ElevatedButton.styleFrom(
// // // //                             padding: const EdgeInsets.symmetric(vertical: 12),
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //       floatingActionButton: FloatingActionButton(
// // // //         onPressed: _loadWeatherData,
// // // //         tooltip: '새로고침',
// // // //         child: const Icon(Icons.refresh),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_fastapi_auth/models/weather.dart';
// // // import 'package:flutter_fastapi_auth/models/air_quality.dart';
// // // import 'package:flutter_fastapi_auth/services/api_service.dart';
// // // import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
// // // import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
// // // import 'package:flutter_fastapi_auth/config.dart';
// // // import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';
// // // import 'package:flutter_fastapi_auth/screens/settings_screen.dart';

// // // class HomeScreen extends StatefulWidget {
// // //   const HomeScreen({Key? key}) : super(key: key);

// // //   @override
// // //   State<HomeScreen> createState() => _HomeScreenState();
// // // }

// // // class _HomeScreenState extends State<HomeScreen> {
// // //   final ApiService _apiService = ApiService();
// // //   late Future<String> _defaultLocationFuture;
// // //   late String _currentLocation;
// // //   String? _username;
// // //   Weather? _currentWeather;
// // //   AirQuality? _currentAirQuality;
// // //   bool _isLoading = true;
// // //   String? _error;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _defaultLocationFuture = AppConfig.getDefaultLocation();
// // //     _defaultLocationFuture.then((location) {
// // //       _currentLocation = location;
// // //       _loadWeatherData();
// // //     });
// // //     _loadUsername();
// // //   }

// // //   Future<void> _loadUsername() async {
// // //     final profile = await _apiService.getProfile();
// // //     if (profile != null) {
// // //       setState(() {
// // //         _username = profile['username'];
// // //       });
// // //     }
// // //   }

// // //   Future<void> _loadWeatherData() async {
// // //     setState(() {
// // //       _isLoading = true;
// // //       _error = null;
// // //     });

// // //     try {
// // //       final weather = await _apiService.getCurrentWeather(_currentLocation);
// // //       final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
// // //       setState(() {
// // //         _currentWeather = weather;
// // //         _currentAirQuality = airQuality;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() {
// // //         _error = '데이터를 불러오는 중 오류 발생: $e';
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }

// // //   void _changeLocation(String locationCode) {
// // //     setState(() {
// // //       _currentLocation = locationCode;
// // //     });
// // //     AppConfig.setDefaultLocation(locationCode);
// // //     _loadWeatherData();
// // //   }

// // //   void _logout() async {
// // //     final success = await _apiService.logout();
// // //     if (success) {
// // //       Navigator.pushReplacementNamed(context, '/login');
// // //     }
// // //   }

// // //   void _showLocationSelectionDialog() {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => AlertDialog(
// // //         title: const Text('지역 선택'),
// // //         content: SizedBox(
// // //           width: double.maxFinite,
// // //           height: 400,
// // //           child: ListView(
// // //             children: AppConfig.locationMap.entries.map((entry) {
// // //               return ListTile(
// // //                 title: Text(entry.value),
// // //                 onTap: () {
// // //                   Navigator.pop(context);
// // //                   _changeLocation(entry.key);
// // //                 },
// // //               );
// // //             }).toList(),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('$locationName 날씨'),
// // //         actions: [
// // //           IconButton(icon: const Icon(Icons.location_on), onPressed: _showLocationSelectionDialog),
// // //           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
// // //         ],
// // //       ),
// // //       body: _isLoading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : _error != null
// // //               ? Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Text(_error!, textAlign: TextAlign.center),
// // //                       const SizedBox(height: 16),
// // //                       ElevatedButton(
// // //                         onPressed: _loadWeatherData,
// // //                         child: const Text('다시 시도'),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 )
// // //               : RefreshIndicator(
// // //                   onRefresh: _loadWeatherData,
// // //                   child: ListView(
// // //                     padding: const EdgeInsets.all(16),
// // //                     children: [
// // //                       if (_username != null)
// // //                         Padding(
// // //                           padding: const EdgeInsets.only(bottom: 16),
// // //                           child: Text('안녕하세요, $_username님!', style: const TextStyle(fontSize: 18)),
// // //                         ),
// // //                       if (_currentWeather != null)
// // //                         WeatherCard(weather: _currentWeather!),
// // //                       const SizedBox(height: 16),
// // //                       if (_currentAirQuality != null)
// // //                         AirQualityCard(airQuality: _currentAirQuality!),
// // //                       const SizedBox(height: 16),
// // //                       ElevatedButton.icon(
// // //                         icon: const Icon(Icons.place),
// // //                         label: const Text('지역 변경'),
// // //                         onPressed: _showLocationSelectionDialog,
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //       floatingActionButton: FloatingActionButton(
// // //         onPressed: _loadWeatherData,
// // //         child: const Icon(Icons.refresh),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:http/http.dart' as http;

// // import 'package:flutter/material.dart';
// // import 'package:flutter_fastapi_auth/models/weather.dart';
// // import 'package:flutter_fastapi_auth/models/air_quality.dart';
// // import 'package:flutter_fastapi_auth/screens/air_quality_detail_screen.dart';
// // import 'package:flutter_fastapi_auth/services/api_service.dart';
// // import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
// // import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
// // import 'package:flutter_fastapi_auth/config.dart';
// // import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';


// // class HomeScreen extends StatefulWidget {
// //   const HomeScreen({Key? key}) : super(key: key);

// //   @override
// //   State<HomeScreen> createState() => _HomeScreenState();
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
// //   bool _isVentilationRecommended = false;
// //   String _ventilationMessage = "";
  
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

// //   // Future<void> _loadWeatherData() async {
// //   //   setState(() {
// //   //     _isLoading = true;
// //   //     _error = null;
// //   //   });

// //   //   try {
// //   //     final weather = await _apiService.getCurrentWeather(_currentLocation);
// //   //     final airQuality = await _apiService.getCurrentAirQuality(_currentLocation);
// //   //     setState(() {
// //   //       _currentWeather = weather;
// //   //       _currentAirQuality = airQuality;
// //   //       _isLoading = false;
// //   //     });
// //   //   } catch (e) {
// //   //     setState(() {
// //   //       _error = '데이터를 불러오는 중 오류 발생: $e';
// //   //       _isLoading = false;
// //   //     });
// //   //   }
// //   // }

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
// // void _showLocationSelectionDialog() {
// //   showGeneralDialog(
// //     context: context,
// //     barrierDismissible: true,
// //     barrierLabel: '지역 선택',
// //     transitionDuration: const Duration(milliseconds: 200),
// //     pageBuilder: (context, anim1, anim2) {
// //       final allLocations = AppConfig.locationMap.entries.toList();

// //       return SafeArea(
// //         child: Center(
// //           child: Material(
// //             borderRadius: BorderRadius.circular(20),
// //             color: Colors.white,
// //             child: Container(
// //               width: MediaQuery.of(context).size.width * 0.85,
// //               height: 400,
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 children: [
// //                   const Text(
// //                     '지역을 선택하세요',
// //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Expanded(
// //                     child: GridView.builder(
// //                       itemCount: allLocations.length,
// //                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                         crossAxisCount: 2,
// //                         mainAxisSpacing: 10,
// //                         crossAxisSpacing: 10,
// //                         childAspectRatio: 3,
// //                       ),
// //                       itemBuilder: (context, index) {
// //                         final entry = allLocations[index];
// //                         final isSelected = _currentLocation == entry.key;

// //                         return InkWell(
// //                           onTap: () {
// //                             Navigator.pop(context);
// //                             _changeLocation(entry.key);
// //                           },
// //                           borderRadius: BorderRadius.circular(12),
// //                           child: Container(
// //                             decoration: BoxDecoration(
// //                               color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(
// //                                 color: isSelected ? Colors.blue : Colors.transparent,
// //                                 width: 2,
// //                               ),
// //                             ),
// //                             padding: const EdgeInsets.symmetric(horizontal: 12),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Flexible(
// //                                   child: Text(
// //                                     entry.value,
// //                                     style: TextStyle(
// //                                       fontWeight: FontWeight.w600,
// //                                       color: isSelected ? Colors.blue : Colors.black,
// //                                     ),
// //                                     overflow: TextOverflow.ellipsis,
// //                                   ),
// //                                 ),
// //                                 if (isSelected)
// //                                   const Icon(Icons.favorite, color: Colors.blue, size: 18),
// //                               ],
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       );
// //     },
// //   );
// // }

// //   void _navigateToWeatherDetail() {
// //     if (_currentWeather != null) {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => WeatherDetailScreen(
// //             locationCode: _currentLocation,
// //             weather: _currentWeather!,
// //           ),
// //         ),
// //       );
// //     }
// //   }

// //   void _navigateToAirQualityDetail() {
// //     if (_currentAirQuality != null) {
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => AirQualityDetailScreen(
// //             locationCode: _currentLocation,
// //             airQuality: _currentAirQuality!,
// //           ),
// //         ),
// //       );
// //     }
// //   }
// // void _calculateVentilationStatus() {
// //   if (_currentWeather == null || _currentAirQuality == null) return;

// //   final now = DateTime.now();
// //   final hour = now.hour;

// //   bool badWeather = _currentWeather!.precipitation > 0.5 ||
// //       (_currentWeather!.skyCondition?.contains('비') == true) ||
// //       (_currentWeather!.skyCondition?.contains('눈') == true);

// //   bool extremeTemperature = _currentWeather!.temperature < 5 ||
// //       _currentWeather!.temperature > 30;

// //   bool highDust = _currentAirQuality!.pm10 > 80 ||
// //       _currentAirQuality!.pm25 > 35;

// //   bool isNightTime = hour < 6 || hour >= 22;

// //   _isVentilationRecommended = !badWeather && !extremeTemperature && !highDust && !isNightTime;

// //   if (isNightTime) {
// //     _ventilationMessage = "늦은 밤에는 환기를 삼가는 것이 좋아요.";
// //   } else if (badWeather) {
// //     _ventilationMessage = "비/눈이 오고 있어요. 창문을 닫아두세요.";
// //   } else if (extremeTemperature) {
// //     _ventilationMessage = _currentWeather!.temperature < 5
// //         ? "날씨가 춥습니다. 창문을 닫아두세요."
// //         : "날씨가 덥습니다. 에어컨 사용 시 창문을 닫아두세요.";
// //   } else if (highDust) {
// //     _ventilationMessage = "미세먼지가 나쁨 상태입니다. 창문을 닫아두세요.";
// //   } else {
// //     _ventilationMessage = "환기하기 좋은 날씨입니다. 창문을 열어 신선한 공기를 들이세요.";
// //   }
// // }

// // // 환기 버튼 액션 메서드
// // void _handleVentilationAction(bool openWindow) async {
// //   String message = openWindow
// //       ? "창문을 열어 환기를 시작합니다."
// //       : "창문을 닫습니다.";

// //   // 사용자에게 메시지 표시
// //   ScaffoldMessenger.of(context).showSnackBar(
// //     SnackBar(
// //       content: Text(message),
// //       duration: Duration(seconds: 2),
// //     ),
// //   );

// //   // 백엔드 서버의 API 주소
// // final uri = Uri.parse(
// //   openWindow
// //     ? "https://5912-113-198-180-200.ngrok-free.app/iot/send/open"
// //     : "https://5912-113-198-180-200.ngrok-free.app/iot/send/close"
// // );

// //   try {
// //     final response = await http.post(uri);
// //     if (response.statusCode == 200) {
// //       print("명령 전송 성공: ${response.body}");
// //     } else {
// //       print("명령 전송 실패: ${response.statusCode}, ${response.body}");
// //     }
// //   } catch (e) {
// //     print("네트워크 오류: $e");
// //   }
// // }

// //   // // 환기 버튼 액션 메서드
// //   // void _handleVentilationAction(bool openWindow) {
// //   //   String message = openWindow 
// //   //       ? "창문을 열어 환기를 시작합니다." 
// //   //       : "창문을 닫습니다.";
    
// //   //   ScaffoldMessenger.of(context).showSnackBar(
// //   //     SnackBar(
// //   //       content: Text(message),
// //   //       duration: Duration(seconds: 2),
// //   //     ),
// //   //   );
    
// //   //   // 여기에 실제 스마트홈 연동 로직을 추가할 수 있습니다.
// //   //   // 예: _apiService.controlWindow(_currentLocation, openWindow);
// //   // }

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
        
// //         // 환기 권장 여부 계산 추가
// //         _calculateVentilationStatus();
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _error = '데이터를 불러오는 중 오류 발생: $e';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('$locationName 날씨'),
// //         actions: [
// //           IconButton(icon: const Icon(Icons.location_on), onPressed: _showLocationSelectionDialog),
// //           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
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
// //                   child: ListView(
// //                     padding: const EdgeInsets.all(16),
// //                     children: [
// //                       if (_username != null)
// //                         Padding(
// //                           padding: const EdgeInsets.only(bottom: 16),
// //                           child: Card(
// //                             child: Padding(
// //                               padding: const EdgeInsets.all(16.0),
// //                               child: Row(
// //                                 children: [
// //                                   const Icon(Icons.person, size: 32),
// //                                   const SizedBox(width: 16),
// //                                   Text(
// //                                     '안녕하세요, $_username님!',
// //                                     style: const TextStyle(
// //                                       fontSize: 18,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       if (_currentWeather != null)
// //                         InkWell(
// //                           onTap: _navigateToWeatherDetail,
// //                           child: WeatherCard(weather: _currentWeather!),
// //                         ),
// //                       const SizedBox(height: 16),
// //                       if (_currentAirQuality != null)
// //                         InkWell(
// //                           onTap: _navigateToAirQualityDetail,
// //                           child: AirQualityCard(airQuality: _currentAirQuality!),
// //                         ),
// //                       const SizedBox(height: 16),
                      
// //                       // 환기 상태 카드 추가
// //                       if (_currentWeather != null && _currentAirQuality != null)
// //                         Card(
// //                           elevation: 3,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                             side: BorderSide(
// //                               color: _isVentilationRecommended ? Colors.green : Colors.red,
// //                               width: 2,
// //                             ),
// //                           ),
// //                           child: Padding(
// //                             padding: const EdgeInsets.all(16.0),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Row(
// //                                   children: [
// //                                     Icon(
// //                                       _isVentilationRecommended ? Icons.window : Icons.window_outlined,
// //                                       color: _isVentilationRecommended ? Colors.green : Colors.red,
// //                                       size: 28,
// //                                     ),
// //                                     const SizedBox(width: 12),
// //                                     Expanded(
// //                                       child: Text(
// //                                         _isVentilationRecommended ? '환기 권장' : '창문 닫기 권장',
// //                                         style: const TextStyle(
// //                                           fontSize: 18,
// //                                           fontWeight: FontWeight.bold,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 const SizedBox(height: 12),
                                
// //                                 // 환기 조건 요약
// //                                 Container(
// //                                   padding: const EdgeInsets.all(8),
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.grey.shade100,
// //                                     borderRadius: BorderRadius.circular(8),
// //                                   ),
// //                                   child: Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       Row(
// //                                         // children: [
// //                                         //   // Icon(Icons.thermostat, 
// //                                         //   //     color: _currentWeather!.temperature > 30 || _currentWeather!.temperature < 5 
// //                                         //   //         ? Colors.red : Colors.green, 
// //                                         //   //     size: 16),
// //                                         //   const SizedBox(width: 4),
// //                                         //   Text('온도: ${_currentWeather!.temperature.toStringAsFixed(1)}°C'),
// //                                         // ],
// //                                       ),
// //                                       // const SizedBox(height: 4),
// //                                       // Row(
// //                                       //   children: [
// //                                       //     Icon(Icons.air, 
// //                                       //         color: _currentAirQuality!.pm10 > 80 ? Colors.red : Colors.green, 
// //                                       //         size: 16),
// //                                       //     const SizedBox(width: 4),
// //                                       //     Text('미세먼지: ${_currentAirQuality!.pm10.toStringAsFixed(0)}μg/m³'),
// //                                       //   ],
// //                                       // ),
// //                                       // const SizedBox(height: 4),
// //                                       // Row(
// //                                       //   children: [
// //                                       //     Icon(Icons.water_drop, 
// //                                       //         color: _currentWeather!.precipitation > 0.5 ? Colors.red : Colors.green, 
// //                                       //         size: 16),
// //                                       //     const SizedBox(width: 4),
// //                                       //     Text('강수량: ${_currentWeather!.precipitation.toStringAsFixed(1)}mm'),
// //                                       //   ],
// //                                       // ),
// //                                     ],
// //                                   ),
// //                                 ),
                                
// //                                 const SizedBox(height: 12),
// //                                 Text(
// //                                   _ventilationMessage,
// //                                   style: TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w500,
// //                                     color: _isVentilationRecommended ? Colors.green.shade700 : Colors.red.shade700,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 16),
                                
// //                                 // 창문 열기/닫기 버튼
// //                                 Row(
// //                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                                   children: [
// //                                     Expanded(
// //                                       child: ElevatedButton.icon(
// //                                         onPressed: () => _handleVentilationAction(true),
// //                                         icon: const Icon(Icons.window),
// //                                         label: const Text('창문 열기'),
// //                                         style: ElevatedButton.styleFrom(
// //                                           backgroundColor: _isVentilationRecommended ? Colors.green : Colors.grey,
// //                                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     const SizedBox(width: 12),
// //                                     Expanded(
// //                                       child: ElevatedButton.icon(
// //                                         onPressed: () => _handleVentilationAction(false),
// //                                         icon: const Icon(Icons.window_outlined),
// //                                         label: const Text('창문 닫기'),
// //                                         style: ElevatedButton.styleFrom(
// //                                           backgroundColor: !_isVentilationRecommended ? Colors.red : Colors.grey,
// //                                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
                      
// //                       const SizedBox(height: 16),
// //                       // ElevatedButton.icon(
// //                       //   icon: const Icon(Icons.place),
// //                       //   label: const Text('지역 변경'),
// //                       //   onPressed: _showLocationSelectionDialog,
// //                       // ),
// //                     ],
// //                   ),
// //                 ),
// //    floatingActionButton: FloatingActionButton(
// //  onPressed: () async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('새로고침 중입니다...')),
// //     );

// //     final success = await _apiService.triggerManualFetch();
    
// //     if (success) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('데이터 수집을 요청했습니다')),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('데이터 수집 요청 실패')),
// //       );
// //     }

// //     // UI 갱신도 필요하면 수동으로 날씨 다시 로드
// //     _loadWeatherData();
// //   },
// //   tooltip: '새로고침',
// //   child: const Icon(Icons.refresh),
// // ),

// //     );
// //   }
// // }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('$locationName 날씨'),
// // //         actions: [
// // //           IconButton(icon: const Icon(Icons.location_on), onPressed: _showLocationSelectionDialog),
// // //           IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
// // //         ],
// // //       ),
// // //       body: _isLoading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : _error != null
// // //               ? Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Text(_error!, textAlign: TextAlign.center),
// // //                       const SizedBox(height: 16),
// // //                       ElevatedButton(
// // //                         onPressed: _loadWeatherData,
// // //                         child: const Text('다시 시도'),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 )
// // //               : RefreshIndicator(
// // //                   onRefresh: _loadWeatherData,
// // //                   child: ListView(
// // //                     padding: const EdgeInsets.all(16),
// // //                     children: [
// // //                       if (_username != null)
// // //                         Padding(
// // //                           padding: const EdgeInsets.only(bottom: 16),
// // //                           child: Card(
// // //                             child: Padding(
// // //                               padding: const EdgeInsets.all(16.0),
// // //                               child: Row(
// // //                                 children: [
// // //                                   const Icon(Icons.person, size: 32),
// // //                                   const SizedBox(width: 16),
// // //                                   Text(
// // //                                     '안녕하세요, $_username님!',
// // //                                     style: const TextStyle(
// // //                                       fontSize: 18,
// // //                                       fontWeight: FontWeight.bold,
// // //                                     ),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       if (_currentWeather != null)
// // //                         InkWell(
// // //                           onTap: _navigateToWeatherDetail,
// // //                           child: WeatherCard(weather: _currentWeather!),
// // //                         ),
// // //                       const SizedBox(height: 16),
// // //                       if (_currentAirQuality != null)
// // //                         InkWell(
// // //                           onTap: _navigateToAirQualityDetail,
// // //                           child: AirQualityCard(airQuality: _currentAirQuality!),
// // //                         ),
// // //                       const SizedBox(height: 16),
// // //                       ElevatedButton.icon(
// // //                         icon: const Icon(Icons.place),
// // //                         label: const Text('지역 변경'),
// // //                         onPressed: _showLocationSelectionDialog,
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //       floatingActionButton: FloatingActionButton(
// // //         onPressed: _loadWeatherData,
// // //         tooltip: '새로고침',
// // //         child: const Icon(Icons.refresh),
// // //       ),
// // //     );
// // //   }
// // // }

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_fastapi_auth/models/weather.dart';
// import 'package:flutter_fastapi_auth/models/air_quality.dart';
// import 'package:flutter_fastapi_auth/screens/air_quality_detail_screen.dart';
// import 'package:flutter_fastapi_auth/services/api_service.dart';
// import 'package:flutter_fastapi_auth/widgets/weather_card.dart';
// import 'package:flutter_fastapi_auth/widgets/air_quality_card.dart';
// import 'package:flutter_fastapi_auth/config.dart';
// import 'package:flutter_fastapi_auth/screens/weather_detail_screen.dart';

// // 센서 데이터 모델
// class SensorData {
//   final String deviceId;
//   final int? pir;
//   final int? light;
//   final int? gas;
//   final DateTime timestamp;

//   SensorData({
//     required this.deviceId,
//     this.pir,
//     this.light,
//     this.gas,
//     required this.timestamp,
//   });

//   factory SensorData.fromJson(Map<String, dynamic> json) {
//     return SensorData(
//       deviceId: json['device_id'] ?? '',
//       pir: json['pir'],
//       light: json['light'],
//       gas: json['gas'],
//       timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
//     );
//   }
// }

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
//   bool _isVentilationRecommended = false;
//   String _ventilationMessage = "";
  
//   // 센서 관련 변수들
//   SensorData? _lastSensorData;
//   Timer? _sensorCheckTimer;
//   bool _isMonitoringActive = true;
  
//   // 센서 임계값 설정
//   static const int LIGHT_THRESHOLD_DARK = 200;  // 어두워지는 기준
//   static const int LIGHT_THRESHOLD_BRIGHT = 500; // 밝아지는 기준
//   static const int GAS_THRESHOLD_HIGH = 500;    // 가스 농도 높음 기준
//   static const int GAS_THRESHOLD_NORMAL = 300;  // 가스 농도 정상 기준
  
//   @override
//   void initState() {
//     super.initState();
//     _defaultLocationFuture = AppConfig.getDefaultLocation();
//     _defaultLocationFuture.then((location) {
//       _currentLocation = location;
//       _loadWeatherData();
//     });
//     _loadUsername();
//     _startSensorMonitoring();
//   }

//   @override
//   void dispose() {
//     _sensorCheckTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadUsername() async {
//     final profile = await _apiService.getProfile();
//     if (profile != null) {
//       setState(() {
//         _username = profile['username'];
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

//   // 센서 모니터링 시작
//   void _startSensorMonitoring() {
//     _sensorCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (_isMonitoringActive) {
//         _checkSensorData();
//       }
//     });
//   }

//   // 센서 데이터 확인 및 팝업 트리거
//   Future<void> _checkSensorData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://5912-113-198-180-200.ngrok-free.app/iot/data/latest'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final newSensorData = SensorData.fromJson(data);
        
//         if (_lastSensorData != null) {
//           _analyzeSensorChanges(_lastSensorData!, newSensorData);
//         }
        
//         setState(() {
//           _lastSensorData = newSensorData;
//         });
//       }
//     } catch (e) {
//       print('센서 데이터 확인 오류: $e');
//     }
//   }

//   // 센서 변화 분석 및 팝업 결정
//   void _analyzeSensorChanges(SensorData old, SensorData current) {
//     String? popupReason;
//     bool? shouldOpenWindow;

//     // 1. 움직임 감지 시 (PIR 센서)
//     if (current.pir == 1 && old.pir != 1) {
//       // 사람이 감지되었을 때는 실내 공기질 확인
//       if (current.gas != null && current.gas! > GAS_THRESHOLD_HIGH) {
//         popupReason = "움직임이 감지되었고 실내 공기질이 나쁩니다.";
//         shouldOpenWindow = true;
//       }
//     }

//     // 2. 조도 변화 감지
//     if (old.light != null && current.light != null) {
//       // 어두워졌을 때 (밤이 되었을 때)
//       if (old.light! > LIGHT_THRESHOLD_BRIGHT && current.light! < LIGHT_THRESHOLD_DARK) {
//         popupReason = "어두워졌습니다. 실내 환기를 위해 창문을 닫는 것을 권장합니다.";
//         shouldOpenWindow = false;
//       }
//       // 밝아졌을 때 (아침이 되었을 때)
//       else if (old.light! < LIGHT_THRESHOLD_DARK && current.light! > LIGHT_THRESHOLD_BRIGHT) {
//         if (current.gas != null && current.gas! < GAS_THRESHOLD_NORMAL) {
//           popupReason = "밝아졌고 공기질이 좋습니다. 신선한 공기를 위해 창문을 여는 것을 권장합니다.";
//           shouldOpenWindow = true;
//         }
//       }
//     }

//     // 3. 가스 농도 급격한 변화
//     if (old.gas != null && current.gas != null) {
//       // 가스 농도가 급격히 높아졌을 때
//       if (old.gas! < GAS_THRESHOLD_NORMAL && current.gas! > GAS_THRESHOLD_HIGH) {
//         popupReason = "실내 공기질이 급격히 나빠졌습니다. 즉시 환기가 필요합니다.";
//         shouldOpenWindow = true;
//       }
//       // 가스 농도가 정상으로 돌아왔을 때 (외부 공기질이 나쁘면 닫기 권장)
//       else if (old.gas! > GAS_THRESHOLD_HIGH && current.gas! < GAS_THRESHOLD_NORMAL) {
//         if (_currentAirQuality != null && 
//             (_currentAirQuality!.pm10 > 80 || _currentAirQuality!.pm25 > 35)) {
//           popupReason = "실내 공기질이 개선되었지만 외부 미세먼지가 나쁩니다. 창문을 닫는 것을 권장합니다.";
//           shouldOpenWindow = false;
//         }
//       }
//     }

//     // 팝업 표시
//     if (popupReason != null && shouldOpenWindow != null) {
//       _showSensorBasedPopup(popupReason, shouldOpenWindow);
//     }
//   }

//   // 센서 기반 팝업 표시
//   void _showSensorBasedPopup(String reason, bool shouldOpen) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Row(
//             children: [
//               Icon(
//                 shouldOpen ? Icons.window : Icons.window_outlined,
//                 color: shouldOpen ? Colors.green : Colors.orange,
//                 size: 28,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   shouldOpen ? '창문 열기 권장' : '창문 닫기 권장',
//                   style: TextStyle(
//                     color: shouldOpen ? Colors.green : Colors.orange,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 reason,
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 16),
//               if (_lastSensorData != null) ...[
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '현재 센서 상태:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       if (_lastSensorData!.light != null)
//                         Text('🔆 조도: ${_lastSensorData!.light}'),
//                       if (_lastSensorData!.gas != null)
//                         Text('💨 공기질: ${_lastSensorData!.gas}'),
//                       if (_lastSensorData!.pir != null)
//                         Text('👤 움직임: ${_lastSensorData!.pir == 1 ? "감지됨" : "없음"}'),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('나중에'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _handleVentilationAction(shouldOpen);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: shouldOpen ? Colors.green : Colors.orange,
//               ),
//               child: Text(shouldOpen ? '창문 열기' : '창문 닫기'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showLocationSelectionDialog() {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: '지역 선택',
//       transitionDuration: const Duration(milliseconds: 200),
//       pageBuilder: (context, anim1, anim2) {
//         final allLocations = AppConfig.locationMap.entries.toList();

//         return SafeArea(
//           child: Center(
//             child: Material(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.85,
//                 height: 400,
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     const Text(
//                       '지역을 선택하세요',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 16),
//                     Expanded(
//                       child: GridView.builder(
//                         itemCount: allLocations.length,
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 10,
//                           crossAxisSpacing: 10,
//                           childAspectRatio: 3,
//                         ),
//                         itemBuilder: (context, index) {
//                           final entry = allLocations[index];
//                           final isSelected = _currentLocation == entry.key;

//                           return InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                               _changeLocation(entry.key);
//                             },
//                             borderRadius: BorderRadius.circular(12),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isSelected ? Colors.blue : Colors.transparent,
//                                   width: 2,
//                                 ),
//                               ),
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Flexible(
//                                     child: Text(
//                                       entry.value,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         color: isSelected ? Colors.blue : Colors.black,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   if (isSelected)
//                                     const Icon(Icons.favorite, color: Colors.blue, size: 18),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _navigateToWeatherDetail() {
//     if (_currentWeather != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => WeatherDetailScreen(
//             locationCode: _currentLocation,
//             weather: _currentWeather!,
//           ),
//         ),
//       );
//     }
//   }

//   void _navigateToAirQualityDetail() {
//     if (_currentAirQuality != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AirQualityDetailScreen(
//             locationCode: _currentLocation,
//             airQuality: _currentAirQuality!,
//           ),
//         ),
//       );
//     }
//   }

//   void _calculateVentilationStatus() {
//     if (_currentWeather == null || _currentAirQuality == null) return;

//     final now = DateTime.now();
//     final hour = now.hour;

//     bool badWeather = _currentWeather!.precipitation > 0.5 ||
//         (_currentWeather!.skyCondition?.contains('비') == true) ||
//         (_currentWeather!.skyCondition?.contains('눈') == true);

//     bool extremeTemperature = _currentWeather!.temperature < 5 ||
//         _currentWeather!.temperature > 30;

//     bool highDust = _currentAirQuality!.pm10 > 80 ||
//         _currentAirQuality!.pm25 > 35;

//     bool isNightTime = hour < 6 || hour >= 22;

//     _isVentilationRecommended = !badWeather && !extremeTemperature && !highDust && !isNightTime;

//     if (isNightTime) {
//       _ventilationMessage = "늦은 밤에는 환기를 삼가는 것이 좋아요.";
//     } else if (badWeather) {
//       _ventilationMessage = "비/눈이 오고 있어요. 창문을 닫아두세요.";
//     } else if (extremeTemperature) {
//       _ventilationMessage = _currentWeather!.temperature < 5
//           ? "날씨가 춥습니다. 창문을 닫아두세요."
//           : "날씨가 덥습니다. 에어컨 사용 시 창문을 닫아두세요.";
//     } else if (highDust) {
//       _ventilationMessage = "미세먼지가 나쁨 상태입니다. 창문을 닫아두세요.";
//     } else {
//       _ventilationMessage = "환기하기 좋은 날씨입니다. 창문을 열어 신선한 공기를 들이세요.";
//     }
//   }

//   // 환기 버튼 액션 메서드
//   void _handleVentilationAction(bool openWindow) async {
//     String message = openWindow
//         ? "창문을 열어 환기를 시작합니다."
//         : "창문을 닫습니다.";

//     // 사용자에게 메시지 표시
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );

//     // 백엔드 서버의 API 주소
//     final uri = Uri.parse(
//       openWindow
//         ? "https://5912-113-198-180-200.ngrok-free.app/iot/send/open"
//         : "https://5912-113-198-180-200.ngrok-free.app/iot/send/close"
//     );

//     try {
//       final response = await http.post(uri);
//       if (response.statusCode == 200) {
//         print("명령 전송 성공: ${response.body}");
//       } else {
//         print("명령 전송 실패: ${response.statusCode}, ${response.body}");
//       }
//     } catch (e) {
//       print("네트워크 오류: $e");
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
        
//         // 환기 권장 여부 계산 추가
//         _calculateVentilationStatus();
//       });
//     } catch (e) {
//       setState(() {
//         _error = '데이터를 불러오는 중 오류 발생: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locationName = AppConfig.locationMap[_currentLocation] ?? '알 수 없는 위치';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$locationName 날씨'),
//         actions: [
//           // 센서 모니터링 토글 버튼
//           IconButton(
//             icon: Icon(
//               _isMonitoringActive ? Icons.sensors : Icons.sensors_off,
//               color: _isMonitoringActive ? Colors.green : Colors.grey,
//             ),
//             onPressed: () {
//               setState(() {
//                 _isMonitoringActive = !_isMonitoringActive;
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     _isMonitoringActive ? '센서 모니터링이 활성화되었습니다.' : '센서 모니터링이 비활성화되었습니다.',
//                   ),
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             },
//           ),
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
                      
//                       // 센서 상태 카드 추가
//                       if (_lastSensorData != null)
//                         Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       _isMonitoringActive ? Icons.sensors : Icons.sensors_off,
//                                       color: _isMonitoringActive ? Colors.green : Colors.grey,
//                                       size: 24,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     const Text(
//                                       '실시간 센서 상태',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                   children: [
//                                     if (_lastSensorData!.light != null)
//                                       Column(
//                                         children: [
//                                           const Icon(Icons.lightbulb, color: Colors.amber),
//                                           const SizedBox(height: 4),
//                                           Text('조도'),
//                                           Text('${_lastSensorData!.light}', 
//                                                style: const TextStyle(fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                     if (_lastSensorData!.gas != null)
//                                       Column(
//                                         children: [
//                                           Icon(Icons.air, 
//                                                color: _lastSensorData!.gas! > GAS_THRESHOLD_HIGH 
//                                                    ? Colors.red : Colors.green),
//                                           const SizedBox(height: 4),
//                                           Text('공기질'),
//                                           Text('${_lastSensorData!.gas}', 
//                                                style: const TextStyle(fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                     if (_lastSensorData!.pir != null)
//                                       Column(
//                                         children: [
//                                           Icon(Icons.person, 
//                                                color: _lastSensorData!.pir == 1 
//                                                    ? Colors.blue : Colors.grey),
//                                           const SizedBox(height: 4),
//                                           Text('움직임'),
//                                           Text(_lastSensorData!.pir == 1 ? '감지' : '없음', 
//                                                style: const TextStyle(fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       const SizedBox(height: 16),
                      
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
                      
//                       // 환기 상태 카드
//                       if (_currentWeather != null && _currentAirQuality != null)
//                         Card(
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             side: BorderSide(
//                               color: _isVentilationRecommended ? Colors.green : Colors.red,
//                               width: 2,
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       _isVentilationRecommended ? Icons.window : Icons.window_outlined,
//                                       color: _isVentilationRecommended ? Colors.green : Colors.red,
//                                       size: 28,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Text(
//                                         _isVentilationRecommended ? '환기 권장' : '창문 닫기 권장',
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
                                
//                                 Text(
//                                   _ventilationMessage,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: _isVentilationRecommended ? Colors.green.shade700 : Colors.red.shade700,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
                                
//                                 // 창문 열기/닫기 버튼
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     Expanded(
//                                       child: ElevatedButton.icon(
//                                         onPressed: () => _handleVentilationAction(true),
//                                         icon: const Icon(Icons.window),
//                                         label: const Text('창문 열기'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: _isVentilationRecommended ? Colors.green : Colors.grey,
//                                           padding: const EdgeInsets.symmetric(vertical: 12),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: ElevatedButton.icon(
//                                         onPressed: () => _handleVentilationAction(false),
//                                         icon: const Icon(Icons.window_outlined),
//                                         label: const Text('창문 닫기'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: !_isVentilationRecommended ? Colors.red : Colors.grey,
//                                           padding: const EdgeInsets.symmetric(vertical: 12),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
                      
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           setState(() {
//             _isLoading = true;
//           });

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('새로고침 중입니다...')),
//           );

//           final success = await _apiService.triggerManualFetch();
          
//           if (success) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('데이터 수집을 요청했습니다')),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('데이터 수집 요청 실패')),
//             );
//           }

//           // UI 갱신도 필요하면 수동으로 날씨 다시 로드
//           _loadWeatherData();
//         },
//         tooltip: '새로고침',
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

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
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
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
  bool _useDummySensorData = true;
  // HomeScreen State 클래스 내에 선언
  bool _dummyPopupShown = false;       // 더미 데이터 팝업 표시 여부
  bool _realPopupShown = false;        // 실제 데이터 팝업 표시 여부

  // 센서 관련 변수들
  SensorData? _lastSensorData;
  SensorData? _previousSensorData;
  Timer? _sensorCheckTimer;
  bool _isMonitoringActive = true;
  List<SensorData> _sensorHistory = [];
  
  // 센서 임계값 설정 (더 세밀하게 조정)
  static const int LIGHT_THRESHOLD_DARK = 150;    // 어두워지는 기준 (낮아짐)
  static const int LIGHT_THRESHOLD_BRIGHT = 400;  // 밝아지는 기준 (높아짐)
  static const int LIGHT_CHANGE_THRESHOLD = 100;  // 급격한 조도 변화 기준
  
  static const int GAS_THRESHOLD_HIGH = 300;      // 가스 농도 높음 기준 (낮춤)
  static const int GAS_THRESHOLD_NORMAL = 100;    // 가스 농도 정상 기준
  static const int GAS_CHANGE_THRESHOLD = 50;     // 급격한 가스 변화 기준
  
  @override
  void initState() {
    super.initState();
    _defaultLocationFuture = AppConfig.getDefaultLocation();
    _defaultLocationFuture.then((location) {
      _currentLocation = location;
      _loadWeatherData();
    });
    _loadUsername();
    _startSensorMonitoring();
  }

  @override
  void dispose() {
    _sensorCheckTimer?.cancel();
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
void _triggerDummySensorPopup() {
  if (_dummyPopupShown) return;      // 이미 한 번 띄운 뒤에는 무시
  _dummyPopupShown = true;

  final dummyOld = SensorData(
    deviceId: 'dummy',
    pir: 0,
    light: LIGHT_THRESHOLD_BRIGHT + 50,
    gas: GAS_THRESHOLD_NORMAL - 20,
    timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
  );
  final dummyCurrent = SensorData(
    deviceId: 'dummy',
    pir: 1,
    light: LIGHT_THRESHOLD_DARK - 50,
    gas: GAS_THRESHOLD_HIGH + 100,
    timestamp: DateTime.now(),
  );
  final analysis = _analyzeSensorChanges(dummyOld, dummyCurrent);
  if (analysis != null) {
    _showSmartVentilationPopup(analysis);
  }
}

// // HomeScreen State 클래스 내에 추가
// void _triggerDummySensorPopup() {
//   final dummyOld = SensorData(
//     deviceId: 'dummy',
//     pir: 0,
//     light: LIGHT_THRESHOLD_BRIGHT + 50, // 밝은 상태
//     gas: GAS_THRESHOLD_NORMAL - 20,     // 정상 공기질
//     timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
//   );
//   final dummyCurrent = SensorData(
//     deviceId: 'dummy',
//     pir: 1,
//     light: LIGHT_THRESHOLD_DARK - 50,    // 어두워진 상태
//     gas: GAS_THRESHOLD_HIGH + 100,       // 위험 수준 가스 농도
//     timestamp: DateTime.now(),
//   );
//   final analysis = _analyzeSensorChanges(dummyOld, dummyCurrent);
//   if (analysis != null) {
//     _showSmartVentilationPopup(analysis);
//   }
// }

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
        Uri.parse('https://5912-113-198-180-200.ngrok-free.app/iot/data/latest'),
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
        final analysis = _analyzeSensorChanges(_previousSensorData!, newSensorData);
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
      if (_useDummySensorData) _triggerDummySensorPopup();
    }
  } catch (e) {
    print('센서 데이터 확인 오류: $e');
    if (_useDummySensorData) _triggerDummySensorPopup();
  }
}
  // 개선된 센서 변화 분석
  SensorAnalysis? _analyzeSensorChanges(SensorData old, SensorData current) {
    // 1. 급격한 가스 농도 증가 (최우선)
    if (old.gas != null && current.gas != null) {
      int gasChange = current.gas! - old.gas!;
      
      if (gasChange > GAS_CHANGE_THRESHOLD && current.gas! > GAS_THRESHOLD_HIGH) {
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason: "🚨 실내 공기질이 급격히 악화되었습니다!\n가스 농도: ${old.gas} → ${current.gas}\n즉시 환기가 필요합니다.",
          urgency: "high",
          color: Colors.red,
        );
      }
      
      // 가스 농도가 높은 상태에서 움직임 감지
      if ((current.pir ?? 0) == 1 && current.gas! > GAS_THRESHOLD_HIGH) {
        return SensorAnalysis(
          shouldOpenWindow: true,
          reason: "👤 움직임이 감지되었고 실내 공기질이 나쁩니다.\n가스 농도: ${current.gas}\n환기를 권장합니다.",
          urgency: "high",
          color: Colors.orange,
        );
      }
    }

    // 2. 조도 변화 기반 시간대 분석
    if (old.light != null && current.light != null) {
      int lightChange = current.light! - old.light!;
      
      // 급격히 어두워짐 (저녁/밤)
      if (lightChange < -LIGHT_CHANGE_THRESHOLD && current.light! < LIGHT_THRESHOLD_DARK) {
        // 외부 공기질이 나쁘거나 가스 농도가 정상이면 창문 닫기 권장
        if (_shouldCloseWindowAtNight()) {
          return SensorAnalysis(
            shouldOpenWindow: false,
            reason: "🌙 어두워졌습니다.\n${_getCloseWindowReason()}\n창문을 닫는 것을 권장합니다.",
            urgency: "medium",
            color: Colors.blue,
          );
        }
      }
      
      // 급격히 밝아짐 (아침)
      else if (lightChange > LIGHT_CHANGE_THRESHOLD && current.light! > LIGHT_THRESHOLD_BRIGHT) {
        if (_shouldOpenWindowInMorning(current)) {
          return SensorAnalysis(
            shouldOpenWindow: true,
            reason: "☀️ 밝아졌습니다!\n실내 공기질이 양호하고 환기하기 좋은 시간입니다.\n신선한 공기를 위해 창문을 여는 것을 권장합니다.",
            urgency: "low",
            color: Colors.green,
          );
        }
      }
    }

    // 3. 공기질 개선 후 외부 상황 고려
    if (old.gas != null && current.gas != null) {
      if (old.gas! > GAS_THRESHOLD_HIGH && current.gas! < GAS_THRESHOLD_NORMAL) {
        // 실내 공기질은 좋아졌지만 외부 미세먼지가 나쁘면 닫기 권장
        if (_currentAirQuality != null && 
            (_currentAirQuality!.pm10 > 80 || _currentAirQuality!.pm25 > 35)) {
          return SensorAnalysis(
            shouldOpenWindow: false,
            reason: "✅ 실내 공기질이 개선되었지만\n외부 미세먼지가 나쁩니다.\n창문을 닫아두는 것을 권장합니다.",
            urgency: "medium",
            color: Colors.amber,
          );
        }
      }
    }

    return null; // 특별한 변화 없음
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
      } else if (_currentAirQuality!.pm10 > 50 || _currentAirQuality!.pm25 > 25) {
        return "외부 미세먼지가 보통 수준입니다.";
      }
    }
    return "밤시간 환기를 위해";
  }

  bool _shouldOpenWindowInMorning(SensorData current) {
    // 실내 공기질이 양호하고 외부 공기질도 괜찮을 때만
    bool indoorAirGood = current.gas == null || current.gas! < GAS_THRESHOLD_NORMAL;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: analysis.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  analysis.shouldOpenWindow ? Icons.window : Icons.window_outlined,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('기온: ${_currentWeather!.temperature}°C'),
                      Text('미세먼지: ${_currentAirQuality!.pm10.toStringAsFixed(0)}㎍/㎥ (${_getAirQualityStatus(_currentAirQuality!.pm10)})'),
                      Text('초미세먼지: ${_currentAirQuality!.pm25.toStringAsFixed(0)}㎍/㎥'),
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
              icon: Icon(analysis.shouldOpenWindow ? Icons.window : Icons.window_outlined),
              label: Text(analysis.shouldOpenWindow ? '창문 열기' : '창문 닫기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: analysis.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSensorStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_lastSensorData!.light != null)
          _buildSensorItem(
            icon: Icons.lightbulb,
            label: '조도',
            value: _lastSensorData!.light.toString(),
            color: _getLightColor(_lastSensorData!.light!),
          ),
        if (_lastSensorData!.gas != null)
          _buildSensorItem(
            icon: Icons.air,
            label: '공기질',
            value: _lastSensorData!.gas.toString(),
            color: _getGasColor(_lastSensorData!.gas!),
          ),
        if (_lastSensorData!.pir != null)
          _buildSensorItem(
            icon: Icons.person,
            label: '움직임',
            value: _lastSensorData!.pir == 1 ? '감지' : '없음',
            color: _lastSensorData!.pir == 1 ? Colors.blue : Colors.grey,
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
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Color _getLightColor(int light) {
    if (light < LIGHT_THRESHOLD_DARK) return Colors.indigo;
    if (light > LIGHT_THRESHOLD_BRIGHT) return Colors.amber;
    return Colors.orange;
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

  // 환기 버튼 액션 메서드
  void _handleVentilationAction(bool openWindow) async {
    String message = openWindow
        ? "창문을 열어 환기를 시작합니다."
        : "창문을 닫습니다.";

    // 사용자에게 메시지 표시
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

    // 백엔드 서버의 API 주소
    final uri = Uri.parse(
      openWindow
        ? "https://5912-113-198-180-200.ngrok-free.app/iot/send/open"
        : "https://5912-113-198-180-200.ngrok-free.app/iot/send/close"
    );

    try {
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("✅ 명령 전송 성공: ${responseData['message']}");
        
        // 성공 시 추가 피드백
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ ${responseData['message']}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print("❌ 명령 전송 실패: ${response.statusCode}, ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ 명령 전송에 실패했습니다."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ 네트워크 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ 네트워크 연결을 확인해주세요."),
          backgroundColor: Colors.red,
        ),
      );
    }
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

      if (_isMonitoringActive) {
        // 다시 켤 때 더미 팝업 플래그 초기화
        _dummyPopupShown = false;
        // 더미 팝업 띄우기
        if (_useDummySensorData) {
          _triggerDummySensorPopup();
        }
      }
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
              _isMonitoringActive ? '스마트 모니터링 활성화됨' : '스마트 모니터링 비활성화됨',
            ),
          ],
        ),
        backgroundColor: _isMonitoringActive ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  },
),

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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                                  child: const Icon(Icons.person, size: 24, color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (_lastSensorData != null)
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
                                  _isMonitoringActive ? Colors.green.shade50 : Colors.grey.shade50,
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
                                          color: _isMonitoringActive ? Colors.green : Colors.grey,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _isMonitoringActive ? Icons.sensors : Icons.sensors_off,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '실시간 센서 모니터링',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '마지막 업데이트: ${_formatTime(_lastSensorData!.timestamp)}',
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
                                  if (_sensorHistory.length >= 3) ...[
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
                          child: AirQualityCard(airQuality: _currentAirQuality!),
                        ),
                      const SizedBox(height: 16),
                      
                      // 스마트 환기 권장 카드 (개선됨)
                      if (_currentWeather != null && _currentAirQuality != null)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _isVentilationRecommended ? Colors.green : Colors.orange,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  (_isVentilationRecommended ? Colors.green : Colors.orange).withOpacity(0.1),
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
                                          color: _isVentilationRecommended ? Colors.green : Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _isVentilationRecommended ? Icons.window : Icons.window_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _isVentilationRecommended ? '✅ 환기 권장' : '⚠️ 창문 닫기 권장',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _isVentilationRecommended ? Colors.green.shade700 : Colors.orange.shade700,
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
                                      border: Border.all(color: Colors.grey.shade200),
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
                                          onPressed: () => _handleVentilationAction(true),
                                          icon: const Icon(Icons.window, size: 20),
                                          label: const Text('창문 열기', style: TextStyle(fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isVentilationRecommended ? Colors.green : Colors.grey.shade400,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: _isVentilationRecommended ? 3 : 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _handleVentilationAction(false),
                                          icon: const Icon(Icons.window_outlined, size: 20),
                                          label: const Text('창문 닫기', style: TextStyle(fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: !_isVentilationRecommended ? Colors.orange : Colors.grey.shade400,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: !_isVentilationRecommended ? 3 : 1,
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
    if (_sensorHistory.length < 3) return const SizedBox();
    
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
          _buildTrendItem('조도', _sensorHistory.take(5).map((e) => e.light ?? 0).toList()),
          _buildTrendItem('공기질', _sensorHistory.take(5).map((e) => e.gas ?? 0).toList()),
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
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: values.take(5).map((value) {
            final normalizedHeight = range > 0 ? ((value - minValue) / range * 20 + 5).toDouble() : 15.0;
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