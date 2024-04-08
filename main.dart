import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Temp & Humidity App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TempHumidityPage(),
    );
  }
}

class TempHumidityPage extends StatefulWidget {
  const TempHumidityPage({Key? key}) : super(key: key);

  @override
  _TempHumidityPageState createState() => _TempHumidityPageState();
}

class _TempHumidityPageState extends State<TempHumidityPage> {
  double? temperature;
  double? humidity;

  @override
  void initState() {
    super.initState();
    _loadDHTData();
  }

  Future<void> _loadDHTData() async {
    final url = Uri.https(
      'verminn-dde78-default-rtdb.firebaseio.com',
      'AppUsers.json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Fetched data: $jsonData');
        setState(() {
          temperature = double.tryParse(jsonData['Temperature'].toString());
          humidity = double.tryParse(jsonData['Humidity'].toString());
        });
      } else {
        print(
            'Failed to load DHT data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error loading DHT data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature & Humidity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Temperature: ${temperature?.toStringAsFixed(1) ?? 'halu'}°C',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Humidity: ${humidity?.toStringAsFixed(1) ?? 'halu'}%',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
