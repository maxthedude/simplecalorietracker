import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/camera/presentation/meal_capture_page.dart';

void main() {
  runApp(const ProviderScope(child: CalorieTrackerApp()));
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Calorie Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const MealCapturePage(),
    );
  }
}
