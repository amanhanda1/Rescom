import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/research_topics.dart';
import 'package:resapp/pages/HomePage.dart';

class ResearchTopicSelection extends StatefulWidget {
  @override
  _ResearchTopicSelectionState createState() => _ResearchTopicSelectionState();
}

class _ResearchTopicSelectionState extends State<ResearchTopicSelection> {
  List<ResearchTopic> selectedTopics = [];

  @override
  Widget build(BuildContext context) {
    void navigateToHomePage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(128, 0, 128, 1),
        title: Text('Select Research Topics'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: researchTopics.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(researchTopics[index].title,style: TextStyle(color: Color.fromARGB(255, 255, 240, 223)),),
                  value: researchTopics[index].isSelected,
                  onChanged: (value) {
                    setState(() {
                      researchTopics[index].isSelected = value!;
                      if (value) {
                        selectedTopics.add(researchTopics[index]);
                      } else {
                        selectedTopics.remove(researchTopics[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Save selected topics to Firestore
              saveSelectedTopicsToFirestore();
              navigateToHomePage();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveSelectedTopicsToFirestore() async {
    // Get the user's UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Create a reference to the user's document in Firestore
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(uid);

    // Update the user's document with the selected topics
    await userDocRef.update({
      'selectedTopics': selectedTopics.map((topic) => topic.id).toList(),
    });
  }
}
