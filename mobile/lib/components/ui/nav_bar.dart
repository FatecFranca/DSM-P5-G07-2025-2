import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      decoration: const BoxDecoration(color: AppColors.sand900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: FontAwesomeIcons.houseChimney,
            label: "Início",
            index: 0,
          ),
          _buildNavItem(
            icon: FontAwesomeIcons.heartPulse,
            label: "Saúde",
            index: 1,
          ),
          _buildNavItem(
            icon: FontAwesomeIcons.stethoscope,
            label: "Checkup",
            index: 2,
          ),
          _buildNavItem(
            icon: FontAwesomeIcons.locationDot,
            label: "Localização",
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? AppColors.orange900 : AppColors.orange200,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.orange900 : AppColors.orange200,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
