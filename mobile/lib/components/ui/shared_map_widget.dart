import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/services/shared_map_state.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/components/ui/animal_pin.dart';

class SharedMapWidget extends StatefulWidget {
  final String animalId;
  final String animalName;
  final Species animalSpecies;
  final String? animalImageUrl;
  final bool showCenterButton;
  final Widget? overlay;

  const SharedMapWidget({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.animalSpecies,
    this.animalImageUrl,
    this.showCenterButton = true,
    this.overlay,
  });

  @override
  State<SharedMapWidget> createState() => _SharedMapWidgetState();
}

class _SharedMapWidgetState extends State<SharedMapWidget>
    with AutomaticKeepAliveClientMixin {
  final SharedMapState _mapState = SharedMapState();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapState.addListener(_onMapStateChanged);
    _mapState.initialize(widget.animalId, widget.animalName, widget.animalSpecies, widget.animalImageUrl);
    _createCustomMarker();
  }

  Future<void> _createCustomMarker() async {
    if (_mapState.currentLocation != null) {
      final customIcon = await _createAnimalMarkerIcon();
      _mapState.updateMarkerIcon(customIcon);
    }
  }

  Future<BitmapDescriptor> _createAnimalMarkerIcon() async {
    try {
      final Uint8List markerBytes = await _createMarkerFromWidget(
        AnimalPin(
          imageUrl: widget.animalImageUrl,
          especie: widget.animalSpecies,
          size: 64,
        ),
        const Size(88, 88),
      );
      return BitmapDescriptor.bytes(markerBytes);
    } catch (e) {
      debugPrint('Erro ao criar marcador personalizado: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<Uint8List> _createMarkerFromWidget(Widget widget, Size size) async {
    final overlayState = Overlay.of(context);
    final devicePixelRatio = View.of(context).devicePixelRatio;

    final key = GlobalKey();
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: -1000,
        top: -1000,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: widget,
            ),
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

      final ui.Image image = await boundary.toImage(pixelRatio: devicePixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      entry.remove();
      return bytes;
    } catch (e) {
      entry.remove();
      rethrow;
    }
  }

  @override
  void dispose() {
    _mapState.removeListener(_onMapStateChanged);
    super.dispose();
  }

  void _onMapStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapState.setMapController(controller);
          },
          initialCameraPosition: _mapState.currentLocation != null
              ? CameraPosition(
                  target: LatLng(
                    _mapState.currentLocation!.latitude,
                    _mapState.currentLocation!.longitude,
                  ),
                  zoom: 16.0,
                )
              : _mapState.defaultPosition,
          markers: _mapState.markers,
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

        if (_mapState.isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.orange400),
            ),
          ),

        if (_mapState.errorMessage != null)
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
                      _mapState.errorMessage!,
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
              color: _mapState.isWebSocketConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _mapState.isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _mapState.isWebSocketConnected ? 'Conectado' : 'Desconectado',
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

        if (widget.showCenterButton)
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                print('Botão pressionado!');
                print('Current location: ${_mapState.currentLocation}');
                print('Map controller: ${_mapState.mapController}');

                if (_mapState.currentLocation != null) {
                  print('Animando para: ${_mapState.currentLocation!.latitude}, ${_mapState.currentLocation!.longitude}');
                  _mapState.animateToLocation(
                    _mapState.currentLocation!.latitude,
                    _mapState.currentLocation!.longitude,
                  );
                } else {
                  print('Localização atual é null!');
                  _mapState.reloadLocation(widget.animalId, context);
                }
              },
              backgroundColor: AppColors.orange400,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

        if (widget.overlay != null) widget.overlay!,
      ],
    );
  }
}
