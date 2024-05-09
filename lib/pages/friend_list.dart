import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resapp/pages/Profile_page.dart';

class FriendListPage extends StatelessWidget {
  final String userId;

  const FriendListPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void navigateToFriend(BuildContext context, String friendUserId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: friendUserId),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(206, 41, 152, 128),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(206, 41, 152, 128),
        title: Text('Friends List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          final friends = snapshot.data?.docs ?? [];

          if (friends.isEmpty) {
            return const Center(
              child: Text('No friends yet.'),
            );
          }

          return FutureBuilder<List<String>>(
            // Fetch usernames based on friend email addresses
            future: fetchUsernames(friends),
            builder: (context, usernamesSnapshot) {
  if (usernamesSnapshot.connectionState == ConnectionState.waiting) {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  if (usernamesSnapshot.hasError) {
    return Center(
      child: Text(
        "Error: ${usernamesSnapshot.error}",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  final usernames = usernamesSnapshot.data ?? [];

  return ListView.builder(
    itemCount: friends.length,
    itemBuilder: (context, index) {
      final friendUsername = usernames[index];
      final friendUserId = friends[index].id; // assuming friend's user ID is used as document ID
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: GestureDetector(
          onTap: () {
            navigateToFriend(context, friendUserId);
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(39, 255, 255, 255),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(7),
            child: Text(
              friendUsername,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );
},
          );
        },
      ),
    );
  }

  // Function to fetch usernames based on email addresses
  Future<List<String>> fetchUsernames(
      List<QueryDocumentSnapshot<Object?>> friends) async {
    final List<String> usernames = [];

    for (final friend in friends) {
      final friendEmail = friend.id;
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(friendEmail)
          .get();

      if (userData.exists) {
        final username = userData['username'] as String;
        usernames.add(username);
      } else {
        // If user data not found, you can handle it accordingly
        usernames.add('Unknown User');
      }
    }

    return usernames;
  }
}
