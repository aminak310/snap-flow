import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ppimunajbqveekusuedo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwaW11bmFqYnF2ZWVrdXN1ZWRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMjQ0MTcsImV4cCI6MjA5MTkwMDQxN30.DGe7l9DYFufi8Ld-S7UTsKgtz9x3onopaPRhAWGsbRo',
  );

  runApp(const SnapFlowApp());
}

class SnapFlowApp extends StatelessWidget {
  const SnapFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapFlow',
      home: const LoginScreen(),
    );
  }
}