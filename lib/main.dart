import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/MyFirebaseMessagingService.dart';
import 'package:resapp/firebase_options.dart';
import 'package:resapp/pages/First_page.dart';
import 'package:resapp/pages/HomePage.dart';

class PreviousRouteObserver extends NavigatorObserver {
  Route<dynamic>? _previousRoute;

  Route<dynamic>? get previousRoute => _previousRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _previousRoute = previousRoute;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Check if the user is already signed in
  User? user = FirebaseAuth.instance.currentUser;
  Widget initialScreen = (user != null) ? HomePage() : FirstPage();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final myFirebaseMessagingService = MyFirebaseMessagingService();
  myFirebaseMessagingService.initialize();

  runApp(MyApp(initialScreen: initialScreen));
}

final storage = FirebaseStorage.instance;
final firestore = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  final PreviousRouteObserver routeObserver = PreviousRouteObserver();

  MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R E S',
      navigatorObservers: [routeObserver],
      home: initialScreen,
    );
  }
}
