import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostsWidget extends StatefulWidget {
  final String userId;

  const PostsWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _PostsWidgetState createState() => _PostsWidgetState();
}

class _PostsWidgetState extends State<PostsWidget> {
  List<bool> editEnabledList = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Posts")
          .where('userId', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text("No posts found");
        }

        final posts = snapshot.data!.docs;

        return SingleChildScrollView(
          child: Column(
            children: [
              for (var index = 0; index < posts.length; index++)
                _buildPostTile(posts[index], index)
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostTile(DocumentSnapshot post, int index) {
    final bool isOwnProfile = post['userId'] == FirebaseAuth.instance.currentUser!.uid;
    return ListTile(
      title: Text(
        post['text'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            'Posted by: ${post['username']} on ',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color.fromARGB(224, 82, 81, 81),
            ),
          ),
          Text(
            _formatDateTime(
              post['timestamp'] as Timestamp? ?? Timestamp.now(),
            ),
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color.fromARGB(224, 82, 81, 81),
            ),
          ),
        ],
      ),
      tileColor: const Color.fromARGB(118, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Colors.black),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      trailing: isOwnProfile
        ? PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Call the function to edit the post
                _editPost(post.id, post['text'], index);
              } else if (value == 'delete') {
                // Call the function to delete the post
                _deletePost(post.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          )
        : null,
    );
  }

  String _formatDateTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }

  Future<void> _editPost(String postId, String currentText, int index) async {
    // Implement the logic for editing a post, for example, show a dialog with a text field
    // where the user can edit the post text and update it in the Firestore
    // Here is a simple example using a dialog:

    String newText = currentText;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post',style:TextStyle(color: Colors.black)),
        content: TextField(
          controller: TextEditingController(text: currentText),
          onChanged: (value) {
            newText = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',style:TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              // Update the post in Firestore
              await FirebaseFirestore.instance
                  .collection('Posts')
                  .doc(postId)
                  .update({'text': newText});

              Navigator.pop(context); // Close the dialog
              // Update the editEnabledList to disable editing for this post
              setState(() {
                editEnabledList[index] = false;
              });
            },
            child: const Text('Save',style:TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    

    await FirebaseFirestore.instance.collection('Posts').doc(postId).delete();
  }
}
