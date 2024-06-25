import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PanelWidget extends StatelessWidget {
  final ScrollController controller;

  const PanelWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Date and Time: "),
              Text(formattedDate, style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text("Weather Conditions: "),
              Text("RED ALERT",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Icon(Icons.warning, color: Colors.red),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildWeatherCard("Temperature", "40%"),
                _buildWeatherCard("Wave Speed", "60%"),
                _buildWeatherCard("Humidity", "27%"),
                _buildWeatherCard("Rain Intensity", "60%"),
              ],
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text(
                "EMERGENCY ALERT",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
