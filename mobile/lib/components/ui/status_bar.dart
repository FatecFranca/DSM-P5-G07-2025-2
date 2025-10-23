import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/animal.dart';
import '/models/heartbeat_data.dart';
import '/models/latest_heartbeat.dart';
import '/models/websocket_message.dart'; // HeartrateUpdate
import '/services/animal_service.dart';
import '/services/websocket_service.dart';
import '/services/animal_stats_service.dart'; // <- nova
import '/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:PetDex/components/ui/heart_line_chart.dart';

class StatusBar extends StatefulWidget {
  final String animalId;
  final bool isConnected;

  const StatusBar({
    super.key,
    required this.animalId,
    required this.isConnected,
  });

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isClosing = false; // indica que está em processo de fechamento
  bool _showExpandedContent =
      false; // mantém conteúdo visível até o fim da animação de fechamento
  bool _showArrowDown = false; // controla quando a seta muda de direção
  late final AnimationController _animationController;
  late Animation<double> _heightAnimation;

  final AnimalService _animalService = AnimalService();
  final WebSocketService _webSocketService = WebSocketService();
  final AnimalStatsService _statsService =
      AnimalStatsService(); // <- para API Python

  Animal? _animalInfo;
  LatestHeartbeat? _latestHeartbeat;
  List<HeartbeatData>? _heartbeatHistory; // <- dados reais da API
  bool _isLoading = true;
  int _retryCount = 0;
  Timer? _retryTimer;
  StreamSubscription<HeartrateUpdate>? _heartrateSubscription;

  static const double _collapsedHeight = 160.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Progresso de 0.0 a 1.0; usaremos esse valor para interpolar a altura
    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Inicia como totalmente "colapsado" (t = 1 no ramo de colapso)
    _animationController.value = 1.0;

    _fetchData();
    _initializeWebSocketListener();

    // Listener para controlar a visibilidade do conteúdo e a direção da seta
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isClosing) {
          // Ao terminar de fechar, finaliza o fechamento
          if (mounted) {
            setState(() {
              _isExpanded = false;
              _isClosing = false;
              _showExpandedContent = false;
              _showArrowDown = false;
            });
          }
        } else if (_isExpanded) {
          // Ao terminar de abrir, garante que a seta está para baixo
          if (mounted) {
            setState(() {
              _showArrowDown = true;
            });
          }
        }
      }
    });
  }

  void _initializeWebSocketListener() {
    _heartrateSubscription = _webSocketService.heartrateStream.listen((
      HeartrateUpdate update,
    ) {
      if (update.animalId == widget.animalId) {
        if (mounted) {
          setState(() {
            _latestHeartbeat = LatestHeartbeat(
              frequenciaMedia: update.frequenciaMedia,
            );
          });
          _reloadHeartbeatHistory();
        }
      }
    });
  }

  Future<void> _reloadHeartbeatHistory() async {
    try {
      final history = await _statsService.getMediaUltimas5HorasRegistradas(
        widget.animalId,
      ); // <- dados reais
      if (mounted) {
        setState(() {
          _heartbeatHistory = history;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    try {
      final results =
          await Future.wait<dynamic>([
            _animalService.getAnimalInfo(widget.animalId),
            _animalService.getLatestHeartbeat(widget.animalId),
            _statsService.getMediaUltimas5HorasRegistradas(
              widget.animalId,
            ), // <- pega da API Python
          ]).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Timeout ao buscar dados'),
          );

      if (!mounted) return;

      _retryTimer?.cancel();
      _retryCount = 0;

      setState(() {
        _animalInfo = results[0] as Animal?;
        _latestHeartbeat = results[1] as LatestHeartbeat?;
        _heartbeatHistory = results[2] as List<HeartbeatData>?;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Erro ao buscar dados (tentativa ${_retryCount + 1}/5): $e");

      if (!mounted) return;

      if (_retryCount < 5) {
        _scheduleRetry();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scheduleRetry() {
    if (!mounted) return;
    _retryCount++;
    final delaySeconds = 3 * (1 << (_retryCount - 1));
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted) _fetchData();
    });
  }

  void _toggleExpand() {
    if (_animalInfo != null) {
      final willExpand = !_isExpanded;

      if (willExpand) {
        // Ao abrir: mostra o conteúdo e já muda a seta imediatamente
        setState(() {
          _isExpanded = true;
          _showExpandedContent = true;
          _showArrowDown = true;
        });
        // Dispara a animação de 0 -> 1 para expandir
        _animationController.forward(from: 0);
      } else {
        // Ao fechar: marca como fechando mas mantém _isExpanded = true
        // para que a animação use a fórmula correta
        setState(() {
          _isClosing = true;
        });
        // Dispara a animação de 0 -> 1 para contrair
        // O _isExpanded só mudará quando a animação terminar (no listener)
        _animationController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _heartrateSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        final t = _heightAnimation.value;
        final currentHeight = (_isExpanded && !_isClosing)
            ? _collapsedHeight + t * (maxHeight - _collapsedHeight) // Abrindo
            : _isClosing
                ? maxHeight - t * (maxHeight - _collapsedHeight) // Fechando
                : _collapsedHeight; // Fechado

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.sand100,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          constraints: BoxConstraints(
            minHeight: _collapsedHeight,
            maxHeight: currentHeight,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.sand100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.orange),
            const SizedBox(height: 16),
            Text(
              _retryCount > 0
                  ? 'Tentando reconectar... ($_retryCount/5)'
                  : 'Carregando dados do pet...',
              style: GoogleFonts.poppins(
                color: AppColors.brown,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (_animalInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.orange, size: 48),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar os dados do pet.',
              style: GoogleFonts.poppins(
                color: AppColors.brown,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildInfoBlock(),
          if (_showExpandedContent)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: HeartLineChart(
                title: 'Batimentos - Últimas 5 horas',
                data: _heartbeatHistory ?? [],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        width: 100,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _showArrowDown ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: AppColors.brown,
        ),
      ),
    );
  }

  Widget _buildInfoBlock() {
    final latestHeartbeatValue =
        _latestHeartbeat?.frequenciaMedia.toString() ?? '--';
    const batteryLevel = 96;
    const batteryIcon = FontAwesomeIcons.batteryFull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/uno.png'),
          backgroundColor: AppColors.sand200,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _animalInfo!.nome,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FaIcon(
                      _animalInfo!.sexo.toUpperCase() == 'M'
                          ? FontAwesomeIcons.mars
                          : FontAwesomeIcons.venus,
                      size: 24,
                      color: AppColors.orange900,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isConnected ? 'Conectado' : 'Desconectado',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.brown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                children: [
                  Text(
                    latestHeartbeatValue,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const FaIcon(
                    FontAwesomeIcons.heartPulse,
                    color: AppColors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BPM',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: -1.57,
                    child: const FaIcon(
                      batteryIcon,
                      color: Colors.green,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$batteryLevel%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
