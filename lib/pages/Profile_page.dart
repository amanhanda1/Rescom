// import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resapp/components/Profile_photo.dart';
import 'package:resapp/components/custom_nav_bar.dart';
import 'package:resapp/components/edit_profile.dart';
import 'package:resapp/components/friend_button.dart';
import 'package:resapp/components/friend_count.dart';
import 'package:resapp/components/show_posts.dart';
import 'package:resapp/messaging/allmessages.dart';
import 'package:resapp/messaging/chatroom.dart';
import 'package:resapp/pages/First_page.dart';
import 'package:resapp/pages/HomePage.dart';
import 'package:resapp/pages/add_user.dart';
import 'package:resapp/pages/interest_page.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showPosts = true;
  void navigateToProfilePage() {}
  void logout() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FirstPage(),
        ),
      );
    }
  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void navigateToAddUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AddUser()),
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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = widget.userId == currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        leading: const Icon(Icons.person_outlined),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: const Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "P R O F I L E",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
                ),
              ),
            ),
          ],
        ),
        actions: isOwnProfile?[
          // Add PopupMenuButton
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                logout();
              }
              else if(value=='edit topics'){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResearchTopicSelection()));
              }
              
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                  title: Text('edit topics'),
                ),
              ),
            ],
          ),
        ]:null,
      ),
      body: FutureBuilder<DocumentSnapshot>(
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
          final bio = userData['bio'] ?? '';
          final universityName = userData['university'] ?? '';
          final photoUrl = userData['photoUrl'] ?? '';
          final linkedInUrl = userData['linkedInUrl'] ?? '';
          final researchGateUrl = userData['researchGateUrl'] ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    "P R O F I L E",
                    style: TextStyle(
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
                          "Name: $name ",
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
                        Colors.orange.shade800,
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
                    color: Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: Colors.orange,
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
                      if(researchGateUrl.isNotEmpty)
                      _buildResGAteButton(researchGateUrl),
                  ],
                ),

                // Build LinkedIn button
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 20,
                ),
                const SizedBox(height: 8),
                    PostsWidget(userId: widget.userId)
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: cNavigationBar(
        onProfileIconPressed: navigateToProfilePage,
        onHomePressed: navigateToHomePage,
        onAdduserPressed: navigateToAddUser,
        onChatPressed:() =>
            navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
      ),
    );
  }

  Widget _buildLinkedInButton(String linkedInUrl) {
    return TextButton(
      onPressed: () {
          _launchURL(linkedInUrl);
      },
      child: const Text('LinkedIn'),
    );
  }

  Widget _buildResGAteButton(String researchGateUrl) {
    return TextButton(
      onPressed: () {
          _launchURL(researchGateUrl);
      },
      child: const Text('Res Gate'),
    );
  }

  // Function to launch URL using url_launcher
  void _launchURL(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
