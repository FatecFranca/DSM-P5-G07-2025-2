import 'package:flutter/material.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/button.dart';

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
      home: const ButtonDemoPage(),
    );
  }
}

class ButtonDemoPage extends StatelessWidget {
  const ButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Testando o componente Button")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              text: "Vamos começar?",
              size: ButtonSize.small,
              onPressed: () => debugPrint("Clicou no pequeno"),
            ),
            const SizedBox(height: 16),
            Button(
              text: "Vamos começar?",
              size: ButtonSize.medium,
              onPressed: () => debugPrint("Clicou no médio"),
            ),
            const SizedBox(height: 16),
            Button(
              text: "Vamos começar?",
              size: ButtonSize.large,
              onPressed: () => debugPrint("Clicou no grande"),
            ),
          ],
        ),
      ),
    );
  }
}
