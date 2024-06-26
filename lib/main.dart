import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'panel_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(11.083018, 123.931450),
    zoom: 16.5,
  );

  late GoogleMapController _googleMapController;
  final PanelController _panelController = PanelController();
  final ValueNotifier<double> _fabPositionNotifier =
      ValueNotifier<double>(16.0);
  final ValueNotifier<bool> _isPanelOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isDrawerOpenNotifier = ValueNotifier<bool>(false);
  final ScrollController _scrollController = ScrollController();
  final Set<Marker> _markers = {};

  @override
  void dispose() {
    _googleMapController.dispose();
    _fabPositionNotifier.dispose();
    _isPanelOpenNotifier.dispose();
    _isDrawerOpenNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> generateForecastData() {
    final currentHour = DateTime.now().hour;
    final List<Map<String, dynamic>> forecastData = [];
    final conditions = ["Sunny", "Cloudy", "Rainy"];
    final icons = [Icons.wb_sunny, Icons.wb_cloudy, Icons.grain];

    for (int i = 0; i < 6; i++) {
      final forecastHour = (currentHour + i) % 24;
      final conditionIndex = forecastHour % 3;
      forecastData.add({
        "time": TimeOfDay(hour: forecastHour, minute: 0).format(context),
        "hour": forecastHour,
        "temp": "${30 + i}°C",
        "condition": conditions[conditionIndex],
        "icon": icons[conditionIndex]
      });
    }

    return forecastData;
  }

  void centerScrollToCurrentHour() {
    final forecastData = generateForecastData();
    final currentHour = DateTime.now().hour;
    final index =
        forecastData.indexWhere((data) => data['hour'] == currentHour);
    if (index != -1) {
      _scrollController.animateTo(
        index *
            116.0, // Adjust this value based on the width of each forecast item
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _createCustomMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/Rectangle22.png', 100);
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('customMarker'),
          position: LatLng(11.083018, 123.931450),
          icon: BitmapDescriptor.fromBytes(markerIcon),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => centerScrollToCurrentHour());
    _createCustomMarker(); // Add custom marker when the map is initialized
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fabHeightClosed = screenHeight - 735;
    final fabHeightOpened = screenHeight - 290;
    final forecastData = generateForecastData();
    final currentHour = DateTime.now().hour;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[700],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                _isDrawerOpenNotifier.value = false;
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                _isDrawerOpenNotifier.value = false;
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: _markers,
          ),
          SlidingUpPanel(
            controller: _panelController,
            panelBuilder: (controller) => PanelWidget(controller: controller),
            backdropEnabled: true,
            backdropColor: Colors.transparent,
            color: Colors.transparent,
            minHeight: 125,
            maxHeight: screenHeight * 0.64,
            margin: EdgeInsets.only(
                bottom: 98), // Adjust margin to make space for the button
            onPanelSlide: (position) {
              _fabPositionNotifier.value = fabHeightClosed -
                  ((fabHeightClosed - fabHeightOpened) * position);
              _isPanelOpenNotifier.value = position > 0.1;
            },
            onPanelOpened: () => _isPanelOpenNotifier.value = true,
            onPanelClosed: () => _isPanelOpenNotifier.value = false,
          ),
          Positioned(
            left: 16,
            top: 23,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                      _isDrawerOpenNotifier.value = true;
                    },
                  );
                },
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isPanelOpenNotifier,
            builder: (context, isPanelOpen, child) {
              return Positioned(
                left: 16,
                right: 16,
                top: 75,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: isPanelOpen ? 0.0 : 1.0,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hourly Weather Forecast',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Row(
                            children: forecastData.map((data) {
                              final isCurrentHour = data['hour'] == currentHour;
                              return Container(
                                margin: EdgeInsets.only(right: 16.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: isCurrentHour
                                      ? Colors.red[700]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      data['icon'] as IconData,
                                      color: isCurrentHour
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    Text(
                                      data['time'] as String,
                                      style: TextStyle(
                                        color: isCurrentHour
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      data['temp'] as String,
                                      style: TextStyle(
                                        color: isCurrentHour
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      data['condition'] as String,
                                      style: TextStyle(
                                        color: isCurrentHour
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "EMERGENCY ALERT",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: _fabPositionNotifier,
            builder: (context, value, child) {
              return Positioned(
                right: 16,
                bottom:
                    value + 80, // Adjust position to account for button height
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.black,
                  onPressed: () => _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(_initialCameraPosition),
                  ),
                  child: const Icon(Icons.center_focus_strong),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
