import 'package:flutter/material.dart';
import 'package:PetDex/components/ui/nav_bar.dart';
import 'package:PetDex/screens/map_screen.dart';
import 'package:PetDex/screens/health_screen.dart';
import 'package:PetDex/screens/location_screen.dart';
import 'package:PetDex/data/enums/species.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    _pages = const [
      MapScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: Species.dog,
        animalImageUrl: "lib/assets/images/uno.png",
      ),
      HealthScreen(),
      LocationScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: Species.dog,
        animalImageUrl: "lib/assets/images/uno.png",
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

