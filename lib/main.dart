import 'package:flutter/material.dart';
import 'package:multitask_lab/screens/home.view.dart';
import 'package:tflite/tflite.dart';
import 'home.page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:multitask_lab/screens/login.view.dart';
import 'package:multitask_lab/screens/register.view.dart';
import 'package:multitask_lab/home.page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Tflite.loadModel(model: "models/fruits.tflite");
    print('Firebase Initialized Successfully!');
  } catch (e, stackTrace) {
    print('Firebase Initialization Failed: $e');
    print(stackTrace);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.white,
        ),
        indicatorColor: Colors.blueAccent,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomeView(),
        // Example route to HomePage.
      },
    );
  }
}