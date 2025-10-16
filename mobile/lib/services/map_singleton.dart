import 'package:PetDex/screens/map_screen.dart';
import 'package:PetDex/data/enums/species.dart';

class MapSingleton {
  static final MapSingleton _instance = MapSingleton._internal();
  factory MapSingleton() => _instance;
  MapSingleton._internal();

  MapScreen? _mapScreenWithButton;
  MapScreen? _mapScreenWithoutButton;

  MapScreen getMapScreen({bool showCenterButton = true}) {
    if (showCenterButton) {
      _mapScreenWithButton ??= const MapScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: Species.dog,
        animalImageUrl: "lib/assets/images/uno.png",
        showCenterButton: true,
      );
      return _mapScreenWithButton!;
    } else {
      _mapScreenWithoutButton ??= const MapScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: Species.dog,
        animalImageUrl: "lib/assets/images/uno.png",
        showCenterButton: false,
      );
      return _mapScreenWithoutButton!;
    }
  }

  void dispose() {
    _mapScreenWithButton = null;
    _mapScreenWithoutButton = null;
  }
}
