import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and then navigate to the MapScreen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/buoy.png',
              width: 98, // Adjust the width
              height: 98, // Adjust the height
              fit: BoxFit.cover, // Adjust the fit
              alignment: Alignment.center, // Adjust the alignment
              color: Colors.red, // Apply a color filter
              colorBlendMode: BlendMode.modulate, // Apply a color blend mode
            ),
            SizedBox(height: 20),
            Text(
              'BUOY WATCH',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
