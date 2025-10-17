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

    // ✅ CORREÇÃO: Usar os nomes corretos dos arquivos de imagem
    final String imagemPadrao = especie == SpeciesEnum.cat
        ? 'assets/images/gato-dex.png'
        : 'assets/images/cao-dex.png';

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
          // ✅ OTIMIZAÇÃO: Reduz o tamanho da imagem em memória
          cacheWidth: (size * 2).toInt(),
          cacheHeight: (size * 2).toInt(),
          // ✅ OTIMIZAÇÃO: Filtragem de baixa qualidade para melhor performance
          filterQuality: FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            // Fallback se a imagem falhar ao carregar
            return Image.asset(
              imagemPadrao,
              fit: BoxFit.cover,
              cacheWidth: (size * 2).toInt(),
              cacheHeight: (size * 2).toInt(),
              filterQuality: FilterQuality.low,
            );
          },
        ),
      ),
    );
  }
}
