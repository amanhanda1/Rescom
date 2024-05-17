// test/mocks.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Mock classes for Firebase services
class MockUser extends Mock implements User {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
