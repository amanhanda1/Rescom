import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResearchPapersWidget extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const ResearchPapersWidget({
    Key? key,
    required this.userId,
    required this.isOwnProfile,
  }) : super(key: key);

  @override
  _ResearchPapersWidgetState createState() => _ResearchPapersWidgetState();
}

class _ResearchPapersWidgetState extends State<ResearchPapersWidget> {
  List<String> downloadUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchDownloadUrls();
  }

  Future<void> _fetchDownloadUrls() async {
    print('Fetching download URLs...');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("ResearchPapers")
          .doc(widget.userId)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('papers')) {
          downloadUrls = List<String>.from(data['papers']);
          print('Download URLs: $downloadUrls');
        } else {
          print('No papers found in the document.');
        }
      } else {
        print('Document does not exist for user ${widget.userId}.');
      }
    } catch (e) {
      print('Error fetching download URLs: $e');
    }
    setState(() {});
    print('Download URLs fetched successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Research Papers:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (downloadUrls.isEmpty)
          const Text("No research papers available"),
        ...downloadUrls.map((downloadUrl) => _buildPaperItem(downloadUrl)),
        if (widget.isOwnProfile)
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: _pickPDFFile,
                    child: Text(
                      "Select PDF",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickPDFFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileName = file.name;
      Uint8List bytes = file.bytes!;
      await addPaperToFirestore(widget.userId, fileName, bytes);
      _fetchDownloadUrls();
    } else {
      // User canceled the file picker
    }
  }

  Future<void> addPaperToFirestore(String userId, String fileName, Uint8List bytes) async {
    String downloadUrl = await uploadPDFToStorage(userId, fileName, bytes);
    if (downloadUrl.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("ResearchPapers")
          .doc(userId)
          .update({
        'papers': FieldValue.arrayUnion([downloadUrl]),
      });
    }
  }

  Future<String> uploadPDFToStorage(String userId, String fileName, Uint8List bytes) async {
    try {
      firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage
          .instance
          .ref()
          .child('researchPapers/$userId/$fileName');

      firebase_storage.UploadTask uploadTask = storageRef.putData(bytes);
      await uploadTask.whenComplete(() => null);

      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      return '';
    }
  }

  Widget _buildPaperItem(String downloadUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _handlePaperTap(downloadUrl),
        child: Row(
          children: [
            Icon(Icons.file_download, color: Colors.white),
            const SizedBox(width: 8.0),
            Text(
              downloadUrl,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaperTap(String downloadUrl) async {
    if (await canLaunch(downloadUrl)) {
      await launch(downloadUrl);
    } else {
      Text("Error opening the file");
    }
  }
}
