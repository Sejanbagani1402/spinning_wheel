import 'package:flutter/material.dart';
import 'package:spinner/game.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SAmple",
      home: const Game(),

    );
  }
}