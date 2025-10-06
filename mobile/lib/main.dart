import 'package:flutter/material.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/question_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const QuestionDemoPage(),
    );
  }
}

class QuestionDemoPage extends StatelessWidget {
  const QuestionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exemplo QuestionCard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            QuestionCard(
              questionNumber: 1,
              questionText: "pipi popopó? pó pô popo pó pipi pó",
            ),
          ],
        ),
      ),
    );
  }
}
