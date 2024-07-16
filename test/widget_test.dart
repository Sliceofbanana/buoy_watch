import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buoy_watch/main.dart';
import 'package:buoy_watch/panel_widget.dart';
import 'mocks.dart';
import 'firebase_test_setup.dart';

void main() {
  setUpAll(() async {
    await initializeFirebase();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

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

    expect(find.text('Panel Widget Content'), findsOneWidget);
  });
}
