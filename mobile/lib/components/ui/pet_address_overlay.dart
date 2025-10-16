import 'package:flutter/material.dart';
import 'package:PetDex/components/ui/pet_address_card.dart';
import 'package:PetDex/services/location_service.dart';
import 'package:PetDex/services/shared_map_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PetAddressOverlay extends StatefulWidget {
  final String animalId;
  final String animalName;

  const PetAddressOverlay({
    super.key,
    required this.animalId,
    required this.animalName,
  });

  @override
  State<PetAddressOverlay> createState() => _PetAddressOverlayState();
}

class _PetAddressOverlayState extends State<PetAddressOverlay> {
  final LocationService _locationService = LocationService();
  final SharedMapState _mapState = SharedMapState();
  String _address = 'Carregando localização...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapState.addListener(_onLocationChanged);
    _loadAddress();
  }

  @override
  void dispose() {
    _mapState.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    if (_mapState.currentLocation != null) {
      _loadAddressFromLocation(_mapState.currentLocation!);
    }
  }

  Future<void> _loadAddress() async {
    if (_mapState.currentLocation != null) {
      await _loadAddressFromLocation(_mapState.currentLocation!);
    } else {
      try {
        final location = await _locationService.getUltimaLocalizacaoAnimal(widget.animalId);
        if (location != null) {
          await _loadAddressFromLocation(location);
        } else {
          setState(() {
            _address = 'Localização não encontrada';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _address = 'Erro ao carregar localização';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAddressFromLocation(location) async {
    try {
      setState(() {
        _isLoading = true;
        _address = 'Carregando endereço...';
      });

      final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      if (googleMapsApiKey.isNotEmpty) {
        final address = await _locationService.getEnderecoFromCoordinates(
          location.latitude,
          location.longitude,
          googleMapsApiKey,
        );

        setState(() {
          _address = address ?? 'Endereço não encontrado';
        });
      } else {
        setState(() {
          _address = 'Chave da API do Google Maps não configurada';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Erro ao carregar endereço';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: SafeArea(
        child: PetAddressCard(
          petName: widget.animalName,
          address: _address,
        ),
      ),
    );
  }
}
