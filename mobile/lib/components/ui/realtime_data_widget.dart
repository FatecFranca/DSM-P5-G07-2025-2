import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/websocket_message.dart';
import '../../services/websocket_service.dart';
import '../../services/logger_service.dart';

class RealtimeDataWidget extends StatefulWidget {
  final String animalId;

  const RealtimeDataWidget({
    super.key,
    required this.animalId,
  });

  @override
  State<RealtimeDataWidget> createState() => _RealtimeDataWidgetState();
}

class _RealtimeDataWidgetState extends State<RealtimeDataWidget> {
  final WebSocketService _webSocketService = WebSocketService();
  
  LocationUpdate? _lastLocation;
  HeartrateUpdate? _lastHeartrate;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _webSocketService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    });

    _webSocketService.locationStream.listen((locationUpdate) {
      if (mounted) {
        LoggerService.debug('🎯 ===== LOCALIZAÇÃO CHEGOU NA INTERFACE =====');
        LoggerService.debug('📱 Animal ID: ${locationUpdate.animalId}');
        LoggerService.debug('📱 Latitude: ${locationUpdate.latitude}');
        LoggerService.debug('📱 Longitude: ${locationUpdate.longitude}');
        LoggerService.debug('📱 Zona Segura: ${locationUpdate.isOutsideSafeZone ? "FORA" : "DENTRO"}');
        LoggerService.debug('📱 Atualizando interface...');
        setState(() {
          _lastLocation = locationUpdate;
        });
        LoggerService.debug('📱 Interface atualizada com sucesso!');
        LoggerService.debug('🎯 ==========================================');
      }
    });

    _webSocketService.heartrateStream.listen((heartrateUpdate) {
      if (mounted) {
        LoggerService.debug('💓 ===== BATIMENTO CHEGOU NA INTERFACE =====');
        LoggerService.debug('📱 Animal ID: ${heartrateUpdate.animalId}');
        LoggerService.debug('📱 Frequência: ${heartrateUpdate.frequenciaMedia} bpm');
        LoggerService.debug('📱 Atualizando interface...');
        setState(() {
          _lastHeartrate = heartrateUpdate;
        });
        LoggerService.debug('📱 Interface atualizada com sucesso!');
        LoggerService.debug('💓 ======================================');
      }
    });

    _webSocketService.connect(widget.animalId);
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildLocationCard(),
          const SizedBox(height: 16),
          _buildHeartrateCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _isConnected ? Icons.wifi : Icons.wifi_off,
          color: _isConnected ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Dados em Tempo Real',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black400,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isConnected ? 'Conectado' : 'Desconectado',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sand100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _lastLocation?.isOutsideSafeZone == true 
              ? Colors.red.withOpacity(0.3) 
              : AppColors.sand300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.locationDot,
                color: _lastLocation?.isOutsideSafeZone == true 
                    ? Colors.red 
                    : AppColors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Localização',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_lastLocation != null) ...[
            _buildLocationInfo('Latitude', _lastLocation!.latitude.toStringAsFixed(6)),
            const SizedBox(height: 8),
            _buildLocationInfo('Longitude', _lastLocation!.longitude.toStringAsFixed(6)),
            const SizedBox(height: 8),
            _buildLocationInfo('Distância do Perímetro', '${_lastLocation!.distanciaDoPerimetro.toStringAsFixed(1)}m'),
            if (_lastLocation!.isOutsideSafeZone) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Fora da zona segura',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${_formatTimestamp(_lastLocation!.timestamp)}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.black200,
              ),
            ),
          ] else ...[
            Text(
              'Aguardando dados de localização...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.black200,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeartrateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sand100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sand300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.heartPulse,
                color: AppColors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Batimento Cardíaco',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_lastHeartrate != null) ...[
            Row(
              children: [
                Text(
                  '${_lastHeartrate!.frequenciaMedia}',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'bpm',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${_formatTimestamp(_lastHeartrate!.timestamp)}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.black200,
              ),
            ),
          ] else ...[
            Text(
              'Aguardando dados de batimento...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.black200,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.black200,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.black400,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      // Extract the local time from the timestamp string without timezone conversion
      // Format: "2025-10-17 20:00:00-03:00" or similar
      // We want to extract just the time part: "20:00:00"
      if (timestamp.contains(' ')) {
        final parts = timestamp.split(' ');
        if (parts.length >= 2) {
          final timePart = parts[1]; // "20:00:00-03:00" or "20:00:00"
          final cleanTime = timePart.split('-')[0].split('+')[0]; // Remove timezone offset
          return cleanTime; // "20:00:00"
        }
      }
      return timestamp;
    } catch (e) {
      return timestamp;
    }
  }
}
