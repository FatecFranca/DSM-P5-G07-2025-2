import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart'; 

class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.orange400,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(width: 11),

            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              
              width: 43,
              height: 32,
              
              decoration: BoxDecoration(
                color: value ? AppColors.orange400 : Colors.transparent,
                border: Border.all(
                  color: AppColors.orange400,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}