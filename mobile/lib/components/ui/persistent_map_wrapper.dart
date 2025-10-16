import 'package:flutter/material.dart';
import 'package:PetDex/screens/map_screen.dart';
import 'package:PetDex/data/enums/species.dart';

class PersistentMapWrapper extends StatefulWidget {
  final String animalId;
  final String animalName;
  final Species animalSpecies;
  final String animalImageUrl;
  final Widget? overlay;

  const PersistentMapWrapper({
    super.key,
    required this.animalId,
    required this.animalName,
    required this.animalSpecies,
    required this.animalImageUrl,
    this.overlay,
  });

  @override
  State<PersistentMapWrapper> createState() => _PersistentMapWrapperState();
}

class _PersistentMapWrapperState extends State<PersistentMapWrapper>
    with AutomaticKeepAliveClientMixin {
  late MapScreen _mapScreen;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapScreen = MapScreen(
      animalId: widget.animalId,
      animalName: widget.animalName,
      animalSpecies: widget.animalSpecies,
      animalImageUrl: widget.animalImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Stack(
      children: [
        _mapScreen,
        if (widget.overlay != null) widget.overlay!,
      ],
    );
  }
}
