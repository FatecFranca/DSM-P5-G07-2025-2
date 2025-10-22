import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/services/safe_area_service.dart';
import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/models/location_model.dart';

class DefineSafeAreaScreen extends StatefulWidget {
  final String animalId;
  final String animalName;
  final LocationData initialLocation;

  const DefineSafeAreaScreen({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.initialLocation,
  });

  @override
  State<DefineSafeAreaScreen> createState() => _DefineSafeAreaScreenState();
}

class _DefineSafeAreaScreenState extends State<DefineSafeAreaScreen> {
  GoogleMapController? _mapController;
  final SafeAreaService _safeAreaService = SafeAreaService();
  final LocationService _locationService = LocationService();

  LatLng? _selectedLocation;
  double _radius = 50.0; // Raio inicial em metros
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicia com a última localização do animal
    _selectedLocation = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
    _updateMapElements();
  }

  /// Atualiza o marcador e o círculo no mapa
  void _updateMapElements() {
    if (_selectedLocation == null) return;

    setState(() {
      // Cria o marcador
      _markers = {
        Marker(
          markerId: const MarkerId('safe_area_center'),
          position: _selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: 'Centro da área segura',
            snippet: 'Raio: ${_radius.toStringAsFixed(0)}m',
          ),
        ),
      };

      // Cria o círculo
      _circles = {
        Circle(
          circleId: const CircleId('safe_area_circle'),
          center: _selectedLocation!,
          radius: _radius,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });
  }

  /// Manipula o toque no mapa para definir nova localização
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _updateMapElements();
  }

  /// Salva a área segura na API
  Future<void> _saveSafeArea() async {
    if (_selectedLocation == null) {
      _showErrorDialog('Por favor, selecione um local no mapa');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _safeAreaService.createSafeArea(
        raio: _radius,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        animalId: widget.animalId,
      );

      if (success && mounted) {
        // Consulta a última localização do animal para obter os novos status
        try {
          final updatedLocation = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);
          if (mounted) {
            _showSuccessDialog(updatedLocation);
          }
        } catch (e) {
          if (mounted) {
            debugPrint('Erro ao consultar localização atualizada: $e');
            // Mesmo com erro, mostra o dialog de sucesso sem a localização
            _showSuccessDialog(null);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro ao salvar área segura: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSuccessDialog(LocationData? updatedLocation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 12),
            Text(
              'Sucesso!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Área segura definida com sucesso!',
          style: GoogleFonts.poppins(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o dialog
              // Volta para LocationScreen com a localização atualizada
              Navigator.of(context).pop(updatedLocation ?? true);
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: AppColors.orange400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
            const SizedBox(width: 12),
            Text(
              'Erro',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: AppColors.orange400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Definir Área Segura',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.sand100,
          ),
        ),
        backgroundColor: AppColors.orange400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialLocation.latitude,
                widget.initialLocation.longitude,
              ),
              zoom: 16.0,
            ),
            markers: _markers,
            circles: _circles,
            onTap: _onMapTap,
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Painel de controle inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.sand100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Título
                  Text(
                    'Configurar Área Segura',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no mapa para definir o centro da área',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Slider de raio
                  Row(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        color: AppColors.orange400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Raio: ${_radius.toStringAsFixed(0)}m',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 5,
                    max: 500,
                    divisions: 99,
                    activeColor: AppColors.orange400,
                    inactiveColor: AppColors.sand200,
                    label: '${_radius.toStringAsFixed(0)}m',
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                      });
                      _updateMapElements();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSafeArea,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Salvar Área Segura',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sand100,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instrução no topo
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.sand100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.orange400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toque no mapa para mover o centro da área',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
