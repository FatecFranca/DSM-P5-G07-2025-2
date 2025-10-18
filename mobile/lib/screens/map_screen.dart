// lib/screens/map_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart'; 

import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/services/websocket_service.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/models/websocket_message.dart';
import 'package:PetDex/components/ui/animal_pin.dart';

class MapScreen extends StatefulWidget {
  final String animalId;
  final String animalName;
  final SpeciesEnum animalSpecies;
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

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final WebSocketService _webSocketService = WebSocketService();

  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<LocationUpdate>? _locationSubscription;
  bool _isInBackground = false;
  bool _isInitialized = false; // Flag para evitar inicializações duplicadas

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
    // Evita inicializações duplicadas
    if (_isInitialized) {
      return;
    }

    try {
      await _loadAnimalLocation();
      _initializeWebSocket();
      await _initializeNotifications();
      // Inicializa background service por último, de forma não-bloqueante
      _initializeBackgroundService();
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Erro ao inicializar app: $e');
    }
  }

  /// Inicializa o serviço de notificações
  Future<void> _initializeNotifications() async {
    try {
      await _webSocketService.initializeNotifications(petName: widget.animalName);
    } catch (e) {
      debugPrint('❌ Erro ao inicializar notificações: $e');
    }
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
      // Gera bytes do widget AnimalPin usando overlay capture
      final Uint8List markerBytes = await _createMarkerFromWidget(
        AnimalPin(
          imageUrl: widget.animalImageUrl,
          especie: widget.animalSpecies,
          size: 64, // tamanho interno do avatar
        ),
        const Size(88, 88), // tamanho do widget que renderizamos (inclui borda)
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
      // Erro ao criar marcador
    }
  }

  /// Converte um widget (AnimalPin) para Uint8List usando um OverlayEntry e RepaintBoundary.
  /// O widget é inserido off-screen, aguardamos o frame e capturamos a imagem.
  Future<Uint8List> _createMarkerFromWidget(Widget widget, Size size) async {
    final overlayState = Overlay.of(context);
    if (overlayState == null) {
      throw Exception('Overlay não disponível');
    }

    final key = GlobalKey();
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        // posicionar off-screen para não interferir na UI
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

    // aguarda um frame para garantir que o widget foi renderizado
    await Future.delayed(const Duration(milliseconds: 50));
    await WidgetsBinding.instance.endOfFrame;

    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Erro ao capturar RenderRepaintBoundary');
      }

      // ✅ OTIMIZAÇÃO: Usa pixelRatio menor para reduzir o tamanho da imagem
      // Isso reduz drasticamente o uso de memória e evita o erro de decodificação
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // remove o overlay
      entry.remove();
      return bytes;
    } catch (e) {
      // garante remoção do overlay em caso de erro
      entry.remove();
      rethrow;
    }
  }

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

  void _initializeWebSocket() {
    try {
      debugPrint('🔌 Inicializando WebSocket para animal: ${widget.animalId}');

      // Cancela subscription anterior se existir
      _locationSubscription?.cancel();

      _locationSubscription = _webSocket_service_locationStreamListener();
      _webSocketService.connect(widget.animalId);

      debugPrint('✅ WebSocket inicializado');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar WebSocket: $e');
    }
  }

  StreamSubscription<LocationUpdate>? _webSocket_service_locationStreamListener() {
    return _webSocketService.locationStream.listen((locationUpdate) {
      _handleWebSocketLocationUpdate(locationUpdate);
    });
  }

  void _handleWebSocketLocationUpdate(LocationUpdate locationUpdate) {
    if (locationUpdate.animalId == widget.animalId) {
      debugPrint('📍 WebSocket: Nova localização recebida - Lat: ${locationUpdate.latitude}, Lng: ${locationUpdate.longitude}');
      debugPrint('🔒 Área segura: ${locationUpdate.isOutsideSafeZone ? "FORA" : "DENTRO"} - Distância: ${locationUpdate.distanciaDoPerimetro}m');

      final newLocation = LocationData(
        id: 'websocket-${DateTime.now().millisecondsSinceEpoch}',
        data: locationUpdate.timestamp,
        latitude: locationUpdate.latitude,
        longitude: locationUpdate.longitude,
        animal: locationUpdate.animalId,
        coleira: locationUpdate.coleiraId,
        // Adiciona informações de área segura do WebSocket
        isOutsideSafeZone: locationUpdate.isOutsideSafeZone,
        distanciaDoPerimetro: locationUpdate.distanciaDoPerimetro,
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
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.ignoreBatteryOptimizations.request();
  }

  Future<void> _initializeBackgroundService() async {
    try {
      await _webSocketService.initializeBackgroundService();
    } catch (e) {
      debugPrint('❌ Erro ao inicializar background service: $e');
      // Não propaga o erro para evitar crash do app
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _webSocketService.setBackgroundMode(false);
    _webSocketService.disconnect();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
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

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.orange400),
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

          // Botão de centralização - Bem acima do StatusBar
          if (_currentLocation != null)
            Positioned(
              bottom: 250, // 20 pixels acima da posição anterior (230 + 20)
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
