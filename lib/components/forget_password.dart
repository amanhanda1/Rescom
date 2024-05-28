import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetWidget extends StatefulWidget {
  @override
  _PasswordResetWidgetState createState() => _PasswordResetWidgetState();
}

class _PasswordResetWidgetState extends State<PasswordResetWidget> {
  late TextEditingController _emailController;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        // Password reset email sent successfully.
        // Now update the password in Firestore if needed.
        // For example:
        // 1. Get the user document from Firestore using email
        // 2. Retrieve the UID from the document
        // 3. Update the password field in the document
        // 4. Save the changes to Firestore

        // Get the user document from Firestore using email
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot userDoc = snapshot.docs.first;

          // Update the password field in the document (replace 'password' with your field name)
          await userDoc.reference.update({'password': 'changed'});

          // Password reset email sent successfully.
          // You may want to show a success message to the user.
          setState(() {
            _isLoading = false;
          });
          _showSuccessDialog();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User not found.';
          });
        }
      } catch (e) {
        // An error occurred while sending the password reset email.
        // You may want to show an error message to the user.
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error sending password reset email: $e';
        });
      }
    } else {
      // Handle the case where email is empty.
      setState(() {
        _isLoading = false;
        _errorMessage = 'Email cannot be empty.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Password reset email has been sent.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email",
          ),
        ),
        SizedBox(height: 16.0),
        GestureDetector(
          onTap: _isLoading ? null : _resetPassword,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 26, 24, 46),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red),
          ),
        if (_isLoading) CircularProgressIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
