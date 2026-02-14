import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placement Readiness Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto', // Defaulting to Roboto if not available, but structure is ready
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}
