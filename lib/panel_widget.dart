import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final FirebaseDatabase database;
  final Future<List<Map<String, dynamic>>> forecastData;
  final Map<String, dynamic> buoyData;

  const PanelWidget({
    Key? key,
    required this.controller,
    required this.database,
    required this.forecastData,
    required this.buoyData,
  }) : super(key: key);

  @override
  _PanelWidgetState createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late Timer _timer;
  late DateTime _currentTime;
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true; // Added loading indicator

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Fetch initial data and set up listener for changes
    _fetchWeatherData();
    _listenToWeatherDataChanges();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    print('Fetching weather data...');
    try {
      DatabaseEvent event =
          await widget.database.ref().child('WeatherData').once();
      setState(() {
        _weatherData = Map<String, dynamic>.from(event.snapshot.value as Map);
        _isLoading = false; // Set loading to false when data is fetched
      });

      // Test code: Print the fetched data
      print('=============================================');
      print('Weather Data fetched successfully.');
      print('Fetched Data: $_weatherData');
      print('Temperature: ${_weatherData!['Temperature']}');
      print('Humidity: ${_weatherData!['Humidity']}');
      print('=============================================');
    } catch (e) {
      // Handle any errors here
      setState(() {
        _isLoading = false; // Set loading to false even if there's an error
      });
      print('Error fetching weather data: $e');
    }
  }

  void _listenToWeatherDataChanges() {
    print('Listening for weather data changes...');
    widget.database.ref().child('WeatherData').onValue.listen((event) {
      setState(() {
        _weatherData = Map<String, dynamic>.from(event.snapshot.value as Map);
      });

      // Test code: Print the fetched data
      print('=============================================');
      print('Weather Data changed.');
      print('New Data: $_weatherData');
      print('Temperature: ${_weatherData!['Temperature']}');
      print('Humidity: ${_weatherData!['Humidity']}');
      print('=============================================');
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM/dd/yy').format(_currentTime);
    final formattedTime = DateFormat('hh:mm a').format(_currentTime);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingHorizontal = screenWidth * 0.05;
    final paddingVertical = screenHeight * 0.01;
    final cardPadding = screenWidth * 0.025;
    final cardFontSize = screenWidth * 0.045;
    final iconSize = screenWidth * 0.06;

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: screenWidth * 0.15,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(top: 15, bottom: 25),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.red[700], size: iconSize),
                          const SizedBox(width: 8),
                          Text("Date: ",
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
                          Icon(Icons.access_time,
                              color: Colors.red[700], size: iconSize),
                          const SizedBox(width: 8),
                          Text("Time: ",
                              style: TextStyle(fontSize: cardFontSize)),
                          Expanded(
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                  fontSize: cardFontSize, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: paddingVertical * 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: cardPadding, vertical: paddingVertical),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _weatherData == null
                            ? const Center(child: Text("No data available"))
                            : GridView.count(
                                crossAxisCount: 2,
                                padding: const EdgeInsets.all(0),
                                children: [
                                  _buildWeatherCard("Temperature",
                                      "${_weatherData!['Temperature']} °C"),
                                  _buildWeatherCard("Humidity",
                                      "${_weatherData!['Humidity']} %"),
                                  _buildWeatherCard("Pressure",
                                      "${_weatherData!['Pressure']} Pa"),
                                  _buildWeatherCard("Brightness",
                                      "${_weatherData!['Light']} lux"),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 5),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 10),
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
