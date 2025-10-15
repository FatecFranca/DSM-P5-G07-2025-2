import 'package:PetDex/screens/map_screen.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MapScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: Species.dog,
        animalImageUrl: "https://love.doghero.com.br/wp-content/uploads/2018/12/golden-retriever-1.png",
      ),
    );
  }
}
