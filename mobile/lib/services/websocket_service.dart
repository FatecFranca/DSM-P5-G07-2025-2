import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/websocket_message.dart';
import 'background_websocket_service.dart';
import 'notification_service.dart';
import 'logger_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  bool _isInBackground = false;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  String? _currentAnimalId;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseReconnectDelay = Duration(seconds: 2);
  DateTime? _lastSuccessfulConnection;

  final StreamController<LocationUpdate> _locationController = StreamController<LocationUpdate>.broadcast();
  final StreamController<HeartrateUpdate> _heartrateController = StreamController<HeartrateUpdate>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<LocationUpdate> get locationStream => _locationController.stream;
  Stream<HeartrateUpdate> get heartrateStream => _heartrateController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;
  bool get isInBackground => _isInBackground;

  // Serviço de notificações
  final NotificationService _notificationService = NotificationService();
  String? _currentPetName; // Nome do pet para notificações

  void setBackgroundMode(bool isBackground) {
    _isInBackground = isBackground;

    if (isBackground) {
      if (_currentAnimalId != null) {
        BackgroundWebSocketService.startBackgroundService(_currentAnimalId!);
      }
    } else {
      BackgroundWebSocketService.stopBackgroundService();
      if (!_isConnected && _currentAnimalId != null) {
        connect(_currentAnimalId!);
      }
    }
  }

  Future<void> initializeBackgroundService() async {
    try {
      await BackgroundWebSocketService.initialize();
    } catch (e) {
      // Não propaga o erro para evitar crash do app
    }
  }

  /// Inicializa o serviço de notificações
  Future<void> initializeNotifications({String? petName}) async {
    _currentPetName = petName;
    await _notificationService.initialize();
  }

  /// Define o nome do pet para notificações
  void setPetName(String petName) {
    _currentPetName = petName;
  }

  Future<void> connect(String animalId) async {
    // Se já está conectado ao MESMO animal, não reconecta
    if (_isConnected && _currentAnimalId == animalId) {
      LoggerService.websocket('✅ Já conectado ao animal: $animalId');
      return;
    }

    // Se está conectado a um animal DIFERENTE, desconecta primeiro
    if (_isConnected && _currentAnimalId != animalId) {
      LoggerService.websocket('🔄 Mudança de animal detectada. Desconectando de $_currentAnimalId e conectando a $animalId');
      disconnect();
    }

    _currentAnimalId = animalId;
    _reconnectAttempts = 0;

    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Silencioso
    }

    final baseUrl = '${dotenv.env['API_JAVA_URL']!}/ws-petdex';

    // Lista de endpoints para tentar
    final endpoints = [
      '$baseUrl/websocket',
      baseUrl,
      '$baseUrl/ws',
      '$baseUrl/sockjs/websocket',
    ];

    for (String endpoint in endpoints) {
      if (_isConnected) break;

      try {
        String wsUrl = endpoint.trim();
        if (wsUrl.startsWith('https://')) {
          wsUrl = wsUrl.replaceFirst('https://', 'wss://');
        } else if (wsUrl.startsWith('http://')) {
          wsUrl = wsUrl.replaceFirst('http://', 'ws://');
        }

        LoggerService.websocket('🔌 Tentando conectar ao WebSocket...');
        LoggerService.websocket('🔗 URL: $wsUrl');

        _channel = WebSocketChannel.connect(
          Uri.parse(wsUrl),
          protocols: ['v12.stomp', 'v11.stomp', 'v10.stomp'],
        );

        // Aguardar um pouco para ver se a conexão é estabelecida
        await Future.delayed(const Duration(seconds: 2));

        _channel!.stream.listen(
          (message) {
            _handleMessage(message);
          },
          onError: (error) {
            LoggerService.connectionError('❌ Erro na conexão WebSocket', error: error);
            if (!_isConnected) {
              _handleDisconnection();
            }
          },
          onDone: () {
            LoggerService.websocket('🔌 Desconectado do WebSocket');
            _handleDisconnection();
          },
        );

        _isConnected = true;
        _reconnectAttempts = 0;
        _lastSuccessfulConnection = DateTime.now();
        _connectionController.add(true);
        LoggerService.success('✅ Conectado ao WebSocket');

        _sendConnectCommand();
        _startHeartbeat();

        Future.delayed(const Duration(seconds: 1), () {
          _subscribeToTopic(animalId);
        });

        break;

      } catch (e) {
        LoggerService.warning('⚠️ Falha ao conectar em $endpoint: $e');
        continue;
      }
    }

    if (!_isConnected) {
      LoggerService.warning('⚠️ Nenhum endpoint disponível. Agendando reconexão...');
      _scheduleReconnect();
    }
  }

  void _sendConnectCommand() {
    if (_channel != null) {
      final connectCommand = 'CONNECT\n'
          'accept-version:1.0,1.1,1.2\n'
          'heart-beat:10000,10000\n'
          '\n\x00';

      try {
        _channel!.sink.add(connectCommand);
      } catch (e) {
        // Silencioso
      }
    }
  }

  void _subscribeToTopic(String animalId) {
    if (_channel != null) {
      // Tentar diferentes formatos de inscrição

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
        _channel!.sink.add(stompSubscribe);
      } catch (e) {
        // Silencioso
      }

      // Aguardar um pouco e tentar JSON
      Future.delayed(const Duration(seconds: 1), () {
        if (_channel != null) {
          try {
            _channel!.sink.add(jsonSubscribe);
          } catch (e) {
            // Silencioso
          }
        }
      });

      // Aguardar mais um pouco e tentar formato direto
      Future.delayed(const Duration(seconds: 2), () {
        if (_channel != null) {
          try {
            _channel!.sink.add(directMessage);
          } catch (e) {
            // Silencioso
          }
        }
      });
    }
  }



  void _handleMessage(dynamic message) {
    if (message is String && message.trim().isNotEmpty) {
      // Verificar se é uma mensagem STOMP
      if (message.startsWith('CONNECTED') ||
          message.startsWith('MESSAGE') ||
          message.startsWith('ERROR') ||
          message.startsWith('RECEIPT')) {
        _handleStompMessage(message);
      } else {
        // Tentar processar como JSON
        try {
          final Map<String, dynamic> data = json.decode(message);
          final wsMessage = WebSocketMessage.fromJson(data);

          if (wsMessage is LocationUpdate) {
            _locationController.add(wsMessage);
            // Envia notificação se o pet saiu da área segura
            _checkAndNotifySafeZone(wsMessage);
          } else if (wsMessage is HeartrateUpdate) {
            _heartrateController.add(wsMessage);
          }
        } catch (e) {
          // Silencioso
        }
      }
    }
  }

  void _handleStompMessage(String message) {
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
            final wsMessage = WebSocketMessage.fromJson(data);

            if (wsMessage is LocationUpdate) {
              _locationController.add(wsMessage);
              // Envia notificação se o pet saiu da área segura
              _checkAndNotifySafeZone(wsMessage);
            } else if (wsMessage is HeartrateUpdate) {
              _heartrateController.add(wsMessage);
            }
          } catch (e) {
            // Silencioso
          }
        }
      }
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _connectionController.add(false);
    _channel = null;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      LoggerService.error('❌ Máximo de tentativas de reconexão atingido ($_maxReconnectAttempts)');
      return;
    }

    final delay = Duration(
      seconds: (_baseReconnectDelay.inSeconds * (1 << _reconnectAttempts)).clamp(2, 300),
    );

    LoggerService.connection('🔄 Reconexão agendada em ${delay.inSeconds}s (tentativa ${_reconnectAttempts + 1}/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _currentAnimalId != null) {
        _reconnectAttempts++;
        LoggerService.connection('🔄 Tentando reconectar... (tentativa $_reconnectAttempts/$_maxReconnectAttempts)');
        connect(_currentAnimalId!);
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('PING');
        } catch (e) {
          _handleDisconnection();
        }
      }
    });
  }



  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }

    if (_isConnected) {
      _isConnected = false;
      _connectionController.add(false);
    }

    _currentAnimalId = null;
    _reconnectAttempts = 0;
  }

  void dispose() {
    disconnect();
    _locationController.close();
    _heartrateController.close();
    _connectionController.close();
  }

  void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
  }

  /// Verifica se o pet saiu/retornou da área segura e envia notificação apropriada
  /// Implementa lógica de transição de estado
  void _checkAndNotifySafeZone(LocationUpdate locationUpdate) {
    // Envia para o serviço de notificações que detectará transições
    _notificationService.sendSafeZoneAlert(
      petName: _currentPetName ?? 'Seu pet',
      isOutside: locationUpdate.isOutsideSafeZone,
    );
  }
}
