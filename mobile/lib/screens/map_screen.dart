import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/components/ui/animal_pin.dart';
import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/utils/custom_marker_helper.dart';

class MapScreen extends StatefulWidget {
  final String animalId;
  final String animalName;
  final Species animalSpecies;
  final String? animalImageUrl;

  const MapScreen({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.animalSpecies,
    this.animalImageUrl,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333),
    zoom: 16.0,
  );

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
          _currentLocation = location;
        });
        await _createMarker(location);
        _animateToLocation(location.latitude, location.longitude);
      } else {
        setState(() {
          _errorMessage = 'Localização não encontrada';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar localização';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createMarker(LocationData location) async {
    final customIcon = await CustomMarkerHelper.createAnimalPinMarker(
      species: widget.animalSpecies,
      imageUrl: widget.animalImageUrl,
    );

    final marker = Marker(
      markerId: const MarkerId('animal_location'),
      position: LatLng(location.latitude, location.longitude),
      icon: customIcon,
      infoWindow: InfoWindow(
        title: widget.animalName,
        snippet: 'Localização atual',
      ),
    );

    setState(() {
      _markers = {marker};
    });
  }

  void _animateToLocation(double latitude, double longitude) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(latitude, longitude)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: _currentLocation != null
                ? CameraPosition(
                    target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                    zoom: 16.0,
                  )
                : _defaultPosition,
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.orange400,
                ),
              ),
            ),

          if (_errorMessage != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
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
              ),
            ),



          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _loadAnimalLocation,
              backgroundColor: AppColors.orange400,
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
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
}
