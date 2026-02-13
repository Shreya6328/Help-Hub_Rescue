import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class RescueTeamApp extends StatelessWidget {
  const RescueTeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
