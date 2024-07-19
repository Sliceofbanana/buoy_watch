import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SosNotificationHandler {
  final BuildContext context;

  SosNotificationHandler(this.context) {
    _listenForSosPress();
  }

  void _listenForSosPress() {
    print('Listening for SOS press...');

    DatabaseReference sosRef =
        FirebaseDatabase.instance.ref().child('ButtonStatus');
    sosRef.onValue.listen((event) {
      print('Event received from Firebase');
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        String location = data['location'];
        String dateTime = data['dateTime'];
        print('=============================================');
        print('Location: $location');
        print('DateTime: $dateTime');
        print('=============================================');
        _showSosNotification(location, dateTime);
      } else {
        print('No data found');
      }
    });
  }

  void _showSosNotification(String location, String dateTime) {
    print('Showing SOS notification...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            decoration: const BoxDecoration(
              color: Color(0xc4161616),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xfffdfdfd),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Someone is in need of help!",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Location: $location",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Date and time: $dateTime",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 84,
                  height: 76,
                  color: Colors.red[700],
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        _handleHelpOnTheWay(location, dateTime);
                      },
                      child: const Text(
                        'Help is on the way',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleHelpOnTheWay(String location, String dateTime) {
    print('Help is on the way for location: $location at $dateTime');

    // Simulate checking the input data
    assert(location.isNotEmpty, 'Location should not be empty');
    assert(dateTime.isNotEmpty, 'DateTime should not be empty');

    DatabaseReference sosRef =
        FirebaseDatabase.instance.ref().child('ButtonStatus');
    sosRef.set({
      'location': location,
      'dateTime': dateTime,
      'status': 'Help is on the way',
    }).then((_) {
      print('=============================================');
      print('Firebase updated successfully.');
      print('=============================================');
      Navigator.of(context).pop();
    }).catchError((error) {
      print('=============================================');
      print('Failed to update Firebase: $error');
      print('=============================================');
    });
  }
}
