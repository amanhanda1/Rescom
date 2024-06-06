import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        setState(() {
          _userName = userDoc['username'];
          _userEmail = userDoc['email'];
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user data: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      String feedback = _feedbackController.text;

      try {
        await FirebaseFirestore.instance.collection('feedback').add({
          'name': _userName,
          'email': _userEmail,
          'feedback': feedback,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully!')),
        );
        _feedbackController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        title: Text('Feedback'),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      title: Text(
                        _userName ?? 'Name not available',
                        style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                      ),
                      subtitle: Text(
                        _userEmail ?? 'Email not available',
                        style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: 'Feedback',
                        labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 255, 240, 223)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 255, 240, 223)),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your feedback';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 240, 223)),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Color.fromARGB(249, 5, 1, 9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
