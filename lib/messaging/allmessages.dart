import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resapp/components/Profile_photo.dart';
import 'package:resapp/components/custom_nav_bar.dart';
import 'package:resapp/messaging/chatroom.dart';
import 'package:resapp/pages/HomePage.dart';
import 'package:resapp/pages/Profile_page.dart';
import 'package:resapp/pages/add_user.dart';

class allMessages extends StatefulWidget {
  final String userId;

  const allMessages({Key? key, required this.userId}) : super(key: key);

  @override
  _allMessagesState createState() => _allMessagesState();
}

class _allMessagesState extends State<allMessages> {
  final _navigationBarKey = GlobalKey<cNavigationBarState>();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // Listen to the Firestore stream for new messages
    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .collection('Conversations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      // Check if there are any new messages
      final hasNewMessage = await Future.wait(snapshot.docs.map((doc) async {
        final conversationId = doc['conversationId'];

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Conversations')
            .doc(conversationId)
            .collection('Messages')
            .where('senderUserId', isNotEqualTo: currentUser!.uid)
            .where('seen', isEqualTo: false)
            .get();

        return querySnapshot.docs.isNotEmpty;
      })).then((results) => results.contains(true));

      // Update the navigation bar with the new message status
      _navigationBarKey.currentState?.setNewMessageStatus(hasNewMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    void navigateToHomePage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }

    void navigateToAddUser() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const AddUser()));
    }

    void navigateToProfilePage(String userId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        leading: const Icon(Icons.message_outlined,
            color: Color.fromARGB(255, 255, 240, 223)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "C H A T S",
              style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.userId)
                  .collection('Conversations')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'No conversations yet.',
                    style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
                  ));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    String conversationId = doc['conversationId'];
                    String senderId = doc['senderUserId'];
                    String receiverId = doc['receiverUserId'];
                    String otherUserId =
                        senderId == currentUser!.uid ? receiverId : senderId;
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(otherUserId)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(); // Placeholder until data is loaded
                        }
                        if (userSnapshot.hasError) {
                          return Text('Error: ${userSnapshot.error}');
                        }
                        if (!userSnapshot.hasData ||
                            userSnapshot.data == null) {
                          return Container(); // Placeholder for empty user data
                        }
                        String otherUserName = userSnapshot.data!['username'];
                        Map<String, dynamic>? userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        String? photoUrl = userData?['photoUrl'];
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Conversations')
                              .doc(conversationId)
                              .collection('Messages')
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                            if (messageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(); // Placeholder until data is loaded
                            }
                            if (messageSnapshot.hasError) {
                              return Text('Error: ${messageSnapshot.error}');
                            }
                            if (!messageSnapshot.hasData ||
                                messageSnapshot.data!.docs.isEmpty) {
                              return Container(); // Placeholder for empty chat
                            }
                            String lastMessage =
                                messageSnapshot.data!.docs.first['message'];
                            bool hasNewMessage = messageSnapshot
                                    .data!.docs.first['senderUserId'] !=
                                currentUser!.uid;
                            bool isMessageSeen =
                                messageSnapshot.data!.docs.first['seen'] ??
                                    false;
                            bool showNewMessageIndicator = hasNewMessage &&
                                !isMessageSeen; // Updated condition
                            final timestamp =
                                messageSnapshot.data!.docs.first['timestamp'];

                            DateTime messageTime = timestamp.toDate();
                            DateTime now = DateTime.now();
                            bool isToday = now.year == messageTime.year &&
                                now.month == messageTime.month &&
                                now.day == messageTime.day;
                            String displayTime = isToday
                                ? DateFormat('HH:mm').format(messageTime)
                                : '${now.difference(messageTime).inDays} days ago';

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey.shade300,
                                  child: ProfilePhotoWidget(
                                    photoUrl: photoUrl,
                                    userId: otherUserId,
                                  ),
                                ),
                                title: Text(
                                  otherUserName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Color.fromARGB(255, 255, 240, 223)),
                                ),
                                subtitle: Text(
                                  lastMessage,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: showNewMessageIndicator
                                        ? Colors.blue
                                        : null,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (hasNewMessage && !isMessageSeen)
                                      CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        radius: 8.0,
                                      ),
                                    if (hasNewMessage && !isMessageSeen)
                                      SizedBox(
                                          height:
                                              4), // Adjust as needed for spacing
                                    Text(
                                      displayTime,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                          senderUserId: currentUser!.uid,
                                          receiverUserId: otherUserId),
                                    ),
                                  );
                                  FirebaseFirestore.instance
                                      .collection('Conversations')
                                      .doc(conversationId)
                                      .collection('Messages')
                                      .doc(messageSnapshot.data!.docs.first.id)
                                      .update({'seen': true});
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(
              height:
                  10), // Add some space between the list and the bottom navigation bar
        ],
      ),
      bottomNavigationBar: cNavigationBar(
        key: _navigationBarKey,
        onHomePressed: navigateToHomePage,
        onChatPressed: () {},
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
        onAdduserPressed: navigateToAddUser,
      ),
    );
  }
}
