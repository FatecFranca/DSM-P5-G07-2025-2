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

  /// Determina se a URL é uma imagem de rede (começa com http/https)
  bool _isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Constrói o widget de imagem apropriado (asset ou network)
  Widget _buildImage(String imageUrl) {
    final bool isNetwork = _isNetworkImage(imageUrl);

    if (isNetwork) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: (size * 2).toInt(),
        cacheHeight: (size * 2).toInt(),
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          // Fallback para imagem padrão se a rede falhar
          return _buildDefaultImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Mostra imagem padrão enquanto carrega
          return _buildDefaultImage();
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        cacheWidth: (size * 2).toInt(),
        cacheHeight: (size * 2).toInt(),
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    }
  }

  /// Constrói a imagem padrão baseada na espécie
  Widget _buildDefaultImage() {
    final String imagemPadrao = especie == SpeciesEnum.cat
        ? 'assets/images/gato-dex.png'
        : 'assets/images/cao-dex.png';

    return Image.asset(
      imagemPadrao,
      fit: BoxFit.cover,
      cacheWidth: (size * 2).toInt(),
      cacheHeight: (size * 2).toInt(),
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        // Último fallback: container colorido
        return Container(
          color: AppColors.orange400.withValues(alpha: 0.3),
          child: const Center(
            child: Icon(Icons.pets, color: AppColors.orange400),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool temImagem = imageUrl != null && imageUrl!.isNotEmpty;
    final double borderWidth = 6.0;

    return Container(
      width: size + borderWidth * 2,
      height: size + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: pinColor, width: borderWidth),
      ),
      child: ClipOval(
        child: temImagem ? _buildImage(imageUrl!) : _buildDefaultImage(),
      ),
    );
  }
}
