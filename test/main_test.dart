import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:buoy_watch/main.dart';
import 'mocks.dart';
import 'setupfirebasemocks.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  group('FirebaseDatabase', () {
    late MockDatabaseReference mockDatabaseReference;
    late StreamController<DatabaseEvent> controller;

    setUp(() {
      mockDatabaseReference = MockDatabaseReference();
      controller = StreamController<DatabaseEvent>();

      // Correctly return a new instance of MockDatabaseReference
      when(mockDatabaseReference.child('WeatherData'))
          .thenReturn(MockDatabaseReference());
      when(mockDatabaseReference.onValue).thenAnswer((_) => controller.stream);
    });

    tearDown(() {
      controller.close();
    });

    testWidgets('Fetch Buoy Data', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MapScreen(),
      ));

      var mockSnapshot = MockDataSnapshot();
      when(mockSnapshot.value).thenReturn({"latitude": 0, "longitude": 0});

      var mockEvent = MockDatabaseEvent();
      when(mockEvent.snapshot).thenReturn(mockSnapshot);

      controller.add(mockEvent);

      await tester.pump();

      expect(find.text('Latitude: 0'), findsOneWidget);
      expect(find.text('Longitude: 0'), findsOneWidget);
    });
  });
}
