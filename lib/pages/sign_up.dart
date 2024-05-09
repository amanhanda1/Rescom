import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/error.dart';
import 'package:resapp/components/mytextfield.dart';
import 'package:resapp/components/showuniversities.dart';
import 'package:resapp/pages/interest_page.dart';
class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  DateTime? selectedDate;
  String? selectedUniversity;
  String? selectedRole;
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

  void resisterUser() async {
  // Loading circle
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
  // Confirming the password
  if (passwordController.text != cpasswordController.text) {
    Navigator.pop(context);
    displayerror("Password does not match", context); // Function from helper
  }
  // Creating the user
  else {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
      await createUserDocument(userCredential, selectedDate, selectedUniversity,selectedRole);
      
      // Fetching the role from Firestore
      FirebaseFirestore.instance.collection("Users").doc(userCredential.user?.uid).get().then((doc) {
        
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResearchTopicSelection()));
    });

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayerror(e.code, context);
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
      'linkedInUrl':'',
      'researchGateUrl':'',
      'role': role,
      'university': university,
      'lastseen': FieldValue.serverTimestamp(),
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 26, 24, 46),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person,
                  size: 80,
                  color: Color.fromARGB(255, 255, 240, 223)),
              const SizedBox(height: 24),
              const Text("Z I N S A", style: TextStyle(fontSize: 20,color:Color.fromARGB(255, 255, 240, 223))),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "UserName",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: "abc@gmail.com",
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
                hintText: "confirm password",
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
                    hint: const Text('Select Role',style: TextStyle(color: Color.fromARGB(255, 255, 240, 223))), // Placeholder text
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue;
                      });
                    },
                    style: const TextStyle(color: Color.fromARGB(255, 26, 24, 46)),
                    dropdownColor: Color.fromARGB(255, 26, 24, 46),
                    items: <String>['Student', 'Teacher'] // Dropdown items
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,style: const TextStyle(color: Color.fromARGB(255, 255, 240, 223)),),
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
                        Text("DoB",style:TextStyle(color:Color.fromARGB(249, 5, 1, 9),)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 255, 240, 223)),
                    ),
                    onPressed: () async {
                      // Navigate to university list and get the selected university
                      String? selectedUniversity = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UniversityListScreen(),
                        ),
                      );
                      setUniversity(selectedUniversity!);
                    },
                    child: const Text("SELECT YOUR UNIVERSITY",style:TextStyle(color:Color.fromARGB(249, 5, 1, 9),)),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: resisterUser,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 240, 223)),
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
