import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendButton extends StatefulWidget {
  final String userId;

  const FriendButton({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendButtonState createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  bool isFriend = false;

  @override
  void initState() {
    super.initState();
    _loadFriendStatus();
  }

  Future<void> _loadFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedStatus = prefs.getBool('friendStatus_${widget.userId}');

    if (storedStatus != null) {
      setState(() {
        isFriend = storedStatus;
      });
    } else {
      // If no local data, check Firestore and update SharedPreferences
      await checkFriendStatus();
    }
  }

  Future<void> checkFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final friendDoc = userDoc.collection('Supportings').doc(widget.userId);
    final friendSnapshot = await friendDoc.get();
    final prefs = await SharedPreferences.getInstance();

    final isFriendStatus = friendSnapshot.exists;

    await prefs.setBool('friendStatus_${widget.userId}', isFriendStatus);

    setState(() {
      isFriend = isFriendStatus;
    });
  }

  Future<void> addFriend() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).get();
    final currentUsername = userDoc.data()?['username'];

    if (currentUsername == null) {
      return;
    }

    final friendDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('Friends')
        .doc(currentUser.uid);
    final supportingDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('Supportings')
        .doc(widget.userId);

    final friendData = {
      'friendId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
    final supportingData = {
      'friendId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await friendDoc.set(friendData);
    await supportingDoc.set(supportingData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('friendStatus_${widget.userId}', true);

    setState(() {
      isFriend = true;
    });

    final notificationData = {
      'user': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'message': '$currentUsername followed you',
      'userId': currentUser.uid,
    };

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('Notifications')
        .add(notificationData);
  }

  Future<void> removeFriend() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final friendDoc = userDoc.collection('Supportings').doc(widget.userId);

    final friendUserDoc = FirebaseFirestore.instance.collection('Users').doc(widget.userId);
    final currentUserFriendDoc = friendUserDoc.collection('Friends').doc(currentUser.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.delete(friendDoc);
        await transaction.delete(currentUserFriendDoc);
      });
    } catch (e) {
      print('Error removing friend: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('friendStatus_${widget.userId}', false);

    setState(() {
      isFriend = false;
    });
  }

  Future<void> _toggleFriendStatus() async {
    if (isFriend) {
      await removeFriend();
    } else {
      await addFriend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ElevatedButton(
        onPressed: _toggleFriendStatus,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              isFriend ? Colors.red : Colors.blue),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.black),
            ),
          ),
        ),
        child: Text(
          isFriend ? 'Following' : 'Follow',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}