// import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resapp/components/Profile_photo.dart';
import 'package:resapp/components/custom_nav_bar.dart';
import 'package:resapp/components/edit_profile.dart';
import 'package:resapp/components/friend_button.dart';
import 'package:resapp/components/friend_count.dart';
import 'package:resapp/components/research_topics.dart';
import 'package:resapp/components/show_posts.dart';
import 'package:resapp/messaging/allmessages.dart';
import 'package:resapp/messaging/chatroom.dart';
import 'package:resapp/pages/First_page.dart';
import 'package:resapp/pages/HomePage.dart';
import 'package:resapp/pages/add_user.dart';
import 'package:resapp/pages/interest_page.dart';
import 'package:resapp/pages/settings.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool hasNewMessages = false;
  bool showPosts = true;
  @override
  void initState() {
    super.initState();
    
  }
  
  void navigateToProfilePage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: userId),
      ),
    );
  }
  

  void logout() async {
  try {
    // Sign out the user from Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // Navigate to the FirstPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const FirstPage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    // Handle any errors that occurred during logout
    print('Error signing out: $e');
  }
}

  void navigateToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUser()),
    );
  }

  void navigateToChatPage(String userId) {
    setState(() {
    hasNewMessages = false;
  });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => allMessages(userId: userId),
      ),
    );
  }
  Future<void> _refreshProfile(userId) async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: userId),
        ),
      );
      await Future.delayed(Duration(seconds: 2));
    }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = widget.userId == currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        leading: const Icon(Icons.person_outlined,
        color: const Color.fromARGB(255, 255, 240, 223)),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: const Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "P R O F I L E",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color.fromARGB(255, 255, 240, 223),fontWeight: FontWeight.w800,fontSize: 18),
                  
                ),
              ),
            ),
          ],
        ),
        actions: isOwnProfile
            ? [
                // Add PopupMenuButton
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      logout();
                    } else if (value == 'edit topics') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResearchTopicSelection(),
                        ),
                      );
                    } else if (value == 'settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    }
                  },
                  iconColor: const Color.fromARGB(255, 255, 240, 223),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    // Option 1: Logout
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit topics',
                      child: ListTile(
                        leading: Icon(Icons.edit_document),
                        title: Text('Edit Topics'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            _refreshProfile(FirebaseAuth.instance.currentUser!.uid),
        child:FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.userId)
            .get(),
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

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("User data not found"),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['username'] ?? '';
          final fname = userData['firstName'] ?? '';
          final lname = userData['lastName'] ?? '';
          final bio = userData['bio'] ?? '';
          final universityName = userData['university'] ?? '';
          final photoUrl = userData['photoUrl'] ?? '';
          final linkedInUrl = userData['linkedInUrl'] ?? '';
          final researchGateUrl = userData['researchGateUrl'] ?? '';
          final selectedTopics =
              List<String>.from(userData['selectedTopics'] ?? []);
          final topicTitles = selectedTopics
              .map((id) => researchTopics
                  .firstWhere((topic) => topic.id == id,
                      orElse: () => ResearchTopic(id: id, title: id))
                  .title)
              .join(', ');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                  "$name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 100, // Adjust width as needed
                  height: 100, // Adjust height as needed
                  child: ProfilePhotoWidget(
                    photoUrl: photoUrl.isNotEmpty ? photoUrl : null,
                    userId: widget.userId,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Name: $fname $lname",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.aBeeZee().fontFamily,
                          ),
                        ),
                        if (!isOwnProfile) ...[
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    senderUserId:
                                        currentUser!.uid, // Current user ID
                                    receiverUserId:
                                        widget.userId, // Profile user ID
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble,
                                color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Text(universityName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: GoogleFonts.josefinSans().fontFamily)),
                const SizedBox(height: 8),
                if (isOwnProfile)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(128, 0, 128, 1),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  )
                else
                  FriendButton(userId: widget.userId),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "$bio",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 240, 223),
                    backgroundColor: Color.fromARGB(92, 0, 128, 0),
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (linkedInUrl.isNotEmpty)
                      _buildLinkedInButton(linkedInUrl),
                    const Spacer(),
                    FriendCountWidget(userId: widget.userId),
                    const Spacer(),
                    if (researchGateUrl.isNotEmpty)
                      _buildResGateButton(researchGateUrl),
                  ],
                ),

                // Build LinkedIn button
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 20,
                ),
                Row(
                  children: [
                    const Text(
                      "Research Topics:",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 240, 223),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ' $topicTitles',
                        style: const TextStyle(color: Colors.white60),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 15,
                ),
                const SizedBox(height: 4.5),
                PostsWidget(userId: widget.userId)
              ],
            ),
          );
        },
      ),),
      bottomNavigationBar: cNavigationBar(
            onProfileIconPressed: () =>
                navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
            onHomePressed: navigateToHomePage,
            onAdduserPressed: navigateToAddUser,
            onChatPressed: () =>
                navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
          ),);
        }
      
  

  Widget _buildLinkedInButton(String linkedInUrl) {
    return TextButton(
      
      onPressed: () {
        _launchURL(linkedInUrl);
      },
      child: Row(
        children: [
          Icon(FontAwesomeIcons.linkedin,color:const Color.fromARGB(128, 0, 128, 1)),
          const Text('LinkedIn',style: TextStyle(color:Color.fromARGB(255, 255, 240, 223))),
        ],
      ),
    );
  }

  Widget _buildResGateButton(String researchGateUrl) {
    return TextButton(
      onPressed: () {
        _launchURL(researchGateUrl);
      },
      child: Row(
        children: [
          Icon(FontAwesomeIcons.researchgate,color:const Color.fromARGB(128, 0, 128, 1)),
          const Text('Res Gate',style: TextStyle(color:Color.fromARGB(255, 255, 240, 223))),
        ],
      ),
    );
  }

  // Function to launch URL using url_launcher
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!uri.hasScheme) {
      final uriWithScheme = Uri.parse('https://$url');
      if (await canLaunchUrl(uriWithScheme)) {
        await launchUrl(uriWithScheme);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
