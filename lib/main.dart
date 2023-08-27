import 'package:exam_appointments/screen/login_screen.dart';
import 'package:exam_appointments/screen/main_screen.dart';
import 'package:exam_appointments/screen/registration_screen.dart';
import 'package:exam_appointments/screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'welcome_screen',
      routes: {
        'welcome_screen': (context) => WelcomeScreen(),
        'registration_screen': (context) => RegistrationScreen(),
        'login_screen': (context) => LoginScreen(),
        'home_screen': (context) => const MainScreen(
              title: 'Exams',
            )
      },
    );
  }
}
