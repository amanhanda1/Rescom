import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/Profile_photo.dart';
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
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: Row(
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .collection(isFollowers ? 'Friends' : 'Supportings')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
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
            return const Center(
              child: Text('No friends yet.'),
            );
          }
          return FutureBuilder<List<Map<String, String?>>>(
            future: fetchUsernamesAndPhotos(friends),
            builder: (context, usernamesSnapshot) {
              if (usernamesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
              if (usernamesSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${usernamesSnapshot.error}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              final userInfos = usernamesSnapshot.data ?? [];
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friendInfo = userInfos[index];
                  final friendUsername =
                      friendInfo['username'] ?? 'Unknown User';
                  final friendUserId = friends[index].id;
                  final friendPhotoUrl = friendInfo['photoUrl'];

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
                          color: Color.fromARGB(137, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: ProfilePhotoWidget(
                                photoUrl: friendPhotoUrl,
                                userId: friendUserId,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              friendUsername,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 255, 240, 223),
                              ),
                            ),
                          ],
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

  Future<List<Map<String, String?>>> fetchUsernamesAndPhotos(
    List<QueryDocumentSnapshot<Object?>> friends) async {
  final List<Map<String, String?>> userInfos = [];
  for (final friend in friends) {
    final friendEmail = friend.id;
    final userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(friendEmail)
        .get();
    if (userData.exists) {
      final username = userData['username'] as String;
      final photoUrl = userData.data()?.containsKey('photoUrl') == true
          ? userData['photoUrl'] as String?
          : null;
      userInfos.add({
        'username': username,
        'photoUrl': photoUrl ?? null
      });
    } else {
      userInfos.add({
        'username': 'Unknown User',
        'photoUrl': null
      });
    }
  }
  return userInfos;
}
}
