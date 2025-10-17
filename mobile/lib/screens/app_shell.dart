import 'dart:async';
import 'package:flutter/material.dart';
import 'package:PetDex/components/ui/bottom_nav_with_status.dart';
import 'package:PetDex/screens/map_screen.dart';
import 'package:PetDex/screens/health_screen.dart';
import 'package:PetDex/screens/location_screen.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/services/websocket_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _isWebSocketConnected = false;
  StreamSubscription<bool>? _connectionSubscription;
  final WebSocketService _webSocketService = WebSocketService();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      MapScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: SpeciesEnum.dog,
        animalImageUrl: "lib/assets/images/uno.png",
      ),
      HealthScreen(),
      LocationScreen(
        animalId: "68194120636f719fcd5ee5fd",
        animalName: "Uno",
        animalSpecies: SpeciesEnum.dog,
        animalImageUrl: "lib/assets/images/uno.png",
      ),
    ];

    // Escuta mudanças no estado de conexão WebSocket
    _connectionSubscription = _webSocketService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isWebSocketConnected = isConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Conteúdo das páginas (ocupa toda a tela)
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Overlay do BottomNavWithStatus (posicionado na parte inferior)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavWithStatus(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              animalId: "68194120636f719fcd5ee5fd", // ID do animal (Uno)
              isConnected: _isWebSocketConnected,
            ),
          ),
        ],
      ),
    );
  }
}

