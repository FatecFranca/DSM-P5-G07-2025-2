import 'package:flutter/material.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/answer_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDex',
      theme: AppTheme.lightTheme,
      home: const AnswerCardDemoPage(),
    );
  }
}

class AnswerCardDemoPage extends StatelessWidget {
  const AnswerCardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Testando o componente AnswerCard")),
      body: Center(
        child: AnswerCard(
          initialValue: "",
          onAnswerChanged: (resposta) {
            debugPrint("Usuário digitou: $resposta");
          },
        ),
      ),
    );
  }
}
