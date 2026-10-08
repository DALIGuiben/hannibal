import 'package:flutter/material.dart';

import 'hannibal_experience.dart';

void main() {
  runApp(const HannibalApp());
}

class HannibalApp extends StatelessWidget {
  const HannibalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hannibal: Decide Your Legacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0B1018),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC99A63),
          brightness: Brightness.dark,
        ),
      ),
      home: const HannibalHomePage(),
    );
  }
}
