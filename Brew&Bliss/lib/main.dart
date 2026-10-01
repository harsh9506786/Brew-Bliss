import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const BrewAndBlissApp());
}

class BrewAndBlissApp extends StatelessWidget {
  const BrewAndBlissApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brew & Bliss',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
