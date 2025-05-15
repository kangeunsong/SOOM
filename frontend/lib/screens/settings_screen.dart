import 'package:flutter/material.dart';
import 'package:flutter_fastapi_auth/config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<String> _defaultLocationFuture;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _defaultLocationFuture = AppConfig.getDefaultLocation();
    _defaultLocationFuture.then((location) {
      setState(() {
        _selectedLocation = location;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: FutureBuilder<String>(
        future: _defaultLocationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '기본 위치 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    ...AppConfig.locationMap.entries.map((entry) => RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: _selectedLocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    )).toList(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null
                            ? () {
                                Navigator.pop(context, _selectedLocation);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('저장'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '앱 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('날씨 & 미세먼지 앱 v1.0.0'),
                      const SizedBox(height: 8),
                      const Text('공공데이터포털의 API를 활용하여 날씨 및 미세먼지 정보를 제공합니다.'),
                      const SizedBox(height: 16),
                      const Text('© 2025 날씨앱 개발팀'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}