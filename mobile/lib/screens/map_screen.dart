import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/services/websocket_service.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/models/websocket_message.dart';
import 'package:PetDex/utils/custom_marker_helper.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

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

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final WebSocketService _webSocketService = WebSocketService();

  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<LocationUpdate>? _locationSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isWebSocketConnected = false;
  bool _isInBackground = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333),
    zoom: 16.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadAnimalLocation();
    _initializeWebSocket();
    _initializeBackgroundService();
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

        // Aguarda o mapa ser criado antes de animar
        if (_mapController != null) {
          _animateToLocation(location.latitude, location.longitude);
        } else {
          // Se o mapa ainda não foi criado, agenda a animação para depois
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

  void _initializeWebSocket() {
    _connectionSubscription = _webSocketService.connectionStream.listen((isConnected) {
      setState(() {
        _isWebSocketConnected = isConnected;
      });
    });

    _locationSubscription = _webSocketService.locationStream.listen((locationUpdate) {
      _handleWebSocketLocationUpdate(locationUpdate);
    });

    _webSocketService.connect(widget.animalId);
  }

  void _handleWebSocketLocationUpdate(LocationUpdate locationUpdate) {
    if (locationUpdate.animalId == widget.animalId) {
      final newLocation = LocationData(
        id: 'websocket-${DateTime.now().millisecondsSinceEpoch}',
        data: locationUpdate.timestamp,
        latitude: locationUpdate.latitude,
        longitude: locationUpdate.longitude,
        animal: locationUpdate.animalId,
        coleira: locationUpdate.coleiraId,
      );

      setState(() {
        _currentLocation = newLocation;
      });

      _createMarker(newLocation);
      _animateToLocation(locationUpdate.latitude, locationUpdate.longitude);
    }
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isInBackground = true;
        _webSocketService.setBackgroundMode(true);
        _webSocketService.resetReconnectionAttempts();
        break;
      case AppLifecycleState.resumed:
        _isInBackground = false;
        _webSocketService.setBackgroundMode(false);
        if (!_webSocketService.isConnected) {
          _webSocketService.connect(widget.animalId);
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.ignoreBatteryOptimizations.request();
  }

  Future<void> _initializeBackgroundService() async {
    await _webSocketService.initializeBackgroundService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService.setBackgroundMode(false);
    _webSocketService.disconnect();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Se já temos uma localização carregada, anima para ela
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

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
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
            top: 50,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isWebSocketConnected ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isWebSocketConnected ? 'Conectado' : 'Desconectado',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 16,
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


}
