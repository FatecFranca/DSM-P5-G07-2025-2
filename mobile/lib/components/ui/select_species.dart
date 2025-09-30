import 'package:flutter/material.dart';
import '../../enums/species.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectSpecies extends StatefulWidget {
  final Species initialValue;
  final Function(Species) onChanged;

  const SelectSpecies({
    super.key,
    required this.onChanged,
    this.initialValue = Species.dog,
  });

  @override
  State<SelectSpecies> createState() => _SelectSpeciesState();
}

class _SelectSpeciesState extends State<SelectSpecies> {
  late Species _selectedSpecies;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.initialValue;
  }

  void _selectSpecies(Species species) {
    setState(() {
      _selectedSpecies = species;
    });
    widget.onChanged(species);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'espécie do animal',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildSpeciesButton(species: Species.dog),
        const SizedBox(height: 16),
        _buildSpeciesButton(species: Species.cat),
      ],
    );
  }

  Widget _buildSpeciesButton({required Species species}) {
    final bool isSelected = (_selectedSpecies == species);
    
    const Color orangeBorderColor = Color(0xFFF29F05);
    const Color buttonBackgroundColor = Color(0xFFF0D37B);
    const Color iconAndTextColor = Color(0xFFFBFBE1);
    const double borderRadius = 25.0;

    double currentIconWidth;
    double currentIconHeight;
    String imagePath;
    String text;

    if (species == Species.dog) {
      imagePath = 'imagens/cao-dex.png';
      text = 'Um Aumigo';
      currentIconWidth = 105.0;
      currentIconHeight = 105.0;
    } else {
      imagePath = 'imagens/gato-dex.png';
      text = 'Um Miaugo';
      currentIconWidth = 105.0;
      currentIconHeight = 105.0;
    }

    Widget imageWidget = Image.asset(
      imagePath,
      width: currentIconWidth,
      height: currentIconHeight,
      color: iconAndTextColor,
      colorBlendMode: BlendMode.srcIn,
    );

    if (species == Species.cat) {
      imageWidget = Transform.scale(
        scaleX: -1,
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: () => _selectSpecies(species),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: buttonBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: orangeBorderColor, width: 3.0)
              : null,
        ),
        child: Row(
          children: [
            imageWidget,
            const SizedBox(width: 24),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: iconAndTextColor,
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