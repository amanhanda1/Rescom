import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/research_topics.dart';
import 'package:resapp/pages/Profile_page.dart';

class UserList extends StatefulWidget {
  final String role;

  const UserList({Key? key, required this.role}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  bool _checkOnlineStatus(dynamic lastSeen) {
    if (lastSeen is Timestamp) {
      final currentTime = Timestamp.now();
      final difference = currentTime.seconds - lastSeen.seconds;
      return difference < 300;
    }
    return false;
  }

  void updateLastSeen() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .update({'lastseen': FieldValue.serverTimestamp()});
    }
  }

  @override
  Widget build(BuildContext context) {
    void navigateToProfilePage(String userId) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage(
                    userId: userId,
                  )));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: Text(
          widget.role == 'Student' ? 'Student List' : 'Teacher List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('role', isEqualTo: widget.role)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ${widget.role}s found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final lastSeen = data['lastseen'];
              final isOnline = _checkOnlineStatus(lastSeen);
              final cardColor = isOnline
                  ? Color.fromARGB(255, 250, 253, 251)
                  : Color.fromARGB(72, 252, 252, 252);
              final dotColor = isOnline ? Colors.green : Colors.red;
              final selectedTopics =
                  List<String>.from(data['selectedTopics'] ?? []);
              final topicTitles = selectedTopics
                  .map((id) => researchTopics
                      .firstWhere((topic) => topic.id == id,
                          orElse: () => ResearchTopic(id: id, title: id))
                      .title)
                  .join(', ');
              return GestureDetector(
                onTap: () {
                  navigateToProfilePage(data['uid']);
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
                      data['username'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['university'],
                          style: TextStyle(color: Colors.white60),
                        ),
                        if (selectedTopics.isNotEmpty)
                          Text(
                            'Research Topics: $topicTitles',
                            style: TextStyle(color: Colors.white60),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
