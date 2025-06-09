import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClockApp());
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Clock',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
