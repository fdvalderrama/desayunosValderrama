import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rjlteifzlhiqrmcqwybn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJqbHRlaWZ6bGhpcXJtY3F3eWJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIyNzQ2OTAsImV4cCI6MjAzNzg1MDY5MH0.Bo6-I38HmPA2osFY-vJEdYVpoTvLxVVmUIkatVEAZlk',
  );

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desayunos Valderrama',
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}