// lib/screens/location_screen_new.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/components/ui/animal_pin.dart';
import 'package:PetDex/components/ui/pet_address_card.dart';

/// LocationScreen - Tela de localização do animal
/// Exibe o mapa com a última localização conhecida e o endereço formatado
/// Mantém o estado vivo usando AutomaticKeepAliveClientMixin
class LocationScreen extends StatefulWidget {
  final String animalId;
  final String animalName;
  final Species animalSpecies;
  final String? animalImageUrl;

  const LocationScreen({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.animalSpecies,
    this.animalImageUrl,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Mantém o estado vivo ao trocar de abas

  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();

  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;
  String? _address; // Endereço formatado

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333),
    zoom: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _loadAnimalLocation();
  }

  /// Carrega a última localização do animal e converte em endereço
  Future<void> _loadAnimalLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Busca a última localização do animal
      final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);

      if (location != null) {
        setState(() {
          _currentLocation = location;
        });
        
        // Cria o marcador no mapa
        await _createMarker(location);

        // Busca o endereço formatado usando Google Maps API
        final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
        if (googleMapsApiKey.isNotEmpty) {
          final address = await _locationService.getEnderecoFromCoordinates(
            location.latitude,
            location.longitude,
            googleMapsApiKey,
          );
          setState(() {
            _address = address ?? 'Endereço não disponível';
          });
        } else {
          setState(() {
            _address = 'API Key do Google Maps não configurada';
          });
        }

        // Centraliza o mapa na localização
        if (_mapController != null) {
          _animateToLocation(location.latitude, location.longitude);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_mapController != null) {
              _animateToLocation(location.latitude, location.longitude);
            }
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Localização não encontrada';
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar localização: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar localização';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Cria o marcador com o AnimalPin convertido para BitmapDescriptor
  Future<void> _createMarker(LocationData location) async {
    try {
      final Uint8List markerBytes = await _createMarkerFromWidget(
        AnimalPin(
          imageUrl: widget.animalImageUrl,
          especie: widget.animalSpecies,
          size: 64,
        ),
        const Size(88, 88),
      );

      final marker = Marker(
        markerId: const MarkerId('animal_location'),
        position: LatLng(location.latitude, location.longitude),
        icon: BitmapDescriptor.fromBytes(markerBytes),
        infoWindow: InfoWindow(
          title: widget.animalName,
          snippet: 'Localização atual',
        ),
      );

      setState(() {
        _markers = {marker};
      });
    } catch (e) {
      debugPrint('Erro ao criar marcador: $e');
    }
  }

  /// Converte um widget (AnimalPin) para Uint8List usando OverlayEntry
  Future<Uint8List> _createMarkerFromWidget(Widget widget, Size size) async {
    final overlayState = Overlay.of(context);
    if (overlayState == null) {
      throw Exception('Overlay não disponível');
    }

    final key = GlobalKey();
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: -1000,
        top: -1000,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: key,
            child: SizedBox(width: size.width, height: size.height, child: widget),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    await Future.delayed(const Duration(milliseconds: 50));
    await WidgetsBinding.instance.endOfFrame;

    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Erro ao capturar RenderRepaintBoundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      entry.remove();
      return bytes;
    } catch (e) {
      entry.remove();
      rethrow;
    }
  }

  /// Anima a câmera do mapa para a localização especificada
  void _animateToLocation(double latitude, double longitude) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(latitude, longitude)),
      );
    }
  }

  /// Centraliza o mapa na localização atual do animal
  void _centerOnAnimalLocation() {
    if (_currentLocation != null) {
      _animateToLocation(_currentLocation!.latitude, _currentLocation!.longitude);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: Stack(
        children: [
          // Mapa do Google Maps
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentLocation != null) {
                _animateToLocation(_currentLocation!.latitude, _currentLocation!.longitude);
              }
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

          // Indicador de carregamento
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.orange400),
              ),
            ),

          // Mensagem de erro
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

          // PetAddressCard - Exibe o endereço do animal
          if (_address != null && !_isLoading)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: PetAddressCard(
                petName: widget.animalName,
                address: _address!,
              ),
            ),

          // Botão de centralização - Canto inferior direito, acima da NavBar
          if (_currentLocation != null)
            Positioned(
              bottom: 100, // Acima da NavBar (altura da NavBar é ~85)
              right: 16,
              child: FloatingActionButton(
                onPressed: _centerOnAnimalLocation,
                backgroundColor: AppColors.orange400,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

