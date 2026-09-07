import 'package:flutter/material.dart';

import 'presentation/pages/home_page.dart';

void main() {
  runApp(const OffgridApp());
}

class OffgridApp extends StatelessWidget {
  const OffgridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offgrid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5A3D)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
