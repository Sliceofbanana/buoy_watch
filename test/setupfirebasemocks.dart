import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

// Create a Mock class for FirebaseApp
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Create a Mock class for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create the mock FirebaseApp
  final mockFirebaseApp = MockFirebaseApp();

  // Set up the method stubs
  when(mockFirebaseApp.name).thenReturn('test');
  when(mockFirebaseApp.options).thenReturn(const FirebaseOptions(
    apiKey: 'testApiKey',
    appId: 'testAppId',
    messagingSenderId: 'testSenderId',
    projectId: 'testProjectId',
  ));

  // Mock FirebaseAuth instanceFor
  final mockFirebaseAuth = MockFirebaseAuth();
  when(FirebaseAuth.instanceFor(app: mockFirebaseApp))
      .thenReturn(mockFirebaseAuth);

  // Set up other FirebaseAuth method stubs if needed
  when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.empty());
}

Future<void> initializeFirebase() async {
  setupFirebaseMocks();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'testApiKey',
      appId: 'testAppId',
      messagingSenderId: 'testSenderId',
      projectId: 'testProjectId',
    ),
  );
}
