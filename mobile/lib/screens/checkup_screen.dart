import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/theme/app_theme.dart';

class CheckupScreen extends StatelessWidget {
  const CheckupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.stethoscope,
              size: 60,
              color: AppColors.orange900,
            ),
            SizedBox(height: 12),
            Text(
              "CheckUp",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

