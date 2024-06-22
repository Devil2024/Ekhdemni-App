import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to home screen or do something else
      Navigator.pushReplacementNamed(context, '/home'); // Navigate to home screen after login
    } catch (e) {
      // Show error message
      print(e);
      // Optionally, you can show an error message dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D0F46),
                Color.fromARGB(255, 0, 0, 0),
                Color(0xFF0D0F46),
              ],
              stops: [0.2, 0.5, 0.8],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/login.png',
                  width: 150, // Adjust the width as needed
                  height: 150, // Adjust the height as needed
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white), // Set text color to white
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white), // Set label color to white
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set underline color to white
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set underline color to white
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white), // Set text color to white
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white), // Set label color to white
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set underline color to white
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set underline color to white
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      minimumSize: const Size(double.infinity - 20, 50),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Don't forget your password",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Color.fromARGB(255, 254, 254, 254)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
