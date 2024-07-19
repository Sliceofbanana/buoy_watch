import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buoy_watch/panel_widget.dart';
import 'mocks.dart';
import 'setupfirebasemocks.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  testWidgets('PanelWidget content test', (WidgetTester tester) async {
    final mockDatabase = MockFirebaseDatabase();

    final mockForecastData = Future.value([
      {
        "time": "12:00 PM",
        "hour": 12,
        "temp": "30°C",
        "condition": "Clear",
        "icon": Icons.wb_sunny
      },
    ]);

    final mockBuoyData = {
      "AngleX": 0,
      "AngleY": 0,
      "altitude": 0,
      "latitude": 0,
      "longitude": 0,
      "status": "Stable"
    };

    await tester.pumpWidget(MaterialApp(
      home: PanelWidget(
        controller: ScrollController(),
        forecastData: mockForecastData,
        buoyData: mockBuoyData,
        database: mockDatabase,
        forecast: const {},
      ),
    ));

    // Verify that the PanelWidget displays the expected content
    expect(find.text('12:00 PM'), findsOneWidget);
    expect(find.text('30°C'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    expect(find.text('Stable'), findsOneWidget);
  });
}
