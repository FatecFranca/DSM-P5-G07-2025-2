import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/theme/app_theme.dart';

class PetAddressCard extends StatelessWidget {
  final String petName;
  final String address;
  final bool?
  isOutsideSafeZone; // null = desconhecido, true = fora, false = dentro
  final double? distanceFromPerimeter; // Distância do perímetro em metros

  const PetAddressCard({
    super.key,
    required this.petName,
    required this.address,
    this.isOutsideSafeZone,
    this.distanceFromPerimeter,
  });

  @override
  Widget build(BuildContext context) {
    // Determina o status da área segura
    final bool showSafeZoneStatus = isOutsideSafeZone != null;
    final bool isInSafeZone = isOutsideSafeZone == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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

              // Status da área segura
              if (showSafeZoneStatus) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isInSafeZone
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isInSafeZone
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInSafeZone
                            ? Icons.check_circle
                            : Icons.warning_rounded,
                        color: isInSafeZone
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isInSafeZone
                              ? 'Pet dentro da área segura'
                              : 'Pet fora da área segura',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isInSafeZone
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
