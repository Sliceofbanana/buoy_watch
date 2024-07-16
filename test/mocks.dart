import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDatabaseEvent extends Mock implements DatabaseEvent {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
