import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/ui/select_date.dart';
import '/services/animal_stats_service.dart';
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

  DateTime _selectedDate = DateTime.now();
  double? _mediaDoDia;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMediaData(_selectedDate);
  }

  Future<void> _fetchMediaData(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mediaDoDia = null;
    });

    try {
      final media = await _statsService.getMediaPorData(widget.animalId, date);

      setState(() {
        _mediaDoDia = media;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao buscar dados.";
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle('Média de Batimento Cardíaco por Data'),
          const SizedBox(height: 16),
          _buildTitle('Selecione uma Data:'),
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
          _buildTitle('Resultado:'),
          const SizedBox(height: 8),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
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
        style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
      );
    }
    if (_mediaDoDia != null) {
      return Text(
        '${_mediaDoDia!.toStringAsFixed(2)} BPM',
        style: GoogleFonts.poppins(
          color: AppColors.black400,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      'Sem dados',
      style: GoogleFonts.poppins(color: AppColors.black200, fontSize: 16),
    );
  }
}
