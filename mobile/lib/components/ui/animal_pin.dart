import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnimalPin extends StatelessWidget {
  final String? imageUrl;
  final SpeciesEnum especie;
  final double size;
  static const Color pinColor = AppColors.orange400;

  const AnimalPin({
    super.key,
    this.imageUrl,
    required this.especie,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final bool temImagem = imageUrl != null && imageUrl!.isNotEmpty;

    final String imagemPadrao = especie == SpeciesEnum.cat
        ? 'assets/images/gato_default.png'
        : 'assets/images/cachorro_default.png';

    final double borderWidth = 6.0;

    return Container(
      width: size + borderWidth * 2,
      height: size + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: pinColor, width: borderWidth),
      ),
      child: ClipOval(
        child: Image.asset(
          temImagem ? imageUrl! : imagemPadrao,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
