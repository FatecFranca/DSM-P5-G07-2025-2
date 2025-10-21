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
import 'package:PetDex/services/safe_area_service.dart' as safe_area;
import 'package:PetDex/services/logger_service.dart';
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
  final SpeciesEnum animalSpecies;
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
  final safe_area.SafeAreaService _safeAreaService = safe_area.SafeAreaService();

  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // Círculos para visualizar a área segura
  bool _isLoading = true;
  String? _errorMessage;
  String? _address; // Endereço formatado
  bool _isInitialized = false; // Flag para evitar inicializações duplicadas
  String? _animalName; // Nome do animal (buscado da API)

  // Informações de área segura
  bool? _isOutsideSafeZone;
  double? _distanceFromPerimeter;
  safe_area.SafeArea? _safeArea; // Área segura do animal (buscada da API)

  // Subscriptions do WebSocket
  StreamSubscription<LocationUpdate>? _locationSubscription;

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
  /// REPLICADO EXATAMENTE DO MapScreen
  Future<void> _initializeApp() async {
    // Evita inicializações duplicadas
    if (_isInitialized) {
      return;
    }

    try {
      await _loadAnimalLocation();
      _initializeWebSocket();
      await _initializeNotifications();
      _isInitialized = true;
    } catch (e) {
      LoggerService.error('❌ Erro ao inicializar LocationScreen: $e', error: e);
    }
  }

  /// Inicializa o serviço de notificações
  /// REPLICADO EXATAMENTE DO MapScreen
  Future<void> _initializeNotifications() async {
    try {
      await _webSocketService.initializeNotifications(petName: widget.animalName);
    } catch (e) {
      LoggerService.error('❌ Erro ao inicializar notificações: $e', error: e);
    }
  }

  /// Inicializa o WebSocket e seus listeners
  /// REPLICADO EXATAMENTE DO MapScreen
  void _initializeWebSocket() {
    try {
      LoggerService.websocket('🔌 Inicializando WebSocket para animal: ${widget.animalId}');

      // Cancela subscription anterior se existir
      _locationSubscription?.cancel();

      _locationSubscription = _webSocketServiceLocationStreamListener();
      _webSocketService.connect(widget.animalId);

      LoggerService.success('✅ WebSocket inicializado');
    } catch (e) {
      LoggerService.error('❌ Erro ao inicializar WebSocket: $e', error: e);
    }
  }

  /// Listener do WebSocket para atualizações de localização
  /// REPLICADO EXATAMENTE DO MapScreen
  StreamSubscription<LocationUpdate>? _webSocketServiceLocationStreamListener() {
    return _webSocketService.locationStream.listen((locationUpdate) {
      _handleWebSocketLocationUpdate(locationUpdate);
    });
  }

  /// Processa atualizações de localização recebidas via WebSocket
  /// Processa atualizações de localização recebidas via WebSocket
  /// REPLICADO EXATAMENTE DO MapScreen
  void _handleWebSocketLocationUpdate(LocationUpdate locationUpdate) {
    if (locationUpdate.animalId == widget.animalId) {
      LoggerService.debug('📍 WebSocket: Nova localização recebida - Lat: ${locationUpdate.latitude}, Lng: ${locationUpdate.longitude}');
      LoggerService.debug('🔒 Área segura: ${locationUpdate.isOutsideSafeZone ? "FORA" : "DENTRO"} - Distância: ${locationUpdate.distanciaDoPerimetro}m');

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
        _isOutsideSafeZone = locationUpdate.isOutsideSafeZone;
        _distanceFromPerimeter = locationUpdate.distanciaDoPerimetro;
      });

      _createMarker(newLocation);
      _animateToLocation(locationUpdate.latitude, locationUpdate.longitude);
    }
  }

  /// MÉTODO UNIFICADO DE ATUALIZAÇÃO
  /// Atualiza a posição do animal no mapa e o endereço exibido
  /// Chamado tanto pelo botão de centralização quanto pelo WebSocket
  Future<void> updateAnimalLocation(LocationData newLocation, {bool shouldAnimate = true}) async {
    // Atualiza a localização atual e informações de área segura
    setState(() {
      _currentLocation = newLocation;
      _isOutsideSafeZone = newLocation.isOutsideSafeZone;
      _distanceFromPerimeter = newLocation.distanciaDoPerimetro;
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
      } else {
        if (mounted) {
          setState(() {
            _address = 'API Key do Google Maps não configurada';
          });
        }
      }
    } catch (e) {
      LoggerService.error('❌ Erro ao atualizar endereço: $e', error: e);
      if (mounted) {
        setState(() {
          _address = 'Erro ao buscar endereço';
        });
      }
    }
  }

  /// Atualiza o círculo de área segura no mapa
  /// Desenha um círculo azul representando a área segura do animal
  /// Usa os dados da área segura buscados da API
  void _updateSafeZoneCircle(LocationData location) {
    // Se não há área segura configurada, não desenha o círculo
    if (_safeArea == null) {
      setState(() {
        _circles = {};
      });
      return;
    }

    // Usa o raio e centro da área segura da API
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('safe_zone_circle'),
          center: LatLng(_safeArea!.latitude, _safeArea!.longitude),
          radius: _safeArea!.raio,
          // Sempre azul na LocationScreen
          fillColor: Colors.blue.withValues(alpha: 0.15),
          strokeColor: Colors.blue.withValues(alpha: 0.7),
          strokeWidth: 2,
        ),
      };
    });
  }

  /// Carrega a última localização do animal (chamado apenas no initState)
  Future<void> _loadAnimalLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Busca a área segura do animal da API
      final safeArea = await _safeAreaService.getSafeAreaByAnimalId(widget.animalId);
      setState(() {
        _safeArea = safeArea;
      });

      // Busca a última localização do animal
      final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);

      if (location != null) {
        // Atualiza informações de área segura da API
        setState(() {
          _isOutsideSafeZone = location.isOutsideSafeZone;
          _distanceFromPerimeter = location.distanciaDoPerimetro;
        });

        // Atualiza o círculo de área segura
        _updateSafeZoneCircle(location);

        await updateAnimalLocation(location, shouldAnimate: true);
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

      if (mounted) {
        setState(() {
          _markers = {marker};
        });
      }
    } catch (e) {
      LoggerService.warning('Erro ao criar marcador do animal: $e');
      // Continua mesmo se falhar - o mapa será exibido sem o marcador
    }
  }

  /// Pré-carrega a imagem do animal para garantir que esteja disponível
  Future<void> _precacheAnimalImage() async {
    try {
      final bool temImagem = widget.animalImageUrl != null && widget.animalImageUrl!.isNotEmpty;

      if (temImagem) {
        final String imageUrl = widget.animalImageUrl!;
        final bool isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

        if (isNetworkImage) {
          // Pré-carrega imagem de rede
          await precacheImage(NetworkImage(imageUrl), context);
        } else {
          // Pré-carrega imagem de asset
          await precacheImage(AssetImage(imageUrl), context);
        }
      } else {
        // Pré-carrega imagem padrão baseada na espécie
        final String imagemPadrao = widget.animalSpecies == SpeciesEnum.cat
            ? 'assets/images/gato-dex.png'
            : 'assets/images/cao-dex.png';
        await precacheImage(AssetImage(imagemPadrao), context);
      }
    } catch (e) {
      LoggerService.warning('Erro ao fazer precache da imagem: $e');
      // Continua mesmo se falhar - o marcador será criado com imagem padrão
    }
  }

  /// Converte um widget (AnimalPin) para Uint8List usando OverlayEntry
  Future<Uint8List> _createMarkerFromWidget(Widget widget, Size size) async {
    final overlayState = Overlay.of(context);

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

    try {
      // CORREÇÃO: Aumenta o delay para garantir que a imagem seja carregada
      // Especialmente importante para imagens de rede
      await Future.delayed(const Duration(milliseconds: 200));
      await WidgetsBinding.instance.endOfFrame;

      // Aguarda mais um frame para garantir renderização completa
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RenderRepaintBoundary não encontrado - widget não foi renderizado');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Falha ao converter imagem para ByteData');
      }

      final bytes = byteData.buffer.asUint8List();
      LoggerService.success('Marcador criado com sucesso: ${bytes.length} bytes');

      return bytes;
    } catch (e) {
      LoggerService.error('Erro ao criar marcador: $e', error: e);
      rethrow;
    } finally {
      entry.remove();
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
  /// Também recarrega a localização, endereço e área segura (útil se o usuário moveu o mapa)
  Future<void> _centerOnAnimalLocation() async {
    if (_currentLocation != null) {
      // Recarrega a localização mais recente da API
      try {
        final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);
        if (location != null) {
          // Recarrega a área segura
          final safeArea = await _locationService.getSafeArea(widget.animalId);
          if (safeArea != null) {
            setState(() {
              _safeArea = safeArea;
            });
            // Atualiza o círculo de área segura
            _updateSafeZoneCircle(location);
          }

          // Usa o método unificado para atualizar posição e endereço
          await updateAnimalLocation(location, shouldAnimate: true);
        }
      } catch (e) {
        // Se falhar, apenas centraliza na última posição conhecida
        _animateToLocation(_currentLocation!.latitude, _currentLocation!.longitude);
      }
    }
  }

  /// Navega para a tela de definição de área segura
  /// Ao retornar, recarrega a área segura e atualiza o círculo
  Future<void> _navigateToDefineSafeArea() async {
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

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DefineSafeAreaScreen(
          animalId: widget.animalId,
          animalName: widget.animalName,
          initialLocation: _currentLocation!,
        ),
      ),
    );

    // Se a área segura foi salva com sucesso, processa o resultado
    if (result != null && mounted) {
      try {
        // Se o resultado é uma LocationData, usa-a diretamente
        if (result is LocationData) {
          final updatedLocation = result;

          // Atualiza a localização e status da área segura
          setState(() {
            _currentLocation = updatedLocation;
            _isOutsideSafeZone = updatedLocation.isOutsideSafeZone;
            _distanceFromPerimeter = updatedLocation.distanciaDoPerimetro;
          });

          // Recarrega a área segura
          final safeArea = await _locationService.getSafeArea(widget.animalId);
          if (safeArea != null) {
            setState(() {
              _safeArea = safeArea;
            });
            // Atualiza o círculo de área segura
            _updateSafeZoneCircle(updatedLocation);
          }

          final statusText = updatedLocation.isOutsideSafeZone ?? false ? "FORA" : "DENTRO";
          final distanceText = updatedLocation.distanciaDoPerimetro?.toStringAsFixed(2) ?? "N/A";
          LoggerService.success('✅ Área segura definida! Status: $statusText - Distância: ${distanceText}m');
        } else if (result == true) {
          // Fallback: se apenas true foi retornado, recarrega os dados
          final safeArea = await _locationService.getSafeArea(widget.animalId);
          if (safeArea != null) {
            setState(() {
              _safeArea = safeArea;
            });
            // Atualiza o círculo de área segura
            _updateSafeZoneCircle(_currentLocation!);
          }
        }
      } catch (e) {
        LoggerService.error('Erro ao processar resultado da área segura: $e', error: e);
      }
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
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
                    zoom: 20.0,
                  )
                : _defaultPosition,
            markers: _markers,
            circles: _circles, // Adiciona os círculos de área segura
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
              color: Colors.black.withValues(alpha: 0.3),
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
                petName: _animalName ?? widget.animalName,
                address: _address!,
                isOutsideSafeZone: _isOutsideSafeZone,
                distanceFromPerimeter: _distanceFromPerimeter,
              ),
            ),

          // Botão de centralização - Bem acima do StatusBar, canto direito
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

          // Botão "Definir área segura" - Acima do botão de centralização, canto esquerdo
          if (_currentLocation != null && !_isLoading)
            Positioned(
              bottom: 250, // Mesma altura do botão de centralização
              left: 16,
              child: FloatingActionButton.extended(
                onPressed: _navigateToDefineSafeArea,
                backgroundColor: Colors.blue.shade700,
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

