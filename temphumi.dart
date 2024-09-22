import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class temphumi extends StatefulWidget {
  const temphumi({super.key});

  @override
  _TempHumiState createState() => _TempHumiState();
}

class _TempHumiState extends State<temphumi> {
  double temperatureValue = 0.0; // Temperature value to be fetched
  double humidityValue = 0.0; // Humidity value to be fetched
  late Timer timer; // Timer for periodic data fetching

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data on widget load

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
          temperatureValue = double.parse(jsonData['Temperature'].toString());
          humidityValue = double.parse(jsonData['Humidity'].toString());
        });
      } else {
        print(
            'Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    String temperatureDisplay =
        '${temperatureValue.toInt()} °C'; // Display temperature
    String humidityDisplay = '${humidityValue.toInt()} %'; // Display humidity

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            // Temperature
            padding: const EdgeInsets.all(10),
            width: displayWidth * .43,
            height: displayWidth * .47,
            decoration: BoxDecoration(
              color: const Color(0xffffffff).withOpacity(.55),
              border: Border.all(
                color: const Color(0xff013e3e),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'lib/uicons/temp.png',
                      height: displayWidth * .1,
                    ),
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
                  radius: displayWidth * .13,
                  lineWidth: displayWidth * .04,
                  progressColor: const Color(0xff77e5b6),
                  startAngle: 230,
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: (temperatureValue / 100)
                      .clamp(0.0, 1.0), // Percentage for temp
                  center: Text(
                    temperatureDisplay, // Display temperature
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff013e3e),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // Humidity
            padding: const EdgeInsets.all(10),
            width: displayWidth * .43,
            height: displayWidth * .47,
            decoration: BoxDecoration(
              color: const Color(0xffffffff).withOpacity(.55),
              border: Border.all(
                color: const Color(0xff013e3e),
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'lib/uicons/humidity.png',
                      height: displayWidth * .1,
                    ),
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
                  radius: displayWidth * .13,
                  lineWidth: displayWidth * .04,
                  progressColor: const Color(0xff77e5b6),
                  startAngle: 230,
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: (humidityValue / 100)
                      .clamp(0.0, 1.0), // Percentage for humidity
                  center: Text(
                    humidityDisplay, // Display humidity
                    style: const TextStyle(
                      fontSize: 20,
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
