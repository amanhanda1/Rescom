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
  late bool isFriend = false;

  @override
  void initState() {
    super.initState(); // Initialize with a default value
    _loadFriendStatus();
  }

  Future<void> _loadFriendStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedStatus = prefs.getBool('friendStatus_${widget.userId}');
    setState(() {
      isFriend = storedStatus ?? false; // Default to false if not found
    });
    // Remove checkFriendStatus() from here as it's already called in setState
  }

  Future<void> checkFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc =
        FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final friendDoc = userDoc.collection('Friends').doc(widget.userId);
    final friendSnapshot = await friendDoc.get();
    final prefs = await SharedPreferences.getInstance();

    // Update SharedPreferences here
    await prefs.setBool('friendStatus_${widget.userId}', friendSnapshot.exists);

    setState(() {
      isFriend = friendSnapshot.exists;
    });
  }

  Future<void> addFriend() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .get();
    final currentUsername = userDoc.data()?['username'];

    if (currentUsername == null) {
      return;
    }

    final friendDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('Friends')
        .doc(currentUser.uid);
    final sprtingDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.uid)
        .collection('Supportings')
        .doc(widget.userId);
    final friendData = {
      'friendId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
    final sprtData = {
      'friendId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await friendDoc.set(friendData);
    await sprtingDoc.set(sprtData); // Set supporting data using friend's ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('friendStatus_${widget.userId}', true);
    setState(() {
      isFriend = true;
    });

    final notificationData = {
      'user': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'message': '$currentUsername added you as a friend',
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

    final userDoc =
        FirebaseFirestore.instance.collection('Users').doc(currentUser.uid);
    final friendDoc = userDoc.collection('Friends').doc(widget.userId);

    final friendUserDoc =
        FirebaseFirestore.instance.collection('Users').doc(widget.userId);
    final currentUserFriendDoc =
        friendUserDoc.collection('Friends').doc(currentUser.uid);

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
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ),
        child: Text(
          isFriend ? 'Remove Support' : 'Add Support',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }
}
