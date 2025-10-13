import 'package:PetDex/data/enums/species.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/animal_pin.dart';

class NavBar extends StatefulWidget {
  final int initialIndex;

  const NavBar({super.key, this.initialIndex = 0});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _pages = [
      const Center(
        child: AnimalPin(
          especie: SpeciesEnum.dog,
          imageUrl: 'lib/assets/images/uno.png', 
          size: 90,
        ),
      ),

      const _NavPage(title: "Saúde", icon: FontAwesomeIcons.heartPulse),
      const _NavPage(title: "Localização", icon: FontAwesomeIcons.locationDot),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 85,
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        decoration: const BoxDecoration(
          color: AppColors.sand900,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(FontAwesomeIcons.houseChimney, "Início", 0,
                offsetX: -1.5),
            _buildNavItem(FontAwesomeIcons.heartPulse, "Saúde", 1,
                offsetX: 0.0),
            _buildNavItem(FontAwesomeIcons.locationDot, "Localização", 2,
                offsetX: 1.2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    double offsetX = 0,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(offsetX, 0),
              child: Icon(
                icon,
                size: 30,
                color: isSelected
                    ? AppColors.orange900
                    : AppColors.orange200,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.orange900
                    : AppColors.orange200,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _NavPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppColors.orange900),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
