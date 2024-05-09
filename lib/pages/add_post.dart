import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 24, 46),
        title: Text('Add Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Enter your post'),
              style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                var username = await _getUsername(currentUser!.uid);

                await FirebaseFirestore.instance.collection("Posts").add({
                  'userId': currentUser.uid,
                  'text': _textController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                  'username': username,
                });

                Navigator.pop(context);
              },
              child: Text('Post',style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(128, 0, 128, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to get username from the user document
  Future<String> _getUsername(String userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>?;

    return userData?['username'] ?? 'Unknown User';
  }
}