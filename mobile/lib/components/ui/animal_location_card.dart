import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/components/ui/google_map_widget.dart';
import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnimalLocationCard extends StatefulWidget {
  final String animalId;
  final String animalName;
  final Species animalSpecies;
  final String? animalImageUrl;

  const AnimalLocationCard({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.animalSpecies,
    this.animalImageUrl,
  });

  @override
  State<AnimalLocationCard> createState() => _AnimalLocationCardState();
}

class _AnimalLocationCardState extends State<AnimalLocationCard> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  String? _errorMessage;
  double? _latitude;
  double? _longitude;
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadAnimalLocation();
  }

  Future<void> _loadAnimalLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);
      
      if (location != null) {
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
        });

        final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
        if (googleMapsApiKey.isNotEmpty) {
          final address = await _locationService.getEnderecoFromCoordinates(
            location.latitude,
            location.longitude,
            googleMapsApiKey,
          );
          setState(() {
            _address = address;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Nenhuma localização encontrada para ${widget.animalName}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar localização: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.orange400,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Localização de ${widget.animalName}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange400,
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_latitude != null && _longitude != null)
            Column(
              children: [
                GoogleMapWidget(
                  latitude: _latitude!,
                  longitude: _longitude!,
                  animalImageUrl: widget.animalImageUrl,
                  animalSpecies: widget.animalSpecies,
                  animalName: widget.animalName,
                  mapHeight: 250,
                ),
                if (_address != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sand100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: AppColors.orange400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address!,
                            style: GoogleFonts.poppins(
                              color: AppColors.black400,
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
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadAnimalLocation,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Atualizar Localização',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
