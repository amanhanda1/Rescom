import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resapp/components/custom_nav_bar.dart';
import 'package:resapp/messaging/allmessages.dart';
import 'package:resapp/pages/Profile_page.dart';
import 'package:resapp/pages/add_post.dart';
import 'package:resapp/pages/add_user.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToProfilePage(String userId) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfilePage(userId: userId,)));
    }
    void navigateToAddUser(){
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AddUser()));
    }
    void navigateToChatPage(String userId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => allMessages(userId: userId),
        ),
      );
    }

    void navigateToHomePage() {}
    return Scaffold(
        
          backgroundColor: const Color.fromARGB(255, 26, 24, 46),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(128, 0, 128, 1),
            title: const Text(
              "P O S T S",
              style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
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
                final useId = post['userId'] as String;
      
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(useId)
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
                      color: Colors.white.withOpacity(0.42),
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
                              fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Posted by: ${userData?['username'] ?? 'Unknown User'}',
                                style: TextStyle(
                                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                    fontSize: 12,
                                    color:
                                        const Color.fromARGB(255, 39, 38, 38))),
                            Text(
                                '${userData?['university'] ?? 'Unknown University'}',
                                style: TextStyle(
                                    fontFamily: GoogleFonts.cardo().fontFamily,
                                    fontSize: 12,
                                    color:
                                        const Color.fromARGB(255, 39, 38, 38))),
                            const SizedBox(height: 2),
                            Text(
                                _formatDateTime(post['timestamp'] as Timestamp? ??
                                    Timestamp.now()),
                                style: TextStyle(
                                    fontFamily: GoogleFonts.lobster().fontFamily,
                                    fontSize: 9.8,
                                    color:
                                        const Color.fromARGB(255, 39, 38, 38))),
                          ],
                        ),
                        onTap: () {
                          navigateToProfilePage(useId);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),floatingActionButton: FloatingActionButton(
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
            onProfileIconPressed:()=> navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
            onHomePressed: navigateToHomePage,
            onAdduserPressed: navigateToAddUser,
            onChatPressed:() =>
              navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
          ));
    
  }
String _formatDateTime(Timestamp? timestamp) {
    final dateTime = timestamp?.toDate();
    if (dateTime == null) {
      return 'Unknown Date and Time';
    }
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }
}
