import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'home_screen.dart';
import 'video_record_screen.dart';
import 'voice_record_screen.dart';
import 'uploads_screen.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'chatbot_screen.dart';
import 'Widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echoseal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/SignIn',
        routes: {
          '/SignIn': (context) => SigninScreen(),
          '/Signup': (context) => SignupScreen(),
          '/Welcome': (context) => WelcomeScreen(),
          '/Home': (context) => HomeScreen(),
          '/VideoRecord': (context) => VideoRecordScreen(),
          '/VoiceRecord': (context) => VoiceRecordScreen(),
          '/Uploads': (context) => UploadsScreen(),
          '/Profile': (context) => ProfileScreen(),
          '/Settings': (context) => SettingsScreen(),
          '/Support': (context) => SupportScreen(),
          '/Chatbot': (context) => ChatbotScreen(),
      },
    );
  }
}
















