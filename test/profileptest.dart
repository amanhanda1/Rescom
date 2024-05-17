// test/profile_page_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:resapp/messaging/chatroom.dart';
import 'package:resapp/pages/Profile_page.dart';

import 'mock.dart';// Import the mocks file

void main() {
  group('ProfilePage Widget Tests', () {
    testWidgets('ProfilePage displays user data correctly', (WidgetTester tester) async {
      // Mock user data
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('testUserId');

      final mockAuth = MockFirebaseAuth();
      when(mockAuth.currentUser).thenReturn(mockUser);

      final mockSnapshot = MockDocumentSnapshot();
      when(mockSnapshot.data()).thenReturn({
        'username': 'testuser',
        'firstName': 'Test',
        'lastName': 'User',
        'bio': 'Test bio',
        'university': 'Test University',
        'photoUrl': 'http://testurl.com/photo.jpg',
        'linkedInUrl': 'http://linkedin.com/testuser',
        'researchGateUrl': 'http://researchgate.com/testuser',
        'selectedTopics': ['topic1', 'topic2']
      });

      // Mock Firestore call
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();
      when(mockCollection.doc('testUserId')).thenReturn(mockDocument);
      when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);

      // Mock FirebaseFirestore instance
      final mockFirestore = MockFirebaseFirestore();
      when(mockFirestore.collection('Users')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);

      await tester.pumpWidget(MaterialApp(
        home: ProfilePage(userId: 'testUserId'),
      ));

      await tester.pumpAndSettle(); // Wait for the async calls to complete

      // Verify the user data is displayed correctly
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Test University'), findsOneWidget);
      expect(find.text('Test bio'), findsOneWidget);
    });

    testWidgets('ProfilePage navigation buttons work', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProfilePage(userId: 'testUserId'),
      ));

      await tester.pumpAndSettle();

      // Tap on the chat button and verify navigation
      await tester.tap(find.byIcon(Icons.chat_bubble));
      await tester.pumpAndSettle();
      expect(find.byType(ChatRoomPage), findsOneWidget);
    });
  });
}
