import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/Profile_photo.dart';
import 'package:resapp/components/research_topics.dart';
import 'package:resapp/pages/Profile_page.dart';

class sameUniUsers extends StatefulWidget {
  const sameUniUsers({Key? key}) : super(key: key);

  @override
  State<sameUniUsers> createState() => _sameUniUsersState();
}

class _sameUniUsersState extends State<sameUniUsers> {
  String currentUniversity = ''; // Initialize with an empty string
  late QuerySnapshot usersSnapshot;

  @override
  void initState() {
    super.initState();
    getUserUniversity();
  }

  Future<void> getUserUniversity() async {
    DocumentSnapshot? userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      currentUniversity = userSnapshot['university'] ?? '';
    });
  }

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
          "Same University users",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('university', isEqualTo: currentUniversity)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'empty',
              style: TextStyle(color: Colors.white),
            ));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final lastSeen = data['lastseen'];
              final isOnline = _checkOnlineStatus(lastSeen);
              final cardColor = isOnline
                  ? Color.fromARGB(255, 196, 203, 198)
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
                  String? photoUrl = data.containsKey('photoUrl')
                        ? data['photoUrl']
                        : null;
                    final otherUserId = data['uid'];
              if (FirebaseAuth.instance.currentUser != null &&
                  data['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                return SizedBox.shrink(); // Skip this user
              }
              return GestureDetector(
                onTap: () {
                  navigateToProfilePage(data['uid']);
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
                    title: Text(data['username'],
                        style: isOnline
                            ? TextStyle(color: Color.fromARGB(207, 26, 24, 46))
                            : TextStyle(color: Colors.white
                                )),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['role'] ?? "old",
                          style: isOnline
                            ? TextStyle(color: Color.fromARGB(151, 26, 24, 46))
                            : TextStyle(color: Colors.white60
                                )
                        ),
                        if (selectedTopics.isNotEmpty)
                          Text(
                            'Research Topics: $topicTitles',
                            style: isOnline
                            ? TextStyle(color: Color.fromARGB(151, 26, 24, 46))
                            : TextStyle(color: Colors.white60
                                )
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
