import 'package:desayunos_valderrama/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rjlteifzlhiqrmcqwybn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJqbHRlaWZ6bGhpcXJtY3F3eWJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIyNzQ2OTAsImV4cCI6MjAzNzg1MDY5MH0.Bo6-I38HmPA2osFY-vJEdYVpoTvLxVVmUIkatVEAZlk',
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}