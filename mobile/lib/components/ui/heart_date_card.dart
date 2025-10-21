import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/ui/select_date.dart';
import '/services/animal_stats_service.dart';
import '/services/websocket_service.dart';
import '/models/websocket_message.dart';
import '/theme/app_theme.dart';

class HeartDateCard extends StatefulWidget {
  final String animalId;

  const HeartDateCard({
    super.key,
    required this.animalId,
  });

  @override
  State<HeartDateCard> createState() => _HeartDateCardState();
}

class _HeartDateCardState extends State<HeartDateCard> {
  final AnimalStatsService _statsService = AnimalStatsService();
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<HeartrateUpdate>? _heartrateSubscription;

  DateTime _selectedDate = DateTime.now();
  double? _mediaDoDia;
  bool _isLoading = false;
  String? _errorMessage;
  String? _mensagemApi;

  @override
  void initState() {
    super.initState();
    _fetchMediaData(_selectedDate);
    _initializeWebSocketListener();
  }

  /// Inicializa o listener do WebSocket para atualizações de batimento cardíaco
  void _initializeWebSocketListener() {
    _heartrateSubscription = _webSocketService.heartrateStream.listen(
      (heartrateUpdate) {
        // Verifica se a atualização é para o animal correto
        if (heartrateUpdate.animalId == widget.animalId) {
          // Recarrega os dados da data selecionada
          _fetchMediaData(_selectedDate);
        }
      },
    );
  }

  @override
  void dispose() {
    _heartrateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchMediaData(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mediaDoDia = null;
      _mensagemApi = null;
    });

    try {
      final media = await _statsService.getMediaPorData(widget.animalId, date);

      setState(() {
        _mediaDoDia = media;
        if (media == null) {
          _mensagemApi = "Nenhum dado encontrado para o intervalo fornecido.";
        }
      });
    } catch (e) {
      print('Erro em HeartDateCard._fetchMediaData: $e');
      setState(() {
        _errorMessage = "Erro ao buscar dados: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Média de batimento cardíaco por data',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.orange,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubtitle('Selecione uma data:'),
          const SizedBox(height: 8),
          SelectDate(
            initialDate: _selectedDate,
            onDateSelected: (newDate) {
              setState(() {
                _selectedDate = newDate;
              });
              _fetchMediaData(newDate);
            },
          ),
          const SizedBox(height: 16),
          _buildSubtitle('Resultado:'),
          const SizedBox(height: 8),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.orange900,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(color: AppColors.orange900),
      );
    }
    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 14,
          height: 1.5,
        ),
      );
    }
    if (_mediaDoDia != null) {
      return Text(
        '${_mediaDoDia!.toInt()} BPM',
        style: GoogleFonts.poppins(
          color: AppColors.black400,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    if (_mensagemApi != null) {
      return Text(
        _mensagemApi!,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: AppColors.black400,
          fontSize: 14,
          height: 1.5,
        ),
      );
    }
    return Text(
      'Sem dados',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: AppColors.black400,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}
