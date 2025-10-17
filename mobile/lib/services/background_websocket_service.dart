import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notification_service.dart';

class BackgroundWebSocketService {
  static const String _taskName = 'websocket_background_task';
  static const String _notificationChannelId = 'petdex_websocket';
  static const String _notificationChannelName = 'PetDex WebSocket';

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeBackgroundService();
    await _initializeWorkManager();

    _isInitialized = true;
  }

  static Future<void> _initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onBackgroundStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onBackgroundStart,
        autoStart: false,
        isForegroundMode: true, // ✅ HABILITADO - Mantém notificação persistente
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'PetDex - Conectado',
        initialNotificationContent: 'Mantendo conexão com seu pet',
        foregroundServiceNotificationId: 888,
      ),
    );
  }

  static Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> startBackgroundService(String animalId) async {
    if (!_isInitialized) {
      await initialize();
    }

    final service = FlutterBackgroundService();
    
    if (await service.isRunning()) {
      service.invoke('setAnimalId', {'animalId': animalId});
      return;
    }

    await service.startService();
    service.invoke('setAnimalId', {'animalId': animalId});

    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      inputData: {'animalId': animalId},
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> stopBackgroundService() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
    
    await Workmanager().cancelByUniqueName(_taskName);
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void _onBackgroundStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    String? animalId;
    Timer? reconnectTimer;
    WebSocketChannel? channel;
    bool isConnected = false;
    int reconnectAttempts = 0;
    final maxReconnectAttempts = 10;

    service.on('setAnimalId').listen((data) {
      animalId = data?['animalId'];
      if (animalId != null && !isConnected) {
        _connectWebSocket(animalId!, service).then((conn) {
          channel = conn;
          isConnected = conn != null;
        });
      }
    });

    service.on('stop').listen((event) {
      reconnectTimer?.cancel();
      channel?.sink.close();
      service.stopSelf();
    });

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!isConnected && animalId != null && reconnectAttempts < maxReconnectAttempts) {
        reconnectAttempts++;
        
        final conn = await _connectWebSocket(animalId!, service);
        if (conn != null) {
          channel = conn;
          isConnected = true;
          reconnectAttempts = 0;
        }
      }

      service.invoke('update', {
        'current_date': DateTime.now().toIso8601String(),
        'connected': isConnected,
        'attempts': reconnectAttempts,
      });
    });
  }

  static Future<WebSocketChannel?> _connectWebSocket(String animalId, ServiceInstance service) async {
    try {
      await dotenv.load(fileName: ".env");
      
      final baseUrl = '${dotenv.env['API_JAVA_URL']!}/ws-petdx';
      var wsUrl = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      
      final channel = WebSocketChannel.connect(Uri.parse('$wsUrl/websocket'));
      
      await channel.ready;
      
      channel.sink.add('CONNECT\naccept-version:1.2,1.1,1.0\nheart-beat:30000,30000\n\n\x00');
      
      channel.stream.listen(
        (message) {
          _handleBackgroundMessage(message, animalId, service);
        },
        onError: (error) {
          print('Erro WebSocket Background: $error');
        },
        onDone: () {
          print('Conexão WebSocket Background finalizada');
        },
      );

      Timer.periodic(const Duration(seconds: 30), (timer) {
        if (channel.closeCode == null) {
          channel.sink.add('\n');
        } else {
          timer.cancel();
        }
      });

      return channel;
    } catch (e) {
      print('Erro ao conectar WebSocket Background: $e');
      return null;
    }
  }

  static void _handleBackgroundMessage(dynamic message, String animalId, ServiceInstance service) {
    try {
      final messageStr = message.toString();

      if (messageStr.startsWith('CONNECTED')) {
        final subscribeMessage = 'SUBSCRIBE\nid:sub-$animalId\ndestination:/topic/animal/$animalId\n\n\x00';
        service.invoke('websocket_send', {'message': subscribeMessage});
        return;
      }

      if (messageStr.startsWith('MESSAGE')) {
        final lines = messageStr.split('\n');
        final bodyIndex = lines.indexWhere((line) => line.isEmpty);

        if (bodyIndex != -1 && bodyIndex + 1 < lines.length) {
          final jsonBody = lines.sublist(bodyIndex + 1).join('\n').replaceAll('\x00', '');

          if (jsonBody.isNotEmpty) {
            final data = json.decode(jsonBody);
            _checkAndNotifySafeZone(data);
          }
        }
      }
    } catch (e) {
      print('Erro ao processar mensagem background: $e');
    }
  }

  /// Verifica se o pet saiu da área segura e envia notificação via NotificationService
  static Future<void> _checkAndNotifySafeZone(Map<String, dynamic> data) async {
    try {
      // Verifica se a mensagem contém informações de área segura
      final isOutsideSafeZone = data['isOutsideSafeZone'] as bool? ?? false;

      if (isOutsideSafeZone) {
        debugPrint('🚨 [Background] Pet fora da área segura! Enviando notificação...');

        // Usa o NotificationService para enviar a notificação de alerta
        final notificationService = NotificationService();
        await notificationService.sendSafeZoneAlert(
          petName: 'Seu pet',
          isOutside: true,
        );
      } else {
        // Pet voltou para área segura - reseta o estado
        final notificationService = NotificationService();
        await notificationService.sendSafeZoneAlert(
          petName: 'Seu pet',
          isOutside: false,
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar área segura em background: $e');
    }
  }

  @pragma('vm:entry-point')
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        final animalId = inputData?['animalId'] as String?;
        if (animalId != null) {
          final service = FlutterBackgroundService();
          if (!(await service.isRunning())) {
            await startBackgroundService(animalId);
          }
        }
        return Future.value(true);
      } catch (e) {
        print('Erro no WorkManager: $e');
        return Future.value(false);
      }
    });
  }
}
