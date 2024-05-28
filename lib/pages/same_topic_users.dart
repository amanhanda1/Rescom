import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/Profile_photo.dart';
import 'package:resapp/components/research_topics.dart';
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
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)));
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
                Map<String, dynamic>? userData =
                    user.data() as Map<String, dynamic>?;
                if (userData != null) {
                  List<String> userSelectedTopics =
                      List<String>.from(userData['selectedTopics'] ?? []);
                  if (userSelectedTopics.any(
                      (topic) => currentUserSelectedTopics.contains(topic))) {
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
                  var userData =
                      filteredUsers[index].data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final lastSeen = userData['lastseen'];
                    final isOnline = _checkOnlineStatus(lastSeen);
                    final cardColor = isOnline
                        ? Color.fromARGB(255, 196, 203, 198)
                        : Color.fromARGB(72, 252, 252, 252);
                    final dotColor = isOnline ? Colors.green : Colors.red;
                    final selectedTopics =
                        List<String>.from(userData['selectedTopics'] ?? []);
                    final topicTitles = selectedTopics
                        .map((id) => researchTopics
                            .firstWhere((topic) => topic.id == id,
                                orElse: () => ResearchTopic(id: id, title: id))
                            .title)
                        .join(', ');
                    String? photoUrl = userData.containsKey('photoUrl')
                        ? userData['photoUrl']
                        : null;
                    final otherUserId = userData['uid'];
                    if (FirebaseAuth.instance.currentUser != null &&
                        userData['uid'] ==
                            FirebaseAuth.instance.currentUser!.uid) {
                      return SizedBox.shrink(); // Skip this user
                    }

                    return GestureDetector(
                      onTap: () {
                        navigateToProfilePage(userData['uid']);
                      },
                      child: Card(
                        color: cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade300,
                            child: ProfilePhotoWidget(
                              photoUrl: photoUrl,
                              userId: otherUserId,
                            ),
                          ),
                          trailing: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                          title: Text(userData['username'],
                              style: isOnline
                                  ? TextStyle(
                                      color:
                                          const Color.fromARGB(255, 26, 24, 46))
                                  : TextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData['university'] ?? '',
                                  style: isOnline
                                      ? TextStyle(
                                          color:
                                              Color.fromARGB(151, 26, 24, 46))
                                      : TextStyle(color: Colors.white60)),
                              if (selectedTopics.isNotEmpty)
                                Text('Research Topics: $topicTitles',
                                    style: isOnline
                                        ? TextStyle(
                                            color:
                                                Color.fromARGB(151, 26, 24, 46))
                                        : TextStyle(color: Colors.white60)),
                            ],
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
