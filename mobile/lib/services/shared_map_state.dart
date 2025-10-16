import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/services/websocket_service.dart';
import 'package:PetDex/models/websocket_message.dart';
import 'package:PetDex/data/enums/species.dart';

class SharedMapState extends ChangeNotifier {
  static final SharedMapState _instance = SharedMapState._internal();
  factory SharedMapState() => _instance;
  SharedMapState._internal();

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
  bool _isInitialized = false;

  String? _animalName;
  Species? _animalSpecies;
  String? _animalImageUrl;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333),
    zoom: 16.0,
  );

  GoogleMapController? get mapController => _mapController;
  LocationData? get currentLocation => _currentLocation;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isWebSocketConnected => _isWebSocketConnected;
  bool get isInitialized => _isInitialized;
  CameraPosition get defaultPosition => _defaultPosition;

  Future<void> initialize(String animalId, String animalName, Species animalSpecies, String? animalImageUrl) async {
    if (_isInitialized) return;

    _animalName = animalName;
    _animalSpecies = animalSpecies;
    _animalImageUrl = animalImageUrl;

    _isInitialized = true;
    await _loadAnimalLocation(animalId);
    _initializeWebSocket(animalId);
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      animateToLocation(_currentLocation!.latitude, _currentLocation!.longitude);
    }
  }

  Future<void> _loadAnimalLocation(String animalId, [BuildContext? context]) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final location = await _locationService.getUltimaLocalizacaoAnimal(animalId);

      if (location != null) {
        _currentLocation = location;
        _updateMarkerPosition(location);

        if (_mapController != null) {
          animateToLocation(location.latitude, location.longitude);
        }
      } else {
        _errorMessage = 'Localização não encontrada';
      }
    } catch (e) {
      debugPrint('Erro ao carregar localização: $e');
      _errorMessage = 'Erro ao carregar localização';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> animateToLocation(double latitude, double longitude) async {
    print('animateToLocation chamado: $latitude, $longitude');
    print('_mapController é null? ${_mapController == null}');

    if (_mapController != null) {
      try {
        // Primeiro, pega a posição atual da câmera
        final currentPosition = await _mapController!.getVisibleRegion();
        print('Posição atual da câmera: ${currentPosition.southwest} - ${currentPosition.northeast}');

        print('Executando animateCamera...');
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 18.0, // Zoom maior para garantir que a animação seja visível
            ),
          ),
        );
        print('animateCamera executado com sucesso!');
      } catch (e) {
        print('Erro ao animar câmera: $e');
      }
    } else {
      print('MapController é null, não pode animar!');
    }
  }

  void _initializeWebSocket(String animalId) {
    _connectionSubscription = _webSocketService.connectionStream.listen((isConnected) {
      _isWebSocketConnected = isConnected;
      notifyListeners();
    });

    _locationSubscription = _webSocketService.locationStream.listen((locationUpdate) {
      _handleWebSocketLocationUpdate(locationUpdate, animalId);
    });

    _webSocketService.connect(animalId);
  }

  void _handleWebSocketLocationUpdate(LocationUpdate locationUpdate, String animalId) {
    if (locationUpdate.animalId == animalId) {
      final newLocation = LocationData(
        id: 'websocket-${DateTime.now().millisecondsSinceEpoch}',
        data: locationUpdate.timestamp,
        latitude: locationUpdate.latitude,
        longitude: locationUpdate.longitude,
        animal: locationUpdate.animalId,
        coleira: locationUpdate.coleiraId,
      );

      _currentLocation = newLocation;
      _updateMarkerPosition(newLocation);
      animateToLocation(locationUpdate.latitude, locationUpdate.longitude);
    }
  }

  void _updateMarkerPosition(LocationData location) {
    final marker = Marker(
      markerId: const MarkerId('animal_location'),
      position: LatLng(location.latitude, location.longitude),
      icon: _markers.isNotEmpty ? _markers.first.icon : BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: _animalName ?? 'Animal',
        snippet: 'Localização atual',
      ),
    );

    _markers = {marker};
    notifyListeners();
  }

  void updateMarkerIcon(BitmapDescriptor icon) {
    if (_currentLocation != null) {
      final marker = Marker(
        markerId: const MarkerId('animal_location'),
        position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        icon: icon,
        infoWindow: InfoWindow(
          title: _animalName ?? 'Animal',
          snippet: 'Localização atual',
        ),
      );

      _markers = {marker};
      notifyListeners();
    }
  }

  Future<void> reloadLocation(String animalId, [BuildContext? context]) async {
    await _loadAnimalLocation(animalId, context);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService.disconnect();
    _mapController?.dispose();
    _mapController = null;
    _isInitialized = false;
    super.dispose();
  }
}
