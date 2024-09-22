import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class nitro extends StatefulWidget {
  const nitro({super.key});

  @override
  _NitrogenState createState() => _NitrogenState();
}

class _NitrogenState extends State<nitro> {
  double nitrogenValue = 0.0; // Nitrogen value to be fetched
  late Timer timer; // Timer for periodic data fetching

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch nitrogen data on widget load

    // Set up a timer to refresh data every 10 seconds
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
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
      'NPK.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          nitrogenValue = double.parse(jsonData['Nitrogen'].toString());
        });
      } else {
        print(
            'Failed to load nitrogen data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error loading nitrogen data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    String nitrogenDisplay =
        '${nitrogenValue.toInt()} mg/kg'; // Display value as integer

    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        width: displayWidth * .89,
        height: displayWidth * .20,
        decoration: BoxDecoration(
          color: const Color(0xffffffff).withOpacity(.55),
          border: Border.all(
            color: const Color(0xff013e3e),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'lib/uicons/nitrogen.png',
                  height: displayWidth * .1,
                ),
                Text(
                  "  Nitrogen",
                  style: GoogleFonts.nunito(
                    color: const Color(0xff013e3e),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              nitrogenDisplay, // Display the nitrogen value
              style: GoogleFonts.quicksand(
                color: const Color(0xff013e3e),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
