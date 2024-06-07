import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resapp/components/custom_nav_bar.dart';
import 'package:resapp/messaging/allmessages.dart';
import 'package:resapp/pages/Profile_page.dart';
import 'package:resapp/pages/add_post.dart';
import 'package:resapp/pages/add_user.dart';
import 'package:resapp/pages/notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer? _periodicTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updateLastSeen();

    // Update last seen every 5 minutes
    _periodicTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      updateLastSeen();
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateLastSeen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User denied notification permission');
    }
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

  void navigateToNotificationPage(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationPage(userId: currentUser.uid),
        ),
      );
    }
  }

  void navigateToProfilePage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: userId),
      ),
    );
  }

  void navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUser()),
    );
  }

  void navigateToChatPage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => allMessages(userId: userId),
      ),
    );
  }

  Future<void> _refreshHome() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
  }

  void navigateToHomePage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        leading:
            const Icon(Icons.home, color: Color.fromARGB(255, 255, 240, 223)),
        actions: [
          IconButton(
            onPressed: () => navigateToNotificationPage(context),
            icon: Icon(Icons.notifications),
            color: const Color.fromARGB(255, 255, 240, 223),
          ),
        ],
        title: const Text(
          "P O S T S",
          style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color.fromARGB(255, 255, 240, 223),
          unselectedLabelColor: Color.fromARGB(128, 255, 240, 223),
          indicatorColor: Color.fromARGB(255, 255, 240, 223),
          tabs: const [
            Tab(text: "My Feed"),
            Tab(text: "All Posts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildMyFeedStream(),
          buildPostsStream(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostPage(),
            ),
          );
        },
        autofocus: true,
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 240, 223)),
      ),
      bottomNavigationBar: cNavigationBar(
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
        onHomePressed: navigateToHomePage,
        onAdduserPressed: navigateToAddUser,
        onChatPressed: () =>
            navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
      ),
    );
  }

  Widget buildPostsStream() {
    return RefreshIndicator(
      onRefresh: () => _refreshHome(),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Posts')
          .orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final posts = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              final userId = post['userId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return Container();
                  }

                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;

                  return Card(
                    elevation: 5,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white.withOpacity(0.26),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        post['text'] ?? '',
                        style: TextStyle(
                          fontFamily: GoogleFonts.nunito().fontFamily,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromARGB(255, 255, 240, 223),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Posted by: ${userData?['username'] ?? 'Unknown User'}' +
                                ' (${(userData?['university'] ?? '')})',
                            style: TextStyle(
                              fontFamily: GoogleFonts.aBeeZee().fontFamily,
                              fontSize: 12,
                              color: Color.fromARGB(255, 164, 159, 152),
                            ),
                          ),
                          Text(
                            _formatDateTime(post['timestamp'] as Timestamp? ??
                                Timestamp.now()),
                            style: TextStyle(
                              fontFamily: GoogleFonts.lobster().fontFamily,
                              fontSize: 9.8,
                              color: Color.fromARGB(255, 164, 159, 152),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        navigateToProfilePage(userId);
                      },
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

  Widget buildMyFeedStream() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text('No user signed in.'));
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Supportings')
          .get(),
      builder: (context, supportingSnapshot) {
        if (supportingSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (supportingSnapshot.hasError || !supportingSnapshot.hasData) {
          return Center(child: Text('Error: ${supportingSnapshot.error}',style: TextStyle(color: Colors.white),));
        }

        final supportingIds =
            supportingSnapshot.data?.docs.map((doc) => doc.id).toList() ?? [];
        supportingIds.add(currentUser.uid); // Add current user's ID to the list

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Posts')
              .where('userId', whereIn: supportingIds)
              .orderBy('timestamp', descending: true) // Order by timestamp
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print({snapshot.error});
              return Center(child: Text("Error: ${snapshot.error}",style: TextStyle(color: Colors.white)));
              
            }

            final posts = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                final userId = post['userId'] as String;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return Container();
                    }

                    final userData =
                        userSnapshot.data?.data() as Map<String, dynamic>?;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white.withOpacity(0.26),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          post['text'] ?? '',
                          style: TextStyle(
                            fontFamily: GoogleFonts.nunito().fontFamily,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromARGB(255, 255, 240, 223),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Posted by: ${userData?['username'] ?? 'Unknown User'}' +
                                  '(${(userData?['university'] ?? '')})',
                              style: TextStyle(
                                fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                fontSize: 12,
                                color: Color.fromARGB(255, 164, 159, 152),
                              ),
                            ),
                            Text(
                              _formatDateTime(post['timestamp'] as Timestamp? ??
                                  Timestamp.now()),
                              style: TextStyle(
                                fontFamily: GoogleFonts.lobster().fontFamily,
                                fontSize: 9.8,
                                color: Color.fromARGB(255, 164, 159, 152),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          navigateToProfilePage(userId);
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
    );
  }

  String _formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    if (dateTime == null) {
      return 'Unknown Date and Time';
    }
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }
}
