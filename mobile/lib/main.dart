import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'components/ui/select_species.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex Test',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SelectSpecies(
              onChanged: print,
            ),
          ),
        ),
      ),
    );
  }
}