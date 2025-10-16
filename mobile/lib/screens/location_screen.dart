// lib/screens/location_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/services/websocket_service.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/models/location_model.dart';
import 'package:PetDex/models/websocket_message.dart';
import 'package:PetDex/components/ui/animal_pin.dart';
import 'package:PetDex/components/ui/pet_address_card.dart';
import 'package:PetDex/screens/define_safe_area_screen.dart';

/// LocationScreen - Tela de localização do animal
/// Exibe o mapa com a última localização conhecida e o endereço formatado
/// Atualiza automaticamente via WebSocket quando novas coordenadas chegam
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
  final WebSocketService _webSocketService = WebSocketService();

  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;
  String? _address; // Endereço formatado

  // Informações de área segura
  bool? _isOutsideSafeZone;
  double? _distanceFromPerimeter;

  // Subscriptions do WebSocket
  StreamSubscription<LocationUpdate>? _locationSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isWebSocketConnected = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-23.5505, -46.6333),
    zoom: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Inicializa a aplicação: carrega localização inicial e conecta WebSocket
  Future<void> _initializeApp() async {
    await _loadAnimalLocation();
    await _initializeNotifications(); // ✅ CRÍTICO: Inicializa notificações
    _initializeWebSocket();
  }

  /// Inicializa o serviço de notificações
  Future<void> _initializeNotifications() async {
    debugPrint('🔔 [LocationScreen] Inicializando notificações para ${widget.animalName}...');
    await _webSocketService.initializeNotifications(petName: widget.animalName);
    debugPrint('✅ [LocationScreen] Notificações inicializadas!');
  }

  /// Inicializa o WebSocket e seus listeners
  void _initializeWebSocket() {
    // Listener de conexão
    _connectionSubscription = _webSocketService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isWebSocketConnected = isConnected;
        });
      }
    });

    // Listener de atualizações de localização
    _locationSubscription = _webSocketService.locationStream.listen((locationUpdate) {
      _handleWebSocketLocationUpdate(locationUpdate);
    });

    // Conecta ao WebSocket
    _webSocketService.connect(widget.animalId);
  }

  /// Processa atualizações de localização recebidas via WebSocket
  void _handleWebSocketLocationUpdate(LocationUpdate locationUpdate) {
    debugPrint('📍 WebSocket: Nova localização recebida - Lat: ${locationUpdate.latitude}, Lng: ${locationUpdate.longitude}');
    debugPrint('🔒 Área segura: ${locationUpdate.isOutsideSafeZone ? "FORA" : "DENTRO"} - Distância: ${locationUpdate.distanciaDoPerimetro}m');

    // Atualiza informações de área segura
    setState(() {
      _isOutsideSafeZone = locationUpdate.isOutsideSafeZone;
      _distanceFromPerimeter = locationUpdate.distanciaDoPerimetro;
    });

    // Cria LocationData a partir do LocationUpdate
    final newLocation = LocationData(
      id: 'websocket-${DateTime.now().millisecondsSinceEpoch}',
      data: locationUpdate.timestamp,
      latitude: locationUpdate.latitude,
      longitude: locationUpdate.longitude,
      animal: locationUpdate.animalId,
      coleira: locationUpdate.coleiraId,
    );

    // Atualiza a localização usando o método unificado
    // CORREÇÃO: shouldAnimate = true para recentralizar automaticamente
    updateAnimalLocation(newLocation, shouldAnimate: true);
  }

  /// MÉTODO UNIFICADO DE ATUALIZAÇÃO
  /// Atualiza a posição do animal no mapa e o endereço exibido
  /// Chamado tanto pelo botão de centralização quanto pelo WebSocket
  Future<void> updateAnimalLocation(LocationData newLocation, {bool shouldAnimate = true}) async {
    debugPrint('🔄 Atualizando localização do animal...');

    // Atualiza a localização atual
    setState(() {
      _currentLocation = newLocation;
    });

    // Atualiza o marcador no mapa
    await _createMarker(newLocation);

    // Busca o novo endereço
    await _updateAddress(newLocation.latitude, newLocation.longitude);

    // Anima o mapa para a nova posição (se solicitado)
    if (shouldAnimate) {
      _animateToLocation(newLocation.latitude, newLocation.longitude);
    }
  }

  /// Atualiza o endereço a partir das coordenadas
  Future<void> _updateAddress(double latitude, double longitude) async {
    try {
      final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      if (googleMapsApiKey.isNotEmpty) {
        final address = await _locationService.getEnderecoFromCoordinates(
          latitude,
          longitude,
          googleMapsApiKey,
        );
        if (mounted) {
          setState(() {
            _address = address ?? 'Endereço não disponível';
          });
        }
        debugPrint('📍 Endereço atualizado: $_address');
      } else {
        if (mounted) {
          setState(() {
            _address = 'API Key do Google Maps não configurada';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar endereço: $e');
      if (mounted) {
        setState(() {
          _address = 'Erro ao buscar endereço';
        });
      }
    }
  }

  /// Carrega a última localização do animal (chamado apenas no initState)
  Future<void> _loadAnimalLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Busca a última localização do animal
      final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);

      if (location != null) {
        // Usa o método unificado para atualizar tudo
        await updateAnimalLocation(location, shouldAnimate: true);
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
      // CORREÇÃO: Pré-carrega a imagem antes de criar o marcador
      await _precacheAnimalImage();

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

  /// Pré-carrega a imagem do animal para garantir que esteja disponível
  Future<void> _precacheAnimalImage() async {
    try {
      final bool temImagem = widget.animalImageUrl != null && widget.animalImageUrl!.isNotEmpty;

      final String imagePath = temImagem
          ? widget.animalImageUrl!
          : (widget.animalSpecies == Species.cat
              ? 'assets/images/gato_default.png'
              : 'assets/images/cachorro_default.png');

      // Pré-carrega a imagem
      await precacheImage(AssetImage(imagePath), context);
      debugPrint('✅ Imagem do marcador pré-carregada: $imagePath');
    } catch (e) {
      debugPrint('⚠️ Erro ao pré-carregar imagem: $e');
      // Continua mesmo se falhar - o marcador será criado com imagem padrão
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

    // CORREÇÃO: Aumenta o delay para garantir que a imagem seja carregada
    await Future.delayed(const Duration(milliseconds: 150));
    await WidgetsBinding.instance.endOfFrame;

    // Aguarda mais um frame para garantir renderização completa
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Erro ao capturar RenderRepaintBoundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      entry.remove();
      debugPrint('✅ Marcador criado com sucesso');
      return bytes;
    } catch (e) {
      entry.remove();
      debugPrint('❌ Erro ao criar marcador: $e');
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
  /// Também recarrega o endereço (útil se o usuário moveu o mapa)
  Future<void> _centerOnAnimalLocation() async {
    if (_currentLocation != null) {
      debugPrint('🎯 Botão de centralização pressionado');
      // Recarrega a localização mais recente da API
      try {
        final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);
        if (location != null) {
          // Usa o método unificado para atualizar posição e endereço
          await updateAnimalLocation(location, shouldAnimate: true);
        }
      } catch (e) {
        debugPrint('❌ Erro ao recarregar localização: $e');
        // Se falhar, apenas centraliza na última posição conhecida
        _animateToLocation(_currentLocation!.latitude, _currentLocation!.longitude);
      }
    }
  }

  /// Navega para a tela de definição de área segura
  void _navigateToDefineSafeArea() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aguarde o carregamento da localização',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DefineSafeAreaScreen(
          animalId: widget.animalId,
          animalName: widget.animalName,
          initialLocation: _currentLocation!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService.disconnect();
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

          // PetAddressCard - Exibe o endereço do animal e status da área segura
          if (_address != null && !_isLoading)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: PetAddressCard(
                petName: widget.animalName,
                address: _address!,
                isOutsideSafeZone: _isOutsideSafeZone,
                distanceFromPerimeter: _distanceFromPerimeter,
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

          // Botão "Definir área segura" - Canto inferior esquerdo, acima da NavBar
          if (_currentLocation != null && !_isLoading)
            Positioned(
              bottom: 100,
              left: 16,
              child: FloatingActionButton.extended(
                onPressed: _navigateToDefineSafeArea,
                backgroundColor: Colors.blue.shade600,
                icon: const Icon(Icons.shield_outlined, color: Colors.white),
                label: Text(
                  'Definir área segura',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

