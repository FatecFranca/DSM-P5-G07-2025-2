import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      decoration: const BoxDecoration(
        color: AppColors.sand900,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            FontAwesomeIcons.houseChimney,
            "Início",
            0,
            offsetX: -1.5,
          ),
          _buildNavItem(
            FontAwesomeIcons.heartPulse,
            "Saúde",
            1,
            offsetX: 0.0,
          ),
          _buildNavItem(
            FontAwesomeIcons.locationDot,
            "Localização",
            2,
            offsetX: 1.2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    double offsetX = 0,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
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
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
