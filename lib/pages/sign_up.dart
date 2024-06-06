import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:resapp/components/error.dart';
import 'package:resapp/components/mytextfield.dart';
import 'package:resapp/components/showuniversities.dart';
import 'package:resapp/pages/interest_page.dart';
import 'package:resapp/pages/login_page.dart';
import 'package:resapp/pages/termsandcondition.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  DateTime? selectedDate;
  String? selectedUniversity;
  String? selectedRole;
  bool _acceptTerms = false;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:
                const Color.fromARGB(128, 0, 128, 1), // Set the primary color
            colorScheme:
                ColorScheme.light(primary: Color.fromARGB(206, 49, 50, 50)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void setUniversity(String university) {
    setState(() {
      selectedUniversity = university;
    });
  }

  Future<void> _showTermsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Please accept the terms and conditions before signing up.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void registerUser() async {
    if (!_acceptTerms) {
      await _showTermsDialog();
      return;
    }
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    // Confirming the password
    if (passwordController.text != cpasswordController.text) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) =>
            CustomErrorDialog(message: "Password doesn't match"),
      );
    }
    // Creating the user
    else {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        await createUserDocument(
            userCredential, selectedDate, selectedUniversity, selectedRole);

        // Fetching the role from Firestore
        FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user?.uid)
            .get()
            .then((doc) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ResearchTopicSelection()));
        });
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) =>
              CustomErrorDialog(message: e.message ?? 'An error occurred'),
        );
      }
    }
  }

  Future<void> createUserDocument(
    UserCredential? userCredential,
    DateTime? dob,
    String? university,
    String? role,
  ) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid) // Store user UID as document ID
          .set({
        'email': emailController.text,
        'uid': userCredential.user!.uid, // Store user UID
        'username': usernameController.text,
        'password': passwordController.text,
        'dob': dob,
        'linkedInUrl': '',
        'researchGateUrl': '',
        'Gender': '',
        'role': role,
        'university': university ?? '',
        'lastseen': FieldValue.serverTimestamp(),
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person,
                  size: 80, color: Color.fromARGB(255, 255, 240, 223)),
              const SizedBox(height: 24),
              const Text("R E S C O M",
                  style: TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 255, 240, 223))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: MyTextField(
                      hintText: "First Name",
                      obscureText: false,
                      controller: firstNameController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyTextField(
                      hintText: "Last Name",
                      obscureText: false,
                      controller: lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "UserName",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "abc@gmail.com(preferred official)",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 8),
              MyTextField(
                hintText: "Your password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 8),
              MyTextField(
                hintText: "Confirm password",
                obscureText: true,
                controller: cpasswordController,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: selectedRole,
                    hint: const Text('Select Role',
                        style: TextStyle(
                            color: Color.fromARGB(
                                255, 255, 240, 223))), // Placeholder text
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue;
                      });
                    },
                    style:
                        const TextStyle(color: Color.fromARGB(255, 26, 24, 46)),
                    dropdownColor: Color.fromARGB(255, 26, 24, 46),
                    items: <String>[
                      'Student',
                      'Teacher',
                      'Job',
                      'Researcher'
                    ] // Dropdown items
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 240, 223)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 255, 240, 223)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_month_sharp),
                        Text("   "),
                        Text("DoB",
                            style: TextStyle(
                              color: Color.fromARGB(249, 5, 1, 9),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  if (!kIsWeb) // Check if not running on web
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 255, 240, 223)),
                      ),
                      onPressed: () async {
                        // Navigate to university list and get the selected university
                        String? selectedUniversity =
                            await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UniversityListScreen(),
                          ),
                        );
                        setUniversity(selectedUniversity!);
                      },
                      child: const Text("SELECT YOUR UNIVERSITY",
                          style: TextStyle(
                            color: Color.fromARGB(249, 5, 1, 9),
                          )),
                    ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text("I accept to ",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 240, 223))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TAC()),
                      );
                    },
                    child: Text(
                      "Terms and Conditions",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                  Text(" and ",style: const TextStyle(
                          color: Color.fromARGB(255, 255, 240, 223))),
                  GestureDetector(
                    onTap: () async {
                      const url =
                          'https://www.termsfeed.com/live/fe128def-6789-425b-b946-f978b8f2879d';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text(
                      "privacy policy",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: registerUser,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 255, 240, 223)),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child: const Text(
                  "SignUp",
                  style: TextStyle(
                    color: Color.fromARGB(249, 5, 1, 9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 240, 223))),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the login page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
