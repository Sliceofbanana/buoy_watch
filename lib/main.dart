import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart'
    show rootBundle, SystemChrome, SystemUiOverlayStyle;
import 'dart:typed_data';
import 'panel_widget.dart';
import 'aboutus_screen.dart';
import 'contactus_screen.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'sos_notification.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late CameraPosition _initialCameraPosition;
  late GoogleMapController _googleMapController;
  final PanelController _panelController = PanelController();
  final ValueNotifier<double> _fabPositionNotifier =
      ValueNotifier<double>(233.0);
  final ValueNotifier<bool> _isPanelOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isDrawerOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isInfoWindowOpenNotifier =
      ValueNotifier<bool>(false);
  final ScrollController _scrollController = ScrollController();
  final Set<Marker> _markers = {};
  Timer? _timer;
  late Interpreter _interpreter;
  late SosNotificationHandler _sosNotificationHandler;
  bool isModelLoaded = false;
  List<Map<String, dynamic>> forecastList = [];

  Map<String, dynamic> buoyData = {
    "AngleX": 0,
    "AngleY": 0,
    "altitude": 0,
    "latitude": 0,
    "longitude": 0,
  };

  @override
  void dispose() {
    _googleMapController.dispose();
    _fabPositionNotifier.dispose();
    _isPanelOpenNotifier.dispose();
    _isDrawerOpenNotifier.dispose();
    _isInfoWindowOpenNotifier.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => centerScrollToCurrentHour());
    _listenToWeatherDataChanges();
    _startHourlyUpdateTimer();
    _fetchBuoyData();
    _fetchInitialCameraPosition();
    _startBuoyUpdateListener();
    loadModel().then((_) {
      // After loading the model, you can now safely call prediction functions.
      if (isModelLoaded) {
        generateForecastData(context);
      }
    });
    _sosNotificationHandler = SosNotificationHandler(context);
    centerScrollToCurrentHour();
  }

  Future<void> loadModel() async {
    try {
      print("Loading model...");
      _interpreter = await Interpreter.fromAsset('assets/model2.tflite');
      isModelLoaded = true;
      print("Model loaded successfully");
    } catch (e) {
      print("Failed to load model: $e");
      isModelLoaded = false;
    }
  }

  void _listenToWeatherDataChanges() {
    print('Listening for weather data changes...');
    FirebaseDatabase.instance.ref().child('WeatherData').onValue.listen(
      (event) async {
        Map<String, dynamic>? weatherData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        // Test code: Print the fetched data
        print('=============================================');
        print('Weather Data updated.');
        print('New Data: $weatherData');
        print('Temperature: ${weatherData['Temperature']}');
        print('Humidity: ${weatherData['Humidity']}');
        print('=============================================');

        // Validate the data
        if (weatherData.containsKey('Temperature') &&
            weatherData.containsKey('Humidity') &&
            weatherData.containsKey('DewPoint') &&
            weatherData.containsKey('Pressure') &&
            weatherData.containsKey('Hour') &&
            weatherData.containsKey('Day') &&
            weatherData.containsKey('Month')) {
          List<Map<String, dynamic>> data = [weatherData];

          List<List<double>> inputData = prepareInputData(data);

          // Print prepared input data for debugging
          print("Prepared input data: $inputData");

          // Ensure input data is not empty before predicting weather
          if (inputData.isNotEmpty) {
            if (!isModelLoaded) {
              await loadModel();
            }
            Map<String, dynamic> modelOutput = await predictWeather(inputData);
            print("Model output (floats): ${modelOutput['floats']}");
            print("Model output (integers): ${modelOutput['integers']}");

            // Generate the forecast list and update the UI
            List<Map<String, dynamic>> newForecastList =
                await generateForecastData(context);
            setState(() {
              forecastList = newForecastList;
            });
          } else {
            print("No valid input data available for prediction.");
          }
        } else {
          print("Incomplete weather data received: $weatherData");
        }
      },
      onError: (error) {
        print("Error getting data: $error");
      },
    );
  }

  Future<Map<String, dynamic>> predictWeather(List<List<double>> data) async {
    print("Entered predictWeather function.");
    if (!isModelLoaded) {
      print("Model not loaded yet. Returning empty predictions.");
      return {
        'floats': [],
        'integers': [],
      };
    }
    print("Model is loaded, proceeding with predictions.");
    try {
      List<double> inputList = data.expand((e) => e).toList();
      Float32List input = Float32List.fromList(inputList);
      if (input.isEmpty) {
        throw Exception("Invalid input data: Input is null or empty.");
      }
      List<double> floatPredictions = [];
      List<int> integerPredictions = [];
      for (int i = 0; i < 6; i++) {
        List<List<double>> outputBuffer =
            List.generate(1, (_) => List.filled(1, 0.0));
        print("Running inference for hour $i");
        print("Input to model: $input");
        try {
          _interpreter.run(input, outputBuffer);
          print("Model output buffer for hour $i: $outputBuffer");
        } catch (e) {
          print("Error during model run for hour $i: $e");
          continue; // Skip this iteration on error
        }
        double prediction = outputBuffer[0][0];
        print("Model output buffer (floats) for hour $i: $prediction");
        floatPredictions.add(prediction);
        integerPredictions.add(prediction.round());
        data[0][4] =
            (data[0][4] + 1) % 24; // Update the hour for the next iteration
        inputList = data.expand((e) => e).toList();
        input = Float32List.fromList(inputList);
        print("Updated input list for next iteration: $inputList");
      }
      print("Final float predictions: $floatPredictions");
      print("Final integer predictions: $integerPredictions");
      return {
        'floats': floatPredictions,
        'integers': integerPredictions,
      };
    } catch (e) {
      print("Error predicting weather: $e");
      return {
        'floats': [],
        'integers': [],
      };
    }
  }

  List<List<double>> prepareInputData(List<Map<String, dynamic>> data,
      {bool useMockData = false}) {
    List<Map<String, dynamic>> mockData = [
      {
        'Temperature': 30.0,
        'Dewpoint_temperature': 26.0,
        'Pressure': 100.9,
        'Humidity': 79.0,
        'Hour': 14,
        'Day': 3,
        'Month': 7,
      },
      // Add more mock data as needed
    ];

    List<Map<String, dynamic>> inputData = useMockData ? mockData : data;
    print("Input data: $inputData");

    return inputData.map((e) {
      return [
        e['Temperature'] as double,
        e['Dewpoint_temperature'] as double,
        e['Pressure'] as double,
        e['Humidity'] as double,
        (e['Hour'] as int).toDouble(),
        (e['Day'] as int).toDouble(),
        (e['Month'] as int).toDouble(),
      ];
    }).toList();
  }

  Future<List<Map<String, dynamic>>> generateForecastData(
      BuildContext context) async {
    print("generateForecastData function called");

    const bool useMockData = false; // Set to true or false as needed
    final currentHour = DateTime.now().hour;
    final List<Map<String, dynamic>> forecastList = [];

    List<Map<String, dynamic>> data = [];
    if (!useMockData) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('WeatherData').get();
      data = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print(
          "Fetched data from Firebase: $data"); // Add this line to verify data
    }

    print("Using mock data: $useMockData");
    print("Data: ${useMockData ? "Using mock data" : data}");

    List<List<double>> inputData =
        prepareInputData(data, useMockData: useMockData);
    print("Prepared input data: $inputData");

    if (!isModelLoaded) {
      await loadModel();
      print("Model loaded successfully."); // Ensure model is loaded
    }

    print("Calling predictWeather.");
    Map<String, dynamic> modelOutput = await predictWeather(inputData);
    print("Model output (floats): ${modelOutput['floats']}");
    print("Model output (integers): ${modelOutput['integers']}");

    final conditions = {
      1: "Clear",
      2: "Fair",
      3: "Cloudy",
      4: "Overcast",
      5: "Fog",
      6: "Freezing Fog",
      7: "Light Rain",
      8: "Rain",
      9: "Heavy Rain",
      10: "Freezing Rain",
      11: "Heavy Freezing Rain",
      12: "Sleet",
      13: "Heavy Sleet",
      14: "Rain Shower",
      15: "Heavy Rain Shower",
      16: "Sleet Shower",
      17: "Heavy Sleet Shower",
      18: "Lightning",
      19: "Hail",
      20: "Thunderstorm",
      21: "Heavy Thunderstorm",
      22: "Storm"
    };

    final dayIcons = {
      1: Icons.wb_sunny,
      2: Icons.wb_sunny_outlined,
      3: Icons.wb_cloudy,
      4: Icons.filter_drama,
      5: Icons.blur_on,
      6: Icons.ac_unit,
      7: Icons.grain,
      8: Icons.invert_colors,
      9: Icons.invert_colors_off,
      10: Icons.ac_unit,
      11: Icons.ac_unit,
      12: Icons.grain,
      13: Icons.grain,
      14: Icons.shower,
      15: Icons.shower,
      16: Icons.shower,
      17: Icons.shower,
      18: Icons.flash_on,
      19: Icons.ac_unit,
      20: Icons.bolt,
      21: Icons.bolt,
      22: Icons.storm
    };

    final nightIcons = {
      1: Icons.nights_stay,
      2: Icons.brightness_2,
      3: Icons.cloud,
      4: Icons.cloud,
      5: Icons.blur_on,
      6: Icons.ac_unit,
      7: Icons.grain,
      8: Icons.invert_colors,
      9: Icons.invert_colors_off,
      10: Icons.ac_unit,
      11: Icons.ac_unit,
      12: Icons.grain,
      13: Icons.grain,
      14: Icons.shower,
      15: Icons.shower,
      16: Icons.shower,
      17: Icons.shower,
      18: Icons.flash_on,
      19: Icons.ac_unit,
      20: Icons.bolt,
      21: Icons.bolt,
      22: Icons.storm
    };

    for (int i = 0; i < 6; i++) {
      final forecastHour = (currentHour + i) % 24;
      final isDaytime = forecastHour >= 6 && forecastHour <= 18;

      int weatherCode = modelOutput['integers'][i];
      print(
          "Weather code for hour $forecastHour: $weatherCode"); // Debug weather code

      final condition = conditions[weatherCode] ?? "Unknown";
      final IconData icon =
          (isDaytime ? dayIcons[weatherCode] : nightIcons[weatherCode]) ??
              Icons.help;

      forecastList.add({
        "hour": forecastHour,
        "time": TimeOfDay(hour: forecastHour, minute: 0).format(context),
        "icon": icon,
        "condition": condition,
        "isCurrentHour": forecastHour == currentHour,
      });
    }

    print("Forecast list generated: $forecastList");

    return forecastList;
  }

  void centerScrollToCurrentHour() async {
    final forecastData = await generateForecastData(context);
    final currentHour = DateTime.now().hour;
    final forecastList = forecastData;
    final index =
        forecastList.indexWhere((data) => data['hour'] == currentHour);
    if (index != -1) {
      _scrollController.animateTo(
        index * 116.0,
        duration: const Duration(seconds: 0),
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

  Future<void> _createCustomMarker(LatLng position) async {
    print('Creating custom marker at position: $position');
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/Rectangle22.png', 50);
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('customMarker'),
          position: position,
          icon: BitmapDescriptor.bytes(markerIcon),
          onTap: () {
            _isInfoWindowOpenNotifier.value = true;
            _panelController.close();
          },
        ),
      );
    });
  }

  void _startHourlyUpdateTimer() {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    final initialDelay = nextHour.difference(now);

    // Set a one-time timer to fire at the start of the next hour
    Timer(initialDelay, () {
      setState(() {});

      // Set up a periodic timer to fire at the start of every subsequent hour
      _timer = Timer.periodic(const Duration(hours: 1), (timer) {
        setState(() {});
      });
    });
  }

  void _fetchBuoyData() {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('BuoyData');
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        buoyData = {
          "AngleX": data['AngleX'],
          "AngleY": data['AngleY'],
          "altitude": data['altitude'],
          "latitude": data['latitude'],
          "longitude": data['longitude'],
        };
        buoyData["status"] = getBuoyStatus(data['AngleX'], data['AngleY']);

        LatLng newPosition =
            LatLng(buoyData["latitude"], buoyData["longitude"]);
        _moveCameraToPosition(newPosition);
        _createCustomMarker(newPosition);

        if (buoyData["status"] == 'Capped') {
          _showCappedNotification(newPosition);
        }
      });
    });
  }

  String getBuoyStatus(double angleX, double angleY) {
    const double thresholdStable = 5.0;
    const double thresholdWaning = 15.0;

    if (angleX.abs() <= thresholdStable && angleY.abs() <= thresholdStable) {
      return 'Stable';
    } else if (angleX.abs() <= thresholdWaning &&
        angleY.abs() <= thresholdWaning) {
      return 'Warning';
    } else {
      return 'Capped';
    }
  }

  void _showCappedNotification(LatLng position) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Buoy Capped"),
          content: Text(
              "The buoy is capped at position: \nLatitude: ${position.latitude}, Longitude: ${position.longitude}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchInitialCameraPosition() async {
    print('Inside _fetchInitialCameraPosition...');
    LatLng initialPosition = await _getInitialCameraPosition();
    setState(() {
      _initialCameraPosition = CameraPosition(
        target: initialPosition,
        zoom: 16.5,
      );
      print('Camera position updated to: $_initialCameraPosition');
      // Create the initial custom marker
      _createCustomMarker(initialPosition);
    });
  }

  Future<LatLng> _getInitialCameraPosition() async {
    final DatabaseReference positionRef =
        FirebaseDatabase.instance.ref().child('BuoyData');

    final Completer<LatLng> completer = Completer();

    positionRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final double latitude = data['latitude']?.toDouble() ?? 0.0;
      final double longitude = data['longitude']?.toDouble() ?? 0.0;
      print(
          'Fetched data from Firebase: latitude=$latitude, longitude=$longitude');

      LatLng newPosition = LatLng(latitude, longitude);

      if (!completer.isCompleted) {
        completer.complete(newPosition);
      }

      setState(() {
        _initialCameraPosition = CameraPosition(
          target: newPosition,
          zoom: 16.5,
        );
        _moveCameraToPosition(newPosition);
        _createCustomMarker(newPosition);
      });
    });

    return completer.future;
  }

  void _moveCameraToPosition(LatLng position) {
    print('Moving camera to position: $position');
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16.5),
      ),
    );
  }

  void _startBuoyUpdateListener() {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('BuoyData');
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        buoyData = {
          "AngleX": data['AngleX'],
          "AngleY": data['AngleY'],
          "altitude": data['altitude'],
          "latitude": data['latitude'],
          "longitude": data['longitude'],
        };
        buoyData["status"] = getBuoyStatus(data['AngleX'], data['AngleY']);
        LatLng newPosition =
            LatLng(buoyData["latitude"], buoyData["longitude"]);
        _moveCameraToPosition(newPosition);
        _createCustomMarker(newPosition);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 123, // Adjust the height here
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red[700],
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text(
                'About Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutUsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ContactUsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              // Check if the panel is closed or not
              if (!_isPanelOpenNotifier.value) {
                _googleMapController.moveCamera(CameraUpdate.scrollBy(
                  -details.delta.dx,
                  -details.delta.dy,
                ));
              }
            },
          ),
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false, // Disable zoom controls
            zoomGesturesEnabled: true, // Enable zoom gestures
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: _markers,
          ),
          SlidingUpPanel(
            controller: _panelController,
            panelBuilder: (controller) => PanelWidget(
              controller: controller,
              database: FirebaseDatabase.instance,
              forecastData: Future.value([]),
              buoyData: const {}, // Pass FirebaseDatabase instance here
            ),
            backdropEnabled: true,
            backdropColor: Colors.transparent,
            color: Colors.transparent,
            minHeight: 120,
            maxHeight: screenHeight * 0.64,
            margin: const EdgeInsets.only(
              bottom: 0.1,
            ),
            onPanelOpened: () => _isPanelOpenNotifier.value = true,
            onPanelClosed: () => _isPanelOpenNotifier.value = false,
          ),
          Positioned(
            left: 16,
            top: 49,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
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
                    icon: const Icon(Icons.menu, color: Colors.black),
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
            valueListenable: _isInfoWindowOpenNotifier,
            builder: (context, isInfoWindowOpen, child) {
              if (isInfoWindowOpen) {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: screenWidth * 0.8,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Buoy\'s Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 8.0), // Space between title and first data
                        Align(
                          alignment: Alignment.center,
                          child: Text('X-axis: ${buoyData["AngleX"]}'),
                        ),
                        const SizedBox(
                            height: 8.0), // Space between X-axis and Y-axis
                        Align(
                          alignment: Alignment.center,
                          child: Text('Y-axis: ${buoyData["AngleY"]}'),
                        ),
                        const SizedBox(
                            height: 8.0), // Space between Y-axis and Altitude
                        Align(
                          alignment: Alignment.center,
                          child: Text('Altitude: ${buoyData["altitude"]}'),
                        ),
                        const SizedBox(
                            height: 8.0), // Space between Altitude and Latitude
                        Align(
                          alignment: Alignment.center,
                          child: Text('Latitude: ${buoyData["latitude"]}'),
                        ),
                        const SizedBox(
                            height:
                                8.0), // Space between Latitude and Longitude
                        Align(
                          alignment: Alignment.center,
                          child: Text('Longitude: ${buoyData["longitude"]}'),
                        ),
                        const SizedBox(
                            height: 8.0), // Space between Longitude and Status
                        Align(
                          alignment: Alignment.center,
                          child: Text('Status: ${buoyData["status"]}'),
                        ),
                        const SizedBox(height: 16.0), // Space before the button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _isInfoWindowOpenNotifier.value = false;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isPanelOpenNotifier,
            builder: (context, isPanelOpen, child) {
              return Positioned(
                left: 16,
                right: 16,
                top: 118,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 0),
                  opacity: isPanelOpen ? 0.0 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
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
                        const Text(
                          'Hourly Weather Forecast',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: generateForecastData(context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    6,
                                    (index) => Container(
                                      width: 100,
                                      margin:
                                          const EdgeInsets.only(right: 16.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 50,
                                            height: 10,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 30,
                                            height: 10,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 50,
                                            height: 10,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Text('No data available');
                            }
                            final forecastList = snapshot.data!;
                            final currentHour = DateTime.now().hour;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController,
                              child: Row(
                                children: forecastList.map((data) {
                                  final isCurrentHour =
                                      data['hour'] == currentHour;
                                  final icon = data['icon']
                                      as IconData; // Cast to IconData
                                  return Container(
                                    margin: const EdgeInsets.only(right: 16.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: isCurrentHour
                                          ? Colors.red[700]
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          icon,
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
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: _fabPositionNotifier,
            builder: (context, value, child) {
              return Positioned(
                right: 16,
                bottom: 128,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isPanelOpenNotifier,
                  builder: (context, isPanelOpen, child) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 0),
                      opacity: isPanelOpen ? 0.0 : 1.0,
                      child: FloatingActionButton(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.black,
                        onPressed: () async {
                          LatLng newPosition =
                              await _getInitialCameraPosition();
                          _googleMapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: newPosition,
                                zoom: 16.5, // Reset zoom level to 16.5
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.center_focus_strong),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
