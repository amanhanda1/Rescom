import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController GenderController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController linkedInController = TextEditingController();
  TextEditingController researchGateController = TextEditingController();
  String? _username;
  String? _bio;
  User? _user;
  String? _linkedInUrl;
  String? _researchGateUrl;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection("Users")
          .doc(_user!.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _username = userData.get('username');
          _bio = userData.get('bio');
          _linkedInUrl = userData.get('linkedInUrl');
          _researchGateUrl = userData.get('researchGateUrl');
          nameController.text = _username ?? '';
          bioController.text = _bio ?? '';
          linkedInController.text = _linkedInUrl ?? '';
          researchGateController.text = _researchGateUrl ?? '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
  if (_user != null) {
    String username = nameController.text.trim();
    String bio = bioController.text.trim();
    String linkedInUrl = linkedInController.text.trim();
    String researchGateUrl = researchGateController.text.trim();
    String gender = GenderController.text.trim();

    Map<String, dynamic> updateData = {};

    if (username.isNotEmpty) {
      updateData['username'] = username;
    }
    if (bio.isNotEmpty) {
      updateData['bio'] = bio;
    }
    if (linkedInUrl.isNotEmpty) {
      updateData['linkedInUrl'] = linkedInUrl;
    }
    if (researchGateUrl.isNotEmpty) {
      updateData['researchGateUrl'] = researchGateUrl;
    }
    if (gender.isNotEmpty) {
      updateData['Gender'] = gender;
    }

    // Update only if there is data to update
    if (updateData.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(_user!.uid)
          .update(updateData);

      setState(() {
        if (updateData.containsKey('username')) _username = username;
        if (updateData.containsKey('bio')) _bio = bio;
        if (updateData.containsKey('linkedInUrl')) _linkedInUrl = linkedInUrl;
        if (updateData.containsKey('researchGateUrl')) _researchGateUrl = researchGateUrl;
      });
    }

    // Show the AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Profile Updated"),
          content: Text("Please refresh the app to see the changes."),
        );
      },
    );

    // Close the dialog after 3.5 seconds and navigate back
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the AlertDialog
      Navigator.pop(context); // Navigate back
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(249, 148, 83, 189),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(249, 148, 83, 189),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter Name',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: bioController,
              maxLength: 250,
              decoration: const InputDecoration(
                hintText: 'Enter Bio(Max:250 words)',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: linkedInController,
              decoration: const InputDecoration(
                hintText: 'Enter LinkedIn URL',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: researchGateController,
              decoration: const InputDecoration(
                hintText: 'Enter ResearchGate URL',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: GenderController,
              decoration: const InputDecoration(
                hintText: 'Gender',
                hintStyle: TextStyle(color: Color.fromARGB(250, 24, 0, 39)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(250, 24, 0, 39),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
