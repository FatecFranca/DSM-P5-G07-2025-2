import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
class BackgroundWebSocketService {
  static const String _taskName = 'websocket_background_task';
  static const String _notificationChannelId = 'petdex_websocket';
  static const String _notificationChannelName = 'PetDex WebSocket';

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ Background service já foi inicializado');
      return;
    }

    debugPrint('⚙️ Inicializando background service...');
    await _initializeBackgroundService();
    await _initializeWorkManager();

    _isInitialized = true;
    debugPrint('✅ Background service inicializado');
  }

  /// Reseta o estado de inicialização (útil para testes ou reinicializações)
  static void resetInitialization() {
    _isInitialized = false;
    debugPrint('🔄 Estado de inicialização resetado');
  }

  static Future<void> _initializeBackgroundService() async {
    try {
      final service = FlutterBackgroundService();

      // Verifica se o serviço já está configurado
      // Se já estiver rodando, não precisa configurar novamente
      if (await service.isRunning()) {
        debugPrint('⚠️ Background service já está rodando, pulando configuração');
        return;
      }

      // ✅ CRÍTICO: Cria o canal de notificação ANTES de configurar o serviço
      await _createNotificationChannel();

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
      debugPrint('✅ Background service configurado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao configurar background service: $e');
      // Não propaga o erro para evitar crash do app
    }
  }

  /// Cria o canal de notificação para o background service
  /// CRÍTICO: Deve ser chamado ANTES de iniciar o foreground service
  static Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      debugPrint('📢 Criando canal de notificação para background service...');

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _notificationChannelId, // ID do canal
        _notificationChannelName, // Nome do canal
        description: 'Mantém a conexão com o dispositivo do seu pet',
        importance: Importance.low, // Importância baixa para não incomodar
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
        debugPrint('✅ Canal de notificação criado: $_notificationChannelId');
      } else {
        debugPrint('⚠️ Não foi possível criar canal de notificação');
      }
    } catch (e) {
      debugPrint('❌ Erro ao criar canal de notificação: $e');
      // Não propaga o erro, mas isso pode causar problemas no foreground service
    }
  }

  static Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> startBackgroundService(String animalId) async {
    try {
      debugPrint('🚀 Iniciando background service para animal: $animalId');

      if (!_isInitialized) {
        debugPrint('⚙️ Inicializando background service...');
        await initialize();
      }

      final service = FlutterBackgroundService();

      // Verifica se o serviço já está rodando
      final isRunning = await service.isRunning();
      debugPrint('📊 Background service status: ${isRunning ? "rodando" : "parado"}');

      if (isRunning) {
        debugPrint('✅ Serviço já está rodando, apenas atualizando animalId');
        service.invoke('setAnimalId', {'animalId': animalId});
        return;
      }

      debugPrint('▶️ Iniciando novo serviço de background');
      await service.startService();

      // Aguarda um pouco para garantir que o serviço iniciou
      await Future.delayed(const Duration(milliseconds: 500));

      service.invoke('setAnimalId', {'animalId': animalId});

      // Registra tarefa periódica do WorkManager
      debugPrint('📅 Registrando tarefa periódica do WorkManager');
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 15),
        inputData: {'animalId': animalId},
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      debugPrint('✅ Background service iniciado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao iniciar background service: $e');
      // Não propaga o erro para evitar crash do app
    }
  }

  static Future<void> stopBackgroundService() async {
    try {
      debugPrint('🛑 Parando background service');

      final service = FlutterBackgroundService();

      // Verifica se o serviço está rodando antes de tentar parar
      if (await service.isRunning()) {
        service.invoke('stop');
        debugPrint('✅ Comando de parada enviado ao background service');
      } else {
        debugPrint('⚠️ Background service já está parado');
      }

      // Cancela tarefas do WorkManager
      await Workmanager().cancelByUniqueName(_taskName);
      debugPrint('✅ Tarefas do WorkManager canceladas');
    } catch (e) {
      debugPrint('❌ Erro ao parar background service: $e');
      // Não propaga o erro para evitar crash do app
    }
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
      
      final baseUrl = '${dotenv.env['API_JAVA_URL']!}/ws-petdex';
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
        debugPrint('🔄 WorkManager task executado: $task');
        // ⚠️ IMPORTANTE: Não usar FlutterBackgroundService aqui
        // Este callback roda em um isolate separado do WorkManager
        // FlutterBackgroundService só deve ser usado no isolate principal (UI)

        // Por enquanto, apenas retorna sucesso
        // O serviço de background é gerenciado pelo lifecycle do app
        return Future.value(true);
      } catch (e) {
        debugPrint('❌ Erro no WorkManager: $e');
        return Future.value(false);
      }
    });
  }
}
