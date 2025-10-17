import 'package:flutter/material.dart';
import '../../data/enums/species.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SpeciesCard extends StatelessWidget {
  final SpeciesEnum species;
  final bool isSelected;
  final VoidCallback onTap;

  const SpeciesCard({
    super.key,
    required this.species,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath =
        species == SpeciesEnum.dog ? 'imagens/cao-dex.png' : 'imagens/gato-dex.png';
    final text = species == SpeciesEnum.dog ? 'Um Aumigo' : 'Um Miaugo';
    final iconSize = 105.0;

    Widget imageWidget = Image.asset(
      imagePath,
      width: iconSize,
      height: iconSize,
      color: AppColors.sand100,
      colorBlendMode: BlendMode.srcIn,
    );

    if (species == SpeciesEnum.cat) {
      imageWidget = Transform.scale(scaleX: -1, child: imageWidget);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(25.0),
          border: isSelected
              ? Border.all(color: AppColors.orange, width: 3.0)
              : null,
        ),
        child: Row(
          children: [
            imageWidget,
            const SizedBox(width: 24),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.sand100,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectSpecies extends StatefulWidget {
  final SpeciesEnum initialValue;
  final Function(SpeciesEnum) onChanged;

  const SelectSpecies({
    super.key,
    required this.onChanged,
    this.initialValue = SpeciesEnum.dog,
  });

  @override
  State<SelectSpecies> createState() => _SelectSpeciesState();
}

class _SelectSpeciesState extends State<SelectSpecies> {
  late SpeciesEnum _selectedSpecies;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.initialValue;
  }

  void _selectSpecies(SpeciesEnum species) {
    setState(() {
      _selectedSpecies = species;
    });
    widget.onChanged(species);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'espécie do animal',
          style: TextStyle(fontSize: 14, color: AppColors.black400), 
        ),
        const SizedBox(height: 8),
        SpeciesCard(
          species: SpeciesEnum.dog,
          isSelected: _selectedSpecies == SpeciesEnum.dog,
          onTap: () => _selectSpecies(SpeciesEnum.dog),
        ),
        const SizedBox(height: 16),
        SpeciesCard(
          species: SpeciesEnum.cat,
          isSelected: _selectedSpecies == SpeciesEnum.cat,
          onTap: () => _selectSpecies(SpeciesEnum.cat),
        ),
      ],
    );
  }
}