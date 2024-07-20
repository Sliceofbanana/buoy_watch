import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class SosNotificationHandler {
  final BuildContext context;
  final bool useManualSos;

  SosNotificationHandler(this.context, {this.useManualSos = false}) {
    if (useManualSos) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerManualSos();
      });
    } else {
      _listenForSosPress();
    }
  }

  void _listenForSosPress() {
    print('Listening for SOS press...');

    DatabaseReference statusRef =
        FirebaseDatabase.instance.ref().child('ButtonStatus');
    statusRef.onValue.listen((event) {
      print('Event received from Firebase');
      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? statusData =
            event.snapshot.value as Map<dynamic, dynamic>?;
        print('ButtonStatus value: $statusData');

        if (statusData != null && statusData.containsKey('Status')) {
          var status = statusData['Status'];
          print('Status value: $status of type ${status.runtimeType}');

          if (status == 1) {
            print('Status is 1, calling _fetchBuoyDataAndShowNotification');
            _fetchBuoyDataAndShowNotification();
          } else {
            print('ButtonStatus is not 1');
          }
        } else {
          print('ButtonStatus is not a valid map or does not contain "Status"');
        }
      } else {
        print('No data found');
      }
    }).onError((error) {
      print('Error listening for SOS press: $error');
    });
  }

  void _fetchBuoyDataAndShowNotification() async {
    print('=============================================');
    print('Fetching BuoyData...');
    print('=============================================');

    try {
      DatabaseReference buoyDataRef =
          FirebaseDatabase.instance.ref().child('BuoyData');
      DataSnapshot snapshot = await buoyDataRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('BuoyData received: $data');

        double latitude = data['latitude']?.toDouble() ?? 0.0;
        double longitude = data['longitude']?.toDouble() ?? 0.0;
        String dateTime = data['dateTime'] ?? '';

        print(
            'Parsed values - Latitude: $latitude, Longitude: $longitude, DateTime: $dateTime');

        if (latitude != 0.0 && longitude != 0.0 && dateTime.isNotEmpty) {
          print('Valid BuoyData found, calling _showSosNotification...');
          _showSosNotification(latitude, longitude, dateTime);
        } else {
          print('=============================================');
          print('No valid data found');
          print('=============================================');
        }
      } else {
        print('=============================================');
        print('No BuoyData found');
        print('=============================================');
      }
    } catch (e) {
      print('Error fetching BuoyData: $e');
    }
  }

  void _triggerManualSos() {
    print('=============================================');
    print('Manually triggering SOS notification...');
    print('=============================================');
    double latitude = 37.7749; // Mock data for testing
    double longitude = -122.4194; // Mock data for testing
    String dateTime = DateTime.now().toString();
    _showSosNotification(latitude, longitude, dateTime);
  }

  void _showSosNotification(
      double latitude, double longitude, String dateTime) {
    print('=============================================');
    print('Showing SOS notification...');
    print('Latitude: $latitude, Longitude: $longitude, DateTime: $dateTime');
    print('Calling showDialog now');
    print('=============================================');

    // Formatting date and time
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    final String formattedDate = DateFormat('MM/dd/yy').format(parsedDateTime);
    final String formattedTime = DateFormat('hh:mm a').format(parsedDateTime);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 75,
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "SOMEONE IS IN NEED OF HELP!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Latitude: $latitude",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Longitude: $longitude",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Date: $formattedDate",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Time: $formattedTime",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  onPressed: () {
                    _handleHelpOnTheWay(latitude, longitude, dateTime);
                  },
                  child: const Text(
                    'HELP IS ON THE WAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleHelpOnTheWay(double latitude, double longitude, String dateTime) {
    print(
        'Help is on the way for location: Latitude: $latitude, Longitude: $longitude at $dateTime');

    // Simulate checking the input data
    assert(latitude != 0.0, 'Latitude should not be zero');
    assert(longitude != 0.0, 'Longitude should not be zero');
    assert(dateTime.isNotEmpty, 'DateTime should not be empty');

    DatabaseReference statusRef =
        FirebaseDatabase.instance.ref().child('ButtonStatus').child('Status');

    // Reset Status to zero
    statusRef.set(0).then((_) {
      print('=============================================');
      print('Firebase updated successfully.');
      print('=============================================');
      Navigator.of(context)
          .pop(); // Close the prompt when the button is pressed
    }).catchError((error) {
      print('=============================================');
      print('Failed to update Firebase: $error');
      print('=============================================');
      Navigator.of(context).pop(); // Close the prompt even if update fails
    });
  }
}
