import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_1/navigator/MainTanScreen.dart';
import 'package:taller_1/screens/LoginScreen.dart';
import 'package:taller_1/screens/RegisterScreen.dart';
import 'package:taller_1/screens/WelcomeScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Supabase.initialize(
    url: 'https://ysarhzuwigzcobcegief.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzYXJoenV3aWd6Y29iY2VnaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2ODM5MDksImV4cCI6MjA2NTI1OTkwOX0.1QN5XiAp1Ph5Et1XKf57GtjlC8dD7h_Y5qiVPp_us-o',
  );
  runApp(const TallerIApp());
}

class TallerIApp extends StatelessWidget {
  const TallerIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieApp',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tabs': (context) => const MainTabScreen(),
      },
    );
  }
}
