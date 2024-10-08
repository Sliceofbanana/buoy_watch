import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {
  @override
  String get name => "test"; // Ensure name is not null

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'testApiKey',
        appId: 'testAppId',
        messagingSenderId: 'testSenderId',
        projectId: 'testProjectId',
      );
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create the mock FirebaseApp
  final mockFirebaseApp = MockFirebaseApp();

  // Mock FirebaseAuth instanceFor
  final mockFirebaseAuth = MockFirebaseAuth();
  when(FirebaseAuth.instanceFor(app: mockFirebaseApp))
      .thenReturn(mockFirebaseAuth);

  // Set up other FirebaseAuth method stubs if needed
  when(mockFirebaseAuth.authStateChanges())
      .thenAnswer((_) => const Stream.empty());
}

Future<void> initializeFirebase() async {
  setupFirebaseMocks();
  await Firebase.initializeApp(
    name: 'test', // Ensure the name is provided
    options: const FirebaseOptions(
      apiKey: 'testApiKey',
      appId: 'testAppId',
      messagingSenderId: 'testSenderId',
      projectId: 'testProjectId',
    ),
  );
}
