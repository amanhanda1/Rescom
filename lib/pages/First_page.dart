import 'package:flutter/material.dart';
import 'package:resapp/pages/login_page.dart';
import 'package:resapp/pages/sign_up.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Create a Tween animation for zooming out
    _animation = Tween<double>(
      begin: 0.2, // Initial scale factor (you can adjust this based on your preference)
      end: 1.0, // Final scale factor
    ).animate(_animationController);

    // Start the animation
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 24, 46),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "R E S C O M",
                style: TextStyle(
                  color: Color.fromARGB(255, 233, 233, 236),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToLoginPage(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 240, 223)),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child: const Text(
                  "L O G I N",
                  style: TextStyle(
                    color: Color.fromARGB(249, 5, 1, 9),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  _navigateToSignUpPage(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 240, 223)),
                  minimumSize: MaterialStateProperty.all(const Size(999, 44)),
                ),
                child: const Text(
                  "N E W  U S E R ?",
                  style: TextStyle(
                    color: Color.fromARGB(249, 5, 1, 9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _navigateToSignUpPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  RegisterPage()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
