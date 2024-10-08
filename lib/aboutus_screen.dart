import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back arrow to white
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(color: Colors.red[700]),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Image.asset(
                    "assets/Ellipse 6.png",
                    width: 109,
                    height: 109,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Asingua, Gil Joshua",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    "BS in Computer Engineering\nSan Remegio, Cebu",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    "assets/Ellipse 7.png",
                    width: 109,
                    height: 109,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Esdrilon Jr, Genesis",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    "BS in Computer Engineering\nBalamban, Cebu",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    "assets/Ellipse 8.png",
                    width: 109,
                    height: 109,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Maglasang, Nathan Earl",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    "BS in Computer Engineering\nBogo City, Cebu",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
