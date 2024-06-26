import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('yyyy-MM-dd – hh:mm:ss a').format(_currentTime);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // Outer container is transparent
        ),
        child: Padding(
          padding: const EdgeInsets.all(0), // Remove inner padding
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
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(top: 15, bottom: 25),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0), // Adjust padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.red[700]),
                          SizedBox(width: 8),
                          Text("Date and Time: ",
                              style: TextStyle(fontSize: 16)),
                          Text(formattedDate,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.cloud, color: Colors.red[700]),
                          SizedBox(width: 8),
                          Text("Weather Conditions: ",
                              style: TextStyle(fontSize: 16)),
                          Text("RED ALERT",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.warning, color: Colors.red),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 15.0), // Adjust padding
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(0),
                      children: [
                        _buildWeatherCard("Temperature", "40%"),
                        _buildWeatherCard("Wave Speed", "60%"),
                        _buildWeatherCard("Humidity", "27%"),
                        _buildWeatherCard("Rain Intensity", "60%"),
                      ],
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
    return Card(
      elevation: 0, // Remove the shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
