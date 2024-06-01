import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/User_role.dart';
import 'package:resapp/components/custom_nav_bar.dart';
import 'package:resapp/messaging/allmessages.dart';
import 'package:resapp/pages/HomePage.dart';
import 'package:resapp/pages/Profile_page.dart';
import 'package:resapp/pages/same_topic_users.dart';
import 'package:resapp/pages/same_uni_users.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  String _selectedRole = 'Student';
  String _searchQuery = '';
  String? _university;

  @override
  void initState() {
    super.initState();
    _fetchUniversity();
  }

  Future<void> _fetchUniversity() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (docSnapshot.exists) {
        setState(() {
          _university = docSnapshot.data()?['university'];
        });
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void navigateToAddUser() {}
  void navigateToProfilePage(String userId) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userId: userId,
                )));
  }

  void navigateToHomePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  void navigateToChatPage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => allMessages(userId: userId),
      ),
    );
  }

  void navigateToSameUserPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UsersPage()));
  }

  void navigateToSameuni() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => sameUniUsers()));
  }

  bool _checkOnlineStatus(dynamic lastSeen) {
    if (lastSeen is Timestamp) {
      final currentTime = Timestamp.now();
      final difference = currentTime.seconds - lastSeen.seconds;
      return difference < 300;
    }
    return false;
  }

  void updateLastSeen() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .update({'lastseen': FieldValue.serverTimestamp()});
    }
  }

  FocusNode _focusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: TextField(
                  focusNode: _focusNode,
                  controller: _searchController,
                  onChanged: _handleSearch,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search user or university',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              dropdownColor: Color.fromARGB(255, 26, 24, 46),
              items: <String>['Student', 'Teacher', 'Job', 'researcher']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Users for you') {
                navigateToSameUserPage();
              } else if (value == 'Users from same university') {
                navigateToSameuni();
              }
            },
            iconColor: const Color.fromARGB(255, 255, 240, 223),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Users for you',
                child: ListTile(
                  leading: Icon(Icons.groups_2_outlined),
                  title: Text('Users for you'),
                ),
              ),
              if (_university != null && _university!.isNotEmpty)
                const PopupMenuItem<String>(
                  value: 'Users from same university',
                  child: ListTile(
                    leading: Icon(Icons.school_rounded),
                    title: Text('Users from same university'),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: UserList(role: _selectedRole, searchQuery: _searchQuery),
      bottomNavigationBar: cNavigationBar(
        onProfileIconPressed: () =>
            navigateToProfilePage(FirebaseAuth.instance.currentUser!.uid),
        onHomePressed: navigateToHomePage,
        onAdduserPressed: () {},
        onChatPressed: () =>
            navigateToChatPage(FirebaseAuth.instance.currentUser!.uid),
      ),
    );
  }
}
