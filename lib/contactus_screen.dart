import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

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
              decoration: BoxDecoration(
                color: Colors.red[700],
              ),
            ),
            const SizedBox(
              width: 29.25,
              height: 19,
            ),
            Image.asset(
              "assets/Group 21.png",
              width: 128,
              height: 134,
            ),
            Container(
              width: 383,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white, // Set background color to white
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "For Concerns or to report an issue:",
                    style: TextStyle(
                      fontSize: 16, // Increased font size
                      fontWeight: FontWeight.bold, // Made text bold
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.red[700]),
                      const SizedBox(width: 8.0),
                      const Text(
                        "genesis.esdrilonjr@gmail.com",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Padding(
                    padding: EdgeInsets.only(left: 32.0), // Align other emails
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "nathanearlmaglasang@gmail.com",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          "giljoshuaasingua@gmail.com",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
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
