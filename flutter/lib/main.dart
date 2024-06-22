import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/view/tabs_home.dart';

import 'view/home_screen.dart'; // Import HomeScreen
import 'view/login_screen.dart';
import 'view/register_screen.dart';
import 'view/welcome_screen.dart';
import 'view/chatbot_screen.dart'; // Import ChatbotScreen

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyAOIPKl6KFUwXsy5BRr6pgDAlf3lOAxDw4",
    appId: "1:444979620854:android:31a2ca1ea56072973b75d7",
    messagingSenderId: "444979620854",
    projectId: "my-app-bac05",
    storageBucket: "my-app-bac05.appspot.com",
  ));
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const TabsHome(), // Add HomeScreen route
        '/chatbot': (context) => ChatbotScreen(), // Add ChatbotScreen route
      },
    );
  }
}
