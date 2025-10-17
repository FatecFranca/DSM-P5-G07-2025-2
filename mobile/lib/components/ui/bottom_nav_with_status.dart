import 'package:flutter/material.dart';
import 'package:PetDex/components/ui/status_bar.dart';
import 'package:PetDex/components/ui/nav_bar.dart';

/// BottomNavWithStatus - Componente que combina StatusBar e NavBar
/// Exibe o StatusBar acima da NavBar, conforme o design
/// Funciona como um overlay que não afeta o layout das telas
class BottomNavWithStatus extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String animalId;
  final bool isConnected;

  const BottomNavWithStatus({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.animalId,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // StatusBar acima
        StatusBar(
          animalId: animalId,
          isConnected: isConnected,
        ),
        // NavBar abaixo
        NavBar(
          currentIndex: currentIndex,
          onTap: onTap,
        ),
      ],
    );
  }
}

