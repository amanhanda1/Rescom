import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactus extends StatefulWidget {
  @override
  _ContactusState createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  void _openLinkedIn() async {
    const url = 'https://www.linkedin.com/company/res-com/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openEmail() async {
    const email = 'mailto:';
    if (await canLaunch(email)) {
      await launch(email);
    } else {
      throw 'Could not launch $email';
    }
  }

  void _openTwitter() async {
    // Add your X (Twitter) link here
  }

  void _openInstagram() async {
    // Add your Instagram link here
  }

  Widget _buildContactBox({required IconData icon, required String label, required VoidCallback onTap, bool isFaIcon = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,  // Adjust the width as needed
        height: 150, // Adjust the height as needed
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isFaIcon ? FaIcon(icon, size: 40, color: Colors.white) : Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        title: Text('Contact us'),
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
      ),
      body: Center(  // Center the GridView
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,  // Adjust the GridView to its content
            children: [
              _buildContactBox(
                icon: FontAwesomeIcons.linkedin,
                label: 'LinkedIn',
                onTap: _openLinkedIn,
                isFaIcon: true,
              ),
              _buildContactBox(
                icon: FontAwesomeIcons.envelope,
                label: 'Email',
                onTap: _openEmail,
                isFaIcon: true,
              ),
              _buildContactBox(
                icon: FontAwesomeIcons.xTwitter, // Change this to a suitable icon for Twitter (X)
                label: 'Twitter (X)',
                onTap: _openTwitter,
                isFaIcon: true,
              ),
              _buildContactBox(
                icon: FontAwesomeIcons.instagram, // Change this to a suitable icon for Instagram
                label: 'Instagram',
                onTap: _openInstagram,
                isFaIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
