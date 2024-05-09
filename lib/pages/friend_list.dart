import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resapp/pages/Profile_page.dart';

class FriendListPage extends StatefulWidget {
  final String userId;
  const FriendListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  bool isFollowers = true;

  void navigateToFriend(BuildContext context, String friendUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: friendUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor      : const Color.fromARGB(128, 0, 128, 1),
        title: Container(
          
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  selectedColor: const Color.fromARGB(255, 26, 24, 46),
                  fillColor: Colors.white.withOpacity(0.3),
                  isSelected: [isFollowers, !isFollowers],
                  onPressed: (index) {
                    setState(() {
                      isFollowers = index == 0;
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Followers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Following',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .collection(isFollowers ? 'Friends' : 'Supportings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          final friends = snapshot.data?.docs ?? [];
          if (friends.isEmpty) {
            return Center(
              child: Text('No friends yet.'),
            );
          }
          return FutureBuilder<List<String>>(
            future: fetchUsernames(friends),
            builder: (context, usernamesSnapshot) {
              if (usernamesSnapshot.connectionState ==
                  ConnectionState.waiting) {
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
                  final friendUserId = friends[index].id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
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
                            color: Color.fromARGB(255, 255, 240, 223),
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

  Future<List<String>> fetchUsernames(
    List<QueryDocumentSnapshot<Object?>> friends,
  ) async {
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
        usernames.add('Unknown User');
      }
    }
    return usernames;
  }
}
