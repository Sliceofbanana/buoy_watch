import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;

  const PanelWidget({Key? key, required this.controller}) : super(key: key);

  @override
  _PanelWidgetState createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('WeatherData');
    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM/dd/yy – hh:mm a').format(_currentTime);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingHorizontal = screenWidth * 0.05;
    final paddingVertical = screenHeight * 0.01;
    final cardPadding = screenWidth * 0.025;
    final cardFontSize = screenWidth * 0.045;
    final iconSize = screenWidth * 0.06;

    return Padding(
      padding: EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // Outer container is transparent
        ),
        child: Padding(
          padding: EdgeInsets.all(0), // Remove inner padding
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Inner panel background
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Indicator
                Center(
                  child: Container(
                    width: screenWidth * 0.15,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.only(top: 15, bottom: 25),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal), // Adjust padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.red[700], size: iconSize),
                          SizedBox(width: 8),
                          Text("Date and Time: ",
                              style: TextStyle(fontSize: cardFontSize)),
                          Expanded(
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                  fontSize: cardFontSize, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: paddingVertical),
                      Row(
                        children: [
                          Icon(Icons.cloud,
                              color: Colors.red[700], size: iconSize),
                          SizedBox(width: 8),
                          Text("Weather Conditions: ",
                              style: TextStyle(fontSize: cardFontSize)),
                          Text(
                            "RED ALERT",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: cardFontSize,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.warning,
                              color: Colors.red, size: iconSize),
                        ],
                      ),
                      SizedBox(height: paddingVertical * 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: cardPadding,
                        vertical: paddingVertical), // Adjust padding
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: fetchWeatherData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No data available'));
                        } else {
                          final weatherData = snapshot.data!;
                          return GridView.count(
                            crossAxisCount: 2,
                            padding: EdgeInsets.all(0),
                            children: [
                              _buildWeatherCard(
                                  "Temperature",
                                  weatherData['Temperature'].toString() +
                                      " °C"),
                              _buildWeatherCard("Humidity",
                                  weatherData['Humidity'].toString() + " %"),
                              _buildWeatherCard("Pressure",
                                  weatherData['Pressure'].toString() + " Pa"),
                              _buildWeatherCard("Light",
                                  weatherData['Light'].toString() + " lux"),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5), // Additional padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(String title, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardFontSize = screenWidth * 0.045;
    final valueFontSize = screenWidth * 0.06;

    return Card(
      elevation: 0, // Remove the shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: valueFontSize, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: cardFontSize, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
