import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/Profile_photo.dart';
import 'package:resapp/components/research_topics.dart';
import 'package:resapp/pages/Profile_page.dart';

class UserList extends StatefulWidget {
  final String role;
  final String searchQuery;

  const UserList({Key? key, required this.role, required this.searchQuery})
      : super(key: key);

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
        leading: Icon(Icons.person_add_alt_1,
            color: const Color.fromARGB(255, 255, 240, 223)),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: Center(
          child: Text(
            widget.role == 'Student'
                ? 'Students List'
                : widget.role == 'Teacher'
                    ? 'Teachers List'
                    : widget.role == 'Job'
                        ? 'Job List'
                        : 'Researchers List',
            style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.filter_list),
        //     onPressed: () {
        //       _showFilterDialog(context);
        //     },
        //   ),
        // ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.searchQuery.isEmpty
            ? FirebaseFirestore.instance
                .collection('Users')
                .where('role', isEqualTo: widget.role)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('Users')
                .where('role', isEqualTo: widget.role)
                .where('username', isGreaterThanOrEqualTo: widget.searchQuery)
                .where('username', isLessThan: widget.searchQuery + 'z')
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white),
              ),
            );
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
                  final otherUserId=data['uid'];
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
                                  radius: 24,
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
                            ? TextStyle(
                                color: const Color.fromARGB(255, 26, 24, 46))
                            : TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['university'] ?? data['role'],
                            style: isOnline
                                ? TextStyle(
                                    color: Color.fromARGB(151, 26, 24, 46))
                                : TextStyle(color: Colors.white60)),
                        if (selectedTopics.isNotEmpty)
                          Text('Research Topics: $topicTitles',
                              style: isOnline
                                  ? TextStyle(
                                      color: Color.fromARGB(151, 26, 24, 46))
                                  : TextStyle(color: Colors.white60)),
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
//   void _showFilterDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Filter by University'),
//         content: TextField(
//           onChanged: (value) {
//             setState(() {
//               _searchUniversity = value.trim();
//             });
//           },
//           decoration: InputDecoration(
//             hintText: 'Enter University Name',
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Clear'),
//             onPressed: () {
//               setState(() {
//                 _searchUniversity = null;
//               });
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Apply'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
