import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/animal.dart';
import '/models/heartbeat_data.dart';
import '/services/animal_service.dart';
import '/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'heart_chart_bar.dart';

class StatusBar extends StatefulWidget {
  final String animalId;

  const StatusBar({super.key, required this.animalId});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _heightAnimation;

  final AnimalService _animalService = AnimalService();
  Animal? _animalInfo;
  List<HeartbeatData>? _heartbeatHistory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(begin: 150, end: 400).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _animalService.getAnimalInfo(widget.animalId),
        _animalService.getHeartbeatHistory(widget.animalId),
      ]);
      if (mounted) {
        setState(() {
          _animalInfo = results[0] as Animal;
          _heartbeatHistory = results[1] as List<HeartbeatData>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao buscar dados do StatusBar: $e");
      if (mounted) setState(() => _isLoading = false);
    }
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        final height = _isExpanded ? _heightAnimation.value : 150.0;
        return Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))]
          ),
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orange));
    }

    if (_animalInfo == null) {
      return Center(
        child: Text(
          'Não foi possível carregar os dados do pet.',
          style: GoogleFonts.poppins(color: AppColors.black400),
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
          if (_isExpanded && _heartbeatHistory != null) _buildChart(),
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
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoBlock() {
    final latestHeartbeat = _heartbeatHistory?.isNotEmpty == true ? _heartbeatHistory!.last.value.toInt() : '--';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage: NetworkImage(_animalInfo!.imageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _animalInfo!.name,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black400),
                  ),
                  const SizedBox(width: 8),
                  FaIcon(
                    _animalInfo!.sex.toUpperCase() == 'MACHO' ? FontAwesomeIcons.mars : FontAwesomeIcons.venus,
                    size: 20,
                    color: _animalInfo!.sex.toUpperCase() == 'MACHO' ? Colors.blue : Colors.pink,
                  ),
                ],
              ),
              Text(
                'Status da PetDex: Conectado',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  latestHeartbeat.toString(),
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black400),
                ),
                const SizedBox(width: 2),
                const FaIcon(FontAwesomeIcons.heartPulse, color: Colors.red, size: 16),
                Text('BPM', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.black400)),
              ],
            ),
            Text('96%', style: GoogleFonts.poppins(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
  
  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: HeartChartBar(
        title: 'Média de batimentos dos últimos cinco dias:',
        data: _heartbeatHistory!,
      ),
    );
  }
}