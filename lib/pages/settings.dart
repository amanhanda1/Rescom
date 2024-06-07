import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:resapp/components/edit_profile.dart';
import 'package:resapp/pages/First_page.dart';
import 'package:resapp/pages/ResetPassword.dart';
import 'package:resapp/pages/contact_us.dart';
import 'package:resapp/pages/feedback_page.dart';
import 'package:resapp/pages/notificationturner.dart';
import 'package:resapp/pages/termsandcondition.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    void navigateToFeedback() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedbackPage()),
      );
    }

    void navigateTotac() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TAC()),
      );
    }
    void navigateTocontactus() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Contactus()),
      );
    }

    void navigateToresetPassword() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordPage()),
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

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        leading: const Icon(Icons.settings,
            color: Color.fromARGB(255, 255, 240, 223)),
        title: Text("Settings",
            style: TextStyle(color: Color.fromARGB(255, 255, 240, 223))),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Profile Information',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
          ),
         ListTile(
  leading: Icon(Icons.notifications, color: const Color.fromARGB(255, 255, 240, 223)),
  title: Text('Notification Settings', style: TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationSettingsPage()),
    );
  },
),
          ListTile(
            leading: Icon(Icons.security,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Security Settings',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: navigateToresetPassword,
          ),
          ListTile(
            leading: Icon(Icons.feedback,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Feedback',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: navigateToFeedback,
          ),
          ListTile(
            leading: Icon(Icons.contact_page,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Contact us',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: navigateTocontactus,
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.squareLetterboxd,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Privacy policy',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: () async {
              const url =
                  'https://www.termsfeed.com/live/fe128def-6789-425b-b946-f978b8f2879d';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('terms and conditions',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: navigateTotac,
          ),
          ListTile(
            leading: Icon(Icons.logout,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Log out',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: logout,
          ),
          ListTile(
            leading: Icon(Icons.delete,
                color: const Color.fromARGB(255, 255, 240, 223)),
            title: Text('Delete Account',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 240, 223))),
            onTap: () async {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Account Deletion"),
          content: Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteUserAccount(context);
              },
            ),
          ],
        );
      },
    );
  }
}

Future<void> deleteUserAccount(BuildContext context) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account deleted successfully.")),
      );
      // Navigate to FirstPage after account deletion
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FirstPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user signed in.")),
      );
    }
  } catch (e) {
    if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("You need to re-login before deleting your account.")),
      );
      // Optionally, prompt the user to reauthenticate
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: ${e.toString()}")),
      );
    }
  }
}
