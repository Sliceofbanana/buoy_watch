import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

// Mock classes
class MockFirebaseApp extends Mock implements FirebaseApp {
  @override
  String get name => 'MockApp';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'testApiKey',
        appId: 'testAppId',
        messagingSenderId: 'testSenderId',
        projectId: 'testProjectId',
      );
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

final Logger _logger = Logger('FirebaseMockSetup');

void setupLogging() {
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockFirebaseApp = MockFirebaseApp();
  _logger.info('Setting up mock FirebaseApp');

  // Ensure that the mock is set up correctly
  when(mockFirebaseApp.name).thenReturn('MockApp');
  when(mockFirebaseApp.options).thenReturn(const FirebaseOptions(
    apiKey: 'testApiKey',
    appId: 'testAppId',
    messagingSenderId: 'testSenderId',
    projectId: 'testProjectId',
  ));

  final mockFirebaseAuth = MockFirebaseAuth();
  // Return the mock instance properly
  when(() => FirebaseAuth.instanceFor(app: mockFirebaseApp))
      .thenReturn(mockFirebaseAuth as FirebaseAuth Function());
  when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => Stream.empty());

  _logger.info('Mock FirebaseAuth setup completed');
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
  _logger.info('Firebase initialized');
}

void main() {
  setupLogging();
  initializeFirebase();
}
