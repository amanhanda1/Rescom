import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:resapp/components/custom_unis.dart';

class UniversityListScreen extends StatefulWidget {
  const UniversityListScreen({super.key});

  @override
  UniversityListScreenState createState() => UniversityListScreenState();
}

class UniversityListScreenState extends State<UniversityListScreen> {
  String searchText = '';
  List<dynamic> universities = [];
  bool _isFetchingData = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _isFetchingData = false;
    super.dispose();
  }

  Future<void> saveUniversityToFirestore(User? user, String universityName) async {
    if (user != null && user.email != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .set({
        'university': universityName,
      }, SetOptions(merge: true));
      print('University saved successfully!');
    }
  }

  Future<void> fetchData() async {
    if (!_isFetchingData) {
      _isFetchingData = true;
      try {
        final response = await http.get(
          Uri.parse('https://rescom.amanhanda446.workers.dev/search?name=$searchText'), // Use the Cloudflare Worker URL
        );

        if (response.statusCode == 200) {
          final List<dynamic> apiUniversities = json.decode(response.body);
          final customUniversities = CustomUniversities.getUniversities();

          if (mounted) {
            setState(() {
              universities = [...apiUniversities, ...customUniversities];
            });
          }
        } else {
          throw Exception('Failed to load universities');
        }
      } catch (e) {
        print('Error fetching data: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching data: $e'),
            ),
          );
        }
      } finally {
        _isFetchingData = false;
      }
    }
  }

  List<dynamic> getFilteredUniversities() {
    return universities
        .where((university) => university['name']
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    context.read<User?>();

    if (universities.isEmpty) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(206, 41, 152, 128),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Loading the universities",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    List<dynamic> filteredUniversities = getFilteredUniversities();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 24, 46),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("R E S")],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                  fetchData();
                },
                decoration: const InputDecoration(
                  labelText: 'Search University',
                  prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 255, 240, 223)),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
                ),
                style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),
              ),
            ),
            Expanded(
              child: filteredUniversities.isEmpty
                  ? const Center(
                      child: Text(
                        "No universities found",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredUniversities.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Color.fromARGB(125, 236, 239, 238),
                          child: ListTile(
                            title: Text(filteredUniversities[index]['name']!),
                            subtitle: Text(filteredUniversities[index]['country']!),
                            onTap: () async {
                              Navigator.pop(context, filteredUniversities[index]['name']);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
