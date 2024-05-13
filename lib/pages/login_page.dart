import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resapp/components/error.dart';
import 'package:resapp/components/forget_password.dart';
import 'package:resapp/components/mytextfield.dart';
import 'package:resapp/pages/HomePage.dart';
import 'package:resapp/pages/sign_up.dart';
class LoginPage extends StatefulWidget {
 
  LoginPage({super.key });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  void login() async {
  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    late String email;
    if (emailController.text.contains('@')) {
      // Use the input as email
      email = emailController.text;
    } else {
      // Use the input as username and fetch the corresponding email from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("username", isEqualTo: emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        email = querySnapshot.docs.first.get("email");
      } else {
        throw FirebaseAuthException(code: 'user-not-found');
      }
    }

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: passwordController.text,
    );

    // Fetching the role from Firestore
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((doc) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => CustomErrorDialog(message: e.message ?? 'An error occurred'),
    );
  }
}

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 26, 24, 46),
        body: Padding(
          padding: const EdgeInsets.all(22.0),
          child:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.person,//will add logo here
                size: 80,
                color: Color.fromARGB(255, 255, 240, 223)),
            const SizedBox(height: 24),
            const Text("L O G  I N", style: TextStyle(fontSize: 20,
            color:Color.fromARGB(255, 255, 240, 223))),
            const SizedBox(height: 10),
            MyTextField(
              hintText: "email or username",
              obscureText: false,
              controller: emailController,
            ),
            const SizedBox(height: 8),
            MyTextField(
              
              hintText: "Your password",
              obscureText: true,
              controller: passwordController,
              
            ),
            
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: login,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 240, 223)),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child:const Text("Login",style: TextStyle(color: Color.fromARGB(255, 65, 64, 64)),)),
                const SizedBox(height: 4.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("create a new account ",style: TextStyle(color:const Color.fromARGB(255, 255, 240, 223)),),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the login page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text(
                      "sign up",
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
                const SizedBox(height:10),
            PasswordResetWidget(),
          ]),
        ));
  }
}
