import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/pages/Profile_page.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _checkOnlineStatus(dynamic lastSeen) {
    if (lastSeen is Timestamp) {
      final currentTime = Timestamp.now();
      final difference = currentTime.seconds - lastSeen.seconds;
      return difference < 300;
    }
    return false;
  }

  late Stream<List<String>> _selectedTopicsStream;

  @override
  void initState() {
    super.initState();
    _selectedTopicsStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser
            ?.uid) // Replace 'currentUserID' with the ID of the current user
        .snapshots()
        .map((doc) => List<String>.from(doc['selectedTopics'] ?? []));
  }

  @override
  Widget build(BuildContext context) {
    void navigateToProfilePage(String userId) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: const Text('Users with Similar Topics'),
      ),
      body: StreamBuilder<List<String>>(
        stream: _selectedTopicsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No selected topics found'));
          }
          List<String> currentUserSelectedTopics = snapshot.data!;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              List<DocumentSnapshot> users = snapshot.data!.docs;
              List<DocumentSnapshot> filteredUsers = [];
              for (var user in users) {
                Map<String, dynamic>? userData = user.data() as Map<String, dynamic>?;
                if (userData != null) {
                  List<String> userSelectedTopics = List<String>.from(userData['selectedTopics'] ?? []);
                  if (userSelectedTopics.any((topic) => currentUserSelectedTopics.contains(topic))) {
                    filteredUsers.add(user);
                  }
                }
              }
              if (filteredUsers.isEmpty) {
                return const Center(
                    child: Text(
                  'No users found with similar topics',
                  style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
                ));
              }
              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  var userData = filteredUsers[index].data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final lastSeen = userData['lastseen'];
                    final isOnline = _checkOnlineStatus(lastSeen);
                    final cardColor = isOnline
                        ? Color.fromARGB(255, 250, 253, 251)
                        : Color.fromARGB(72, 252, 252, 252);
                    final dotColor = isOnline ? Colors.green : Colors.red;

                    return GestureDetector(
                      onTap: () {
                        navigateToProfilePage(userData['uid']);
                      },
                      child: Card(
                        color: cardColor,
                        child: ListTile(
                          leading: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                          title: Text(
                            userData['username'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            userData['university'],
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(); // Return an empty container if userData is null
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}