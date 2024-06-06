import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Re-authenticate the user
          String email = user.email!;
          AuthCredential credential = EmailAuthProvider.credential(
            email: email,
            password: _oldPasswordController.text,
          );

          await user.reauthenticateWithCredential(credential);

          // Update the password
          await user.updatePassword(_newPasswordController.text);

          // Optionally update the password in Firestore if it's stored there
          await FirebaseFirestore.instance.collection("Users").doc(user.uid).update({
            'password': _newPasswordController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        title: Text("reset password",style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        leading: const Icon(Icons.restore,
            color: Color.fromARGB(255, 255, 240, 223)),)
            ,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 240, 223)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Reset Password'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: const Color.fromARGB(255, 255, 240, 223),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
