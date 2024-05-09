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
        // You may want to show a success message to the user.
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog();
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
              child: Text('OK',style: TextStyle(color: Colors.black45),),
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
                    color: Color.fromARGB(249, 5, 1, 9),
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
