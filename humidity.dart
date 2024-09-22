import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Humidity extends StatefulWidget {
  const Humidity({super.key});

  @override
  _HumidityState createState() => _HumidityState();
}

class _HumidityState extends State<Humidity> {
  double hv = 0.0; // Percentage value for the indicator
  double hc = 0.0; // Humidity value
  late Timer timer; // Timer for periodic data fetching

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch humidity on widget load

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
          hc = double.parse(jsonData['Humidity'].toString());
          hv = (hc / 100).clamp(0.0, 1.0); // Clamp value between 0.0 and 1.0
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
    String hvd = '${hc.toStringAsFixed(2)} %'; // Display value

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
                    Image.asset('lib/uicons/humidity.png',
                        height: displayWidth * .1),
                    Text(
                      "Humidity",
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
                  percent: hv, // Dynamic humidity value as percentage
                  center: Text(
                    hvd, // Display humidity value
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
