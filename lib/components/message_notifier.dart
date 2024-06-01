import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageNotifier {
  static final MessageNotifier _instance = MessageNotifier._internal();
  bool hasNewMessages = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _periodicTimer;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  factory MessageNotifier() {
    return _instance;
  }

  MessageNotifier._internal() {
    _auth.userChanges().listen((user) {
      if (user != null) {
        startListeningForMessages();
      } else {
        _stopListeningForMessages();
      }
    });
  }

  Stream<bool> get messageStream => _controller.stream;

  void startListeningForMessages() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Conversations')
          .snapshots()
          .listen((snapshot) {
        bool newMessages = false;
        for (var doc in snapshot.docs) {
          FirebaseFirestore.instance
              .collection('Conversations')
              .doc(doc['conversationId'])
              .collection('Messages')
              .where('seen', isEqualTo: false)
              .where('receiverUserId', isEqualTo: currentUser.uid)
              .snapshots()
              .listen((messageSnapshot) {
            if (messageSnapshot.docs.isNotEmpty) {
              newMessages = true;
            }
            if (newMessages != hasNewMessages) {
              hasNewMessages = newMessages;
              _controller.add(newMessages);
            }
          });
        }
      });
    }
  }

  void _stopListeningForMessages() {
    _controller.add(false);
    hasNewMessages = false;
    _periodicTimer?.cancel();
  }

  void resetNewMessages() {
    hasNewMessages = false;
    _controller.add(false);
  }
}
