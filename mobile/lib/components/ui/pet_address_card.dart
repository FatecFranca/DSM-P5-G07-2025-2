import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/theme/app_theme.dart';

class PetAddressCard extends StatelessWidget {
  final String petName;
  final String address;

  const PetAddressCard({
    super.key,
    required this.petName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'endereço do animal',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.black200,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          width: double.infinity, 
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.sand100, 
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.orange200,
                    size: 22, 
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${petName.toUpperCase()} ESTÁ EM:',
                    style: GoogleFonts.poppins(
                      color: AppColors.orange200,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                address,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.black400,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}