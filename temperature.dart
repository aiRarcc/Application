import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Temperature extends StatefulWidget {
  const Temperature({super.key});

  @override
  _TemperatureState createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature> {
  double tv = 0.0; // Percentage value for the indicator
  double tc = 0.0; // Celsius value
  late Timer timer; // Timer for periodic data fetching

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch temperature on widget load

    // Set up a timer to refresh data every 10 seconds
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchData() async {
    final url = Uri.https(
      'verminn-dde78-default-rtdb.firebaseio.com',
      'DHT_11.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          tc = double.parse(jsonData['Temperature'].toString());
          tv = (tc / 100).clamp(0.0, 1.0); // Clamp value between 0.0 and 1.0
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
    double displayWidth = MediaQuery.of(context).size.width;
    String tvd = '${tc.toStringAsFixed(2)} °C'; // Display value

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: displayWidth * .89,
            height: displayWidth * .70,
            decoration: BoxDecoration(
              color: const Color(0xffffffff).withOpacity(.55),
              border: Border.all(color: const Color(0xff013e3e)),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Image.asset('lib/uicons/temp.png',
                        height: displayWidth * .1),
                    Text(
                      "Temperature",
                      style: GoogleFonts.nunito(
                          color: const Color(0xff013e3e),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                CircularPercentIndicator(
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 1000,
                  backgroundColor: Colors.transparent,
                  radius: displayWidth * .25,
                  lineWidth: displayWidth * .04,
                  progressColor: const Color(0xff77e5b6),
                  startAngle: 230,
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: tv, // Dynamic temperature value as percentage
                  center: Text(
                    tvd, // Display Celsius temperature
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff013e3e),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
