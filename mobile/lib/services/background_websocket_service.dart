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
      return;
    }

    await _initializeBackgroundService();
    await _initializeWorkManager();

    _isInitialized = true;
  }

  /// Reseta o estado de inicialização (útil para testes ou reinicializações)
  static void resetInitialization() {
    _isInitialized = false;
  }

  static Future<void> _initializeBackgroundService() async {
    try {
      final service = FlutterBackgroundService();

      // Verifica se o serviço já está configurado
      // Se já estiver rodando, não precisa configurar novamente
      if (await service.isRunning()) {
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
    } catch (e) {
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
      }
    } catch (e) {
      // Não propaga o erro, mas isso pode causar problemas no foreground service
    }
  }

  static Future<void> _initializeWorkManager() async {
    await Workmanager().initialize(_callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> startBackgroundService(String animalId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final service = FlutterBackgroundService();

      // Verifica se o serviço já está rodando
      final isRunning = await service.isRunning();

      if (isRunning) {
        service.invoke('setAnimalId', {'animalId': animalId});
        return;
      }

      await service.startService();

      // Aguarda um pouco para garantir que o serviço iniciou
      await Future.delayed(const Duration(milliseconds: 500));

      service.invoke('setAnimalId', {'animalId': animalId});

      // Registra tarefa periódica do WorkManager
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 15),
        inputData: {'animalId': animalId},
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      // Não propaga o erro para evitar crash do app
    }
  }

  static Future<void> stopBackgroundService() async {
    try {
      final service = FlutterBackgroundService();

      // Verifica se o serviço está rodando antes de tentar parar
      if (await service.isRunning()) {
        service.invoke('stop');
      }

      // Cancela tarefas do WorkManager
      await Workmanager().cancelByUniqueName(_taskName);
    } catch (e) {
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

      // Lista de endpoints para tentar
      final endpoints = [
        '$baseUrl/websocket',
        baseUrl,
        '$baseUrl/ws',
        '$baseUrl/sockjs/websocket',
      ];

      for (String endpoint in endpoints) {
        try {
          String wsUrl = endpoint.trim();
          if (wsUrl.startsWith('https://')) {
            wsUrl = wsUrl.replaceFirst('https://', 'wss://');
          } else if (wsUrl.startsWith('http://')) {
            wsUrl = wsUrl.replaceFirst('http://', 'ws://');
          }

          final channel = WebSocketChannel.connect(
            Uri.parse(wsUrl),
            protocols: ['v12.stomp', 'v11.stomp', 'v10.stomp'],
          );

          // Aguardar um pouco para ver se a conexão é estabelecida
          await Future.delayed(const Duration(seconds: 2));

          channel.stream.listen(
            (message) {
              _handleBackgroundMessage(message, animalId, service);
            },
            onError: (error) {
              // Silencioso
            },
            onDone: () {
              // WebSocket disconnected
            },
          );

          // Enviar comando STOMP CONNECT
          final connectCommand = 'CONNECT\n'
              'accept-version:1.0,1.1,1.2\n'
              'heart-beat:10000,10000\n'
              '\n\x00';

          try {
            channel.sink.add(connectCommand);
          } catch (e) {
            // Silencioso
          }

          // Aguardar um pouco e depois se inscrever
          await Future.delayed(const Duration(seconds: 1));
          _subscribeToTopicBackground(channel, animalId);

          // Iniciar heartbeat
          Timer.periodic(const Duration(seconds: 30), (timer) {
            if (channel.closeCode == null) {
              try {
                channel.sink.add('PING');
              } catch (e) {
                timer.cancel();
              }
            } else {
              timer.cancel();
            }
          });

          return channel;
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static void _subscribeToTopicBackground(WebSocketChannel channel, String animalId) {
    try {
      // Formato 1: STOMP SUBSCRIBE
      final stompSubscribe = 'SUBSCRIBE\n'
          'id:sub-0\n'
          'destination:/topic/animal/$animalId\n'
          '\n\x00';

      // Formato 2: JSON simples
      final jsonSubscribe = json.encode({
        'command': 'SUBSCRIBE',
        'id': 'sub-0',
        'destination': '/topic/animal/$animalId',
      });

      // Formato 3: Mensagem direta
      final directMessage = json.encode({
        'id': 'sub-0',
        'destination': '/topic/animal/$animalId',
      });

      // Tentar formato STOMP primeiro
      try {
        channel.sink.add(stompSubscribe);
      } catch (e) {
        // Silencioso
      }

      // Aguardar um pouco e tentar JSON
      Future.delayed(const Duration(seconds: 1), () {
        try {
          channel.sink.add(jsonSubscribe);
        } catch (e) {
          // Silencioso
        }
      });

      // Aguardar mais um pouco e tentar formato direto
      Future.delayed(const Duration(seconds: 2), () {
        try {
          channel.sink.add(directMessage);
        } catch (e) {
          // Silencioso
        }
      });
    } catch (e) {
      // Silencioso
    }
  }

  static void _handleBackgroundMessage(dynamic message, String animalId, ServiceInstance service) {
    if (message is String && message.trim().isNotEmpty) {
      // Verificar se é uma mensagem STOMP
      if (message.startsWith('CONNECTED') ||
          message.startsWith('MESSAGE') ||
          message.startsWith('ERROR') ||
          message.startsWith('RECEIPT')) {
        _handleStompMessageBackground(message);
      } else {
        // Tentar processar como JSON
        try {
          final Map<String, dynamic> data = json.decode(message);
          _checkAndNotifySafeZone(data);
        } catch (e) {
          // Silencioso
        }
      }
    }
  }

  static void _handleStompMessageBackground(String message) {
    final lines = message.split('\n');
    if (lines.isEmpty) return;

    final command = lines[0];

    if (command == 'CONNECTED') {
      // Silencioso
    } else if (command == 'MESSAGE') {
      // Extrair o corpo da mensagem (após linha vazia)
      int bodyStartIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) {
          bodyStartIndex = i + 1;
          break;
        }
      }

      if (bodyStartIndex > 0 && bodyStartIndex < lines.length) {
        final body = lines.sublist(bodyStartIndex).join('\n').trim();
        if (body.isNotEmpty && body != '\x00') {
          try {
            // Limpar caracteres especiais e null bytes
            String cleanBody = body.replaceAll('\x00', '').replaceAll('\n', '').trim();

            // Verificar se termina com }
            if (!cleanBody.endsWith('}')) {
              int lastBrace = cleanBody.lastIndexOf('}');
              if (lastBrace > 0) {
                cleanBody = cleanBody.substring(0, lastBrace + 1);
              }
            }

            final Map<String, dynamic> data = json.decode(cleanBody);
            _checkAndNotifySafeZone(data);
          } catch (e) {
            // Silencioso
          }
        }
      }
    }
  }

  /// Verifica se o pet saiu da área segura e envia notificação via NotificationService
  static Future<void> _checkAndNotifySafeZone(Map<String, dynamic> data) async {
    try {
      // Verifica se a mensagem contém informações de área segura
      final isOutsideSafeZone = data['isOutsideSafeZone'] as bool? ?? false;

      if (isOutsideSafeZone) {
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
      // Silencioso
    }
  }

  @pragma('vm:entry-point')
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        // ⚠️ IMPORTANTE: Não usar FlutterBackgroundService aqui
        // Este callback roda em um isolate separado do WorkManager
        // FlutterBackgroundService só deve ser usado no isolate principal (UI)

        // Por enquanto, apenas retorna sucesso
        // O serviço de background é gerenciado pelo lifecycle do app
        return Future.value(true);
      } catch (e) {
        return Future.value(false);
      }
    });
  }
}
