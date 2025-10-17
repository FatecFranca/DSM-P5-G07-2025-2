import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/animal.dart';
import '/models/heartbeat_data.dart';
import '/models/latest_heartbeat.dart';
import '/services/animal_service.dart';
import '/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'heart_chart_bar.dart';

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

class _StatusBarState extends State<StatusBar> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _heightAnimation;

  final AnimalService _animalService = AnimalService();
  Animal? _animalInfo;
  LatestHeartbeat? _latestHeartbeat;
  List<HeartbeatData>? _heartbeatHistory;
  bool _isLoading = true;
  int _retryCount = 0;
  Timer? _retryTimer;

  static const double _collapsedHeight = 150.0;
  static const double _expandedHeight = 420.0;
  static const int _maxRetries = 5; // Máximo de tentativas
  static const int _retryDelaySeconds = 3; // Delay inicial entre tentativas

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(begin: _collapsedHeight, end: _expandedHeight).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchData();
  }

  @override
  void didUpdateWidget(StatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza a UI quando o status de conexão mudar
    if (oldWidget.isConnected != widget.isConnected) {
      debugPrint('🔄 Status de conexão mudou: ${widget.isConnected ? "Conectado" : "Desconectado"}');
      setState(() {
        // Força rebuild para atualizar o indicador de conexão
      });
    }
  }

  /// Busca os dados do StatusBar com retry automático
  Future<void> _fetchData() async {
    if (!mounted) return;

    try {
      debugPrint('📡 Tentativa ${_retryCount + 1}/$_maxRetries de buscar dados do StatusBar...');

      // Adiciona timeout para evitar travamentos
      final results = await Future.wait<dynamic>([
        _animalService.getAnimalInfo(widget.animalId),
        _animalService.getLatestHeartbeat(widget.animalId),
        _animalService.getHeartbeatHistory(widget.animalId),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ Timeout ao buscar dados do StatusBar');
          throw TimeoutException('Timeout ao buscar dados');
        },
      );

      if (!mounted) return;

      // ✅ Sucesso! Cancela qualquer retry pendente
      _retryTimer?.cancel();
      _retryCount = 0;

      setState(() {
        _animalInfo = results[0] as Animal?;
        _latestHeartbeat = results[1] as LatestHeartbeat?;
        _heartbeatHistory = results[2] as List<HeartbeatData>?;
        _isLoading = false;
      });

      debugPrint('✅ Dados do StatusBar carregados com sucesso!');
    } catch (e) {
      debugPrint("❌ Erro ao buscar dados do StatusBar (tentativa ${_retryCount + 1}/$_maxRetries): $e");

      if (!mounted) return;

      // Se ainda não atingiu o máximo de tentativas, agenda retry
      if (_retryCount < _maxRetries) {
        _scheduleRetry();
      } else {
        // Atingiu o máximo de tentativas, para de tentar
        debugPrint('❌ Máximo de tentativas atingido. Parando retry.');
        setState(() => _isLoading = false);
      }
    }
  }

  /// Agenda uma nova tentativa de buscar dados com backoff exponencial
  void _scheduleRetry() {
    if (!mounted) return;

    _retryCount++;

    // Backoff exponencial: 3s, 6s, 12s, 24s, 48s
    final delaySeconds = _retryDelaySeconds * (1 << (_retryCount - 1));

    debugPrint('🔄 Agendando nova tentativa em ${delaySeconds}s...');

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted) {
        _fetchData();
      }
    });
  }

  void _toggleExpand() {
    if (_animalInfo != null) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _retryTimer?.cancel(); // Cancela retry pendente
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          height: _heightAnimation.value,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.sand100,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
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
                ? 'Tentando reconectar... (${_retryCount}/$_maxRetries)'
                : 'Carregando dados do pet...',
              style: GoogleFonts.poppins(
                color: AppColors.black400,
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
            const Icon(
              Icons.error_outline,
              color: AppColors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar os dados do pet.',
              style: GoogleFonts.poppins(
                color: AppColors.black400,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _retryCount = 0;
                });
                _fetchData();
              },
              icon: const Icon(Icons.refresh, color: AppColors.orange),
              label: Text(
                'Tentar novamente',
                style: GoogleFonts.poppins(color: AppColors.orange),
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildInfoBlock(),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildChart(),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
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
          _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: AppColors.orange900,
        ),
      ),
    );
  }

  Widget _buildInfoBlock() {
    final latestHeartbeatValue = _latestHeartbeat?.frequenciaMedia.toString() ?? '--';
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
                      style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.orange900),
                    ),
                    const SizedBox(width: 8),
                    FaIcon(
                      _animalInfo!.sexo.toUpperCase() == 'M' ? FontAwesomeIcons.mars : FontAwesomeIcons.venus,
                      size: 24,
                      color: AppColors.orange900,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                // 👇 CORREÇÃO AQUI: A Row agora encolhe para caber o conteúdo
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isConnected ? 'Conectado' : 'Desconectado',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[700],
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
                  )
                ],
              )
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
                    style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.black400),
                  ),
                  const SizedBox(width: 4),
                  const FaIcon(FontAwesomeIcons.heartPulse, color: AppColors.orange, size: 24),
                  const SizedBox(width: 4),
                  Text('BPM', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black400)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: -1.57,
                    child: const FaIcon(batteryIcon, color: Colors.green, size: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$batteryLevel%', 
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.black400, fontWeight: FontWeight.w600)
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
  
  Widget _buildChart() {
    if (_heartbeatHistory == null || _heartbeatHistory!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: HeartChartBar(
        title: 'Média de batimentos dos últimos cinco dias:',
        data: _heartbeatHistory!,
      ),
    );
  }
}