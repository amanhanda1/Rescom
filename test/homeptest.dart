// // test/home_page_test.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';
// import 'package:resapp/pages/HomePage.dart';
// import 'package:resapp/pages/add_post.dart';
// import 'package:resapp/pages/profile_page.dart';

// import 'mock.dart';



// void main() {
//   late MockFirebaseFirestore mockFirestore;
//   late MockFirebaseAuth mockAuth;
//   late MockUser mockUser;

//   setUp(() {
//     mockFirestore = MockFirebaseFirestore();
//     mockAuth = MockFirebaseAuth();
//     mockUser = MockUser();

//     when(mockAuth.currentUser).thenReturn(mockUser);
//     when(mockUser.uid).thenReturn('testUserId');
//   });

//   Widget createHomePage() {
//     return MultiProvider(
//       providers: [
//         Provider<FirebaseAuth>.value(value: mockAuth),
//         Provider<FirebaseFirestore>.value(value: mockFirestore),
//       ],
//       child: MaterialApp(
//         home: HomePage(),
//       ),
//     );
//   }

//   testWidgets('HomePage displays posts correctly', (WidgetTester tester) async {
//     final postsSnapshot = QuerySnapshot<Map<String, dynamic>>(
//       docs: [
//         QueryDocumentSnapshot<Map<String, dynamic>>(
//           id: 'post1',
//           data: {
//             'text': 'Test Post 1',
//             'userId': 'testUserId',
//             'timestamp': Timestamp.now(),
//           },
//           reference: mockFirestore.collection('Posts').doc('post1'),
//         ),
//       ],
//       query: mockFirestore.collection('Posts'),
//       metadata: SnapshotMetadata(hasPendingWrites: false, isFromCache: false),
//     );

//     when(mockFirestore.collection('Posts').snapshots())
//         .thenAnswer((_) => Stream.value(postsSnapshot));

//     await tester.pumpWidget(createHomePage());

//     // Wait for the stream to emit data and the widget to rebuild.
//     await tester.pump();

//     // Verify that the post is displayed.
//     expect(find.text('Test Post 1'), findsOneWidget);
//   });

//   testWidgets('HomePage navigates to ProfilePage on post tap', (WidgetTester tester) async {
//     await tester.pumpWidget(createHomePage());

//     final postsSnapshot = QuerySnapshot<Map<String, dynamic>>(
//       docs: [
//         QueryDocumentSnapshot<Map<String, dynamic>>(
//           id: 'post1',
//           data: {
//             'text': 'Test Post 1',
//             'userId': 'testUserId',
//             'timestamp': Timestamp.now(),
//           },
//           reference: mockFirestore.collection('Posts').doc('post1'),
//         ),
//       ],
//       query: mockFirestore.collection('Posts'),
//       metadata: SnapshotMetadata(hasPendingWrites: false, isFromCache: false),
//     );

//     when(mockFirestore.collection('Posts').snapshots())
//         .thenAnswer((_) => Stream.value(postsSnapshot));

//     when(mockFirestore.collection('Users').doc('testUserId').get()).thenAnswer(
//       (_) async => DocumentSnapshot<Map<String, dynamic>>(
//         id: 'testUserId',
//         data: {
//           'username': 'Test User',
//         },
//         reference: mockFirestore.collection('Users').doc('testUserId'),
//         metadata: SnapshotMetadata(hasPendingWrites: false, isFromCache: false),
//       ),
//     );

//     await tester.pumpWidget(createHomePage());
//     await tester.pump();

//     await tester.tap(find.text('Test Post 1'));
//     await tester.pumpAndSettle();

//     // Verify that navigation to ProfilePage occurred
//     expect(find.byType(ProfilePage), findsOneWidget);
//   });

//   testWidgets('HomePage navigates to AddPostPage on FAB tap', (WidgetTester tester) async {
//     await tester.pumpWidget(createHomePage());

//     await tester.tap(find.byType(FloatingActionButton));
//     await tester.pumpAndSettle();

//     // Verify that navigation to AddPostPage occurred
//     expect(find.byType(AddPostPage), findsOneWidget);
//   });
// }
