import 'package:flutter/material.dart';
import 'package:PetDex/components/ui/shared_map_widget.dart';
import 'package:PetDex/data/enums/species.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SharedMapWidget(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: Species.dog,
        animalImageUrl: "lib/assets/images/uno.png",
        showCenterButton: true,
      ),
    );
  }
}
