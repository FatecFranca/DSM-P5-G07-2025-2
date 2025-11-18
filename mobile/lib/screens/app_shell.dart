import 'dart:async';
import 'package:PetDex/screens/checkup_screen.dart';
import 'package:flutter/material.dart';
import 'package:PetDex/components/ui/bottom_nav_with_status.dart';
import 'package:PetDex/screens/map_screen.dart';
import 'package:PetDex/screens/health_screen.dart';
import 'package:PetDex/screens/location_screen.dart';
import 'package:PetDex/data/enums/species.dart';
import 'package:PetDex/services/websocket_service.dart';
import 'package:PetDex/main.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/screens/login_screen.dart';

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
  late final String _animalId;
  late final String _animalName;

  @override
  void initState() {
    super.initState();

    _animalId = authService.getAnimalId() ?? '';
    _animalName = authService.getPetName() ?? 'Pet';

    _pages = [
      MapScreen(
        animalId: _animalId,
        animalName: _animalName,
        animalSpecies: SpeciesEnum.dog,
        animalImageUrl: "assets/images/uno.png",
      ),
      HealthScreen(
        animalId: _animalId,
        animalName: _animalName,
      ),
      const CheckupScreen(),
      LocationScreen(
        animalId: _animalId,
        animalName: _animalName,
        animalSpecies: SpeciesEnum.dog,
        animalImageUrl: "assets/images/uno.png",
      ),
    ];

    _connectionSubscription =
        _webSocketService.connectionStream.listen((isConnected) {
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
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),

          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                await authService.logout();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você saiu da conta.'),
                      backgroundColor: AppColors.orange200,
                    ),
                  );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.orange400,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          /// 🔻 Bottom Navigation fixado
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavWithStatus(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              animalId: _animalId,
              isConnected: _isWebSocketConnected,
            ),
          ),
        ],
      ),
    );
  }
}
