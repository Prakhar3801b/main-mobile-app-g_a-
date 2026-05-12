import 'package:flutter/material.dart';

import 'features/complaints/presentation/dashboard_page.dart';

class SamadhanApp extends StatelessWidget {
  const SamadhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samadhan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7490)),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
