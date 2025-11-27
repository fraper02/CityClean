import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityCleanP',
      debugShowCheckedModeBanner: false, // SERVE PER RIMUOVERE LA BARRA "DEBUG" IN ALTO SE AVETE BISOGNO DEL DEBUG SETTATE SU TRUE
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // Tema verde
        useMaterial3: true,
      ),
      home: const ProfileScreen(), // <-- Cosa putna la HOME
    );
  }
}


