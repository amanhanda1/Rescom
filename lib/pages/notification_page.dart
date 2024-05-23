import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resapp/components/friend_button.dart';
import 'package:resapp/pages/profile_page.dart';

class NotificationPage extends StatefulWidget {
  final String userId; // Add a parameter to accept the user ID

  const NotificationPage({required this.userId}); // Constructor

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    void navigateToProfilePage(String userId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        leading:  IconButton( icon:Icon(Icons.arrow_back_rounded), onPressed: () {  Navigator.pop(context);},),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("N O T I F I C A T I O N S")],
        ),
      ),
      body: FutureBuilder(
        future: getNotifications(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications found.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12), // Adjust opacity here
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () => navigateToProfilePage(doc['user']),
                  child: ListTile(
                    title: Text(doc['message']),
                    subtitle: Text(
                      _formatDateTime(
                          doc['timestamp'] as Timestamp? ?? Timestamp.now()),
                    ),
                    trailing: FriendButton(userId: doc['user']),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> getNotifications() async {
    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch notifications from Firestore for the current user
      return await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid) // Using user's UID instead of widget.userId
          .collection('Notifications')
          .get();
    } else {
      // Handle the case where the user is not logged in
      throw Exception('User is not logged in');
    }
  }



String _formatDateTime(Timestamp? timestamp) {
  final now = DateTime.now();
  final dateTime = timestamp?.toDate();
  if (dateTime == null) {
    return 'Unknown Date and Time';
  }
  
  final difference = now.difference(dateTime);
  if (difference.inHours < 24) {
    if (difference.inHours == 0) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      return '1 hour ago';
    } else {
      return '${difference.inHours} hours ago';
    }
  } else {
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }
}
}