import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PetDex/components/ui/animal_pin.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? animalImageUrl;
  final SpeciesEnum animalSpecies;
  final String animalName;
  final double mapHeight;
  final double zoom;

  const GoogleMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.animalImageUrl,
    required this.animalSpecies,
    required this.animalName,
    this.mapHeight = 300,
    this.zoom = 16.0,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarker();
  }

  void _createMarker() {
    final marker = Marker(
      markerId: MarkerId('animal_location'),
      position: LatLng(widget.latitude, widget.longitude),
      infoWindow: InfoWindow(
        title: widget.animalName,
        snippet: 'Localização atual',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      _markers = {marker};
    });
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _createMarker();
      _animateToLocation();
    }
  }

  void _animateToLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.latitude, widget.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.mapHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: widget.zoom,
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black400.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimalPin(
                      imageUrl: widget.animalImageUrl,
                      especie: widget.animalSpecies,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.animalName,
                      style: GoogleFonts.poppins(
                        color: AppColors.black400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _animateToLocation,
                backgroundColor: AppColors.orange400,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
