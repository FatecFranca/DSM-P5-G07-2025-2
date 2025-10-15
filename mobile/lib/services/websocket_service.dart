import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/websocket_message.dart';
import 'background_websocket_service.dart';

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

  void setBackgroundMode(bool isBackground) {
    _isInBackground = isBackground;

    if (isBackground) {
      print('🔄 App entrou em background - iniciando serviço de background');
      if (_currentAnimalId != null) {
        BackgroundWebSocketService.startBackgroundService(_currentAnimalId!);
      }
    } else {
      print('🔄 App voltou para foreground - parando serviço de background');
      BackgroundWebSocketService.stopBackgroundService();
      if (!_isConnected && _currentAnimalId != null) {
        connect(_currentAnimalId!);
      }
    }
  }

  Future<void> initializeBackgroundService() async {
    await BackgroundWebSocketService.initialize();
  }



  Future<void> connect(String animalId) async {
    if (_isConnected) {
      return;
    }

    _currentAnimalId = animalId;
    _reconnectAttempts = 0;

    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Arquivo .env não encontrado, usando valores padrão');
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

        print('🔌 Tentando conectar: $wsUrl');

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
            print('❌ Erro WebSocket ($wsUrl): $error');
            if (!_isConnected) {
              _handleDisconnection();
            }
          },
          onDone: () {
            print('🔌 Conexão WebSocket finalizada ($wsUrl)');
            print('🔄 Tentando reconectar em 3 segundos...');
            _handleDisconnection();
          },
        );

        _isConnected = true;
        _reconnectAttempts = 0;
        _lastSuccessfulConnection = DateTime.now();
        _connectionController.add(true);
        print('✅ Conectado ao WebSocket: $wsUrl');

        _sendConnectCommand();
        _startHeartbeat();

        Future.delayed(const Duration(seconds: 1), () {
          _subscribeToTopic(animalId);
        });

        break;

      } catch (e) {
        print('❌ Falha ao conectar em $endpoint: $e');
        continue;
      }
    }

    if (!_isConnected) {
      print('❌ Não foi possível conectar a nenhum endpoint');
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
        print('🔗 Enviado comando CONNECT STOMP');
      } catch (e) {
        print('❌ Erro ao enviar CONNECT: $e');
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

      print('📡 Tentando inscrever no tópico: /topic/animal/$animalId');

      // Tentar formato STOMP primeiro
      try {
        _channel!.sink.add(stompSubscribe);
        print('📡 Enviado comando STOMP SUBSCRIBE');
      } catch (e) {
        print('❌ Erro ao enviar STOMP: $e');
      }

      // Aguardar um pouco e tentar JSON
      Future.delayed(const Duration(seconds: 1), () {
        if (_channel != null) {
          try {
            _channel!.sink.add(jsonSubscribe);
            print('📡 Enviado comando JSON SUBSCRIBE');
          } catch (e) {
            print('❌ Erro ao enviar JSON: $e');
          }
        }
      });

      // Aguardar mais um pouco e tentar formato direto
      Future.delayed(const Duration(seconds: 2), () {
        if (_channel != null) {
          try {
            _channel!.sink.add(directMessage);
            print('📡 Enviado comando direto');
          } catch (e) {
            print('❌ Erro ao enviar direto: $e');
          }
        }
      });
    }
  }

  void _handleMessage(dynamic message) {
    print('📨 Mensagem WebSocket recebida: $message');

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
          print('📋 Dados JSON decodificados: $data');

          final wsMessage = WebSocketMessage.fromJson(data);

          if (wsMessage is LocationUpdate) {
            _locationController.add(wsMessage);
            print('🎯 ===== LOCALIZAÇÃO RECEBIDA VIA JSON =====');
            print('📍 Animal ID: ${wsMessage.animalId}');
            print('📍 Coleira ID: ${wsMessage.coleiraId}');
            print('📍 Latitude: ${wsMessage.latitude}');
            print('📍 Longitude: ${wsMessage.longitude}');
            print('📍 Zona Segura: ${wsMessage.isOutsideSafeZone ? "FORA" : "DENTRO"}');
            print('📍 Distância do Perímetro: ${wsMessage.distanciaDoPerimetro}m');
            print('📍 Timestamp: ${wsMessage.timestamp}');
            print('🎯 =========================================');
          } else if (wsMessage is HeartrateUpdate) {
            _heartrateController.add(wsMessage);
            print('💓 ===== BATIMENTO RECEBIDO VIA JSON =====');
            print('💓 Animal ID: ${wsMessage.animalId}');
            print('💓 Coleira ID: ${wsMessage.coleiraId}');
            print('💓 Frequência Média: ${wsMessage.frequenciaMedia} bpm');
            print('💓 Timestamp: ${wsMessage.timestamp}');
            print('💓 ====================================');
          }
        } catch (e) {
          print('❌ Erro ao processar JSON: $e');
          print('Mensagem original: $message');
        }
      }
    } else {
      print('⚠️ Mensagem vazia ou inválida: $message (tipo: ${message.runtimeType})');
    }
  }

  void _handleStompMessage(String message) {
    print('📋 Processando mensagem STOMP: $message');

    final lines = message.split('\n');
    if (lines.isEmpty) return;

    final command = lines[0];
    print('🔧 Comando STOMP: $command');

    if (command == 'CONNECTED') {
      print('✅ Conexão STOMP estabelecida');
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
          print('📦 Corpo da mensagem: $body');

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

            print('📦 Corpo limpo: $cleanBody');

            final Map<String, dynamic> data = json.decode(cleanBody);
            final wsMessage = WebSocketMessage.fromJson(data);

            if (wsMessage is LocationUpdate) {
              _locationController.add(wsMessage);
              print('🎯 ===== LOCALIZAÇÃO RECEBIDA VIA STOMP =====');
              print('📍 Animal ID: ${wsMessage.animalId}');
              print('📍 Coleira ID: ${wsMessage.coleiraId}');
              print('📍 Latitude: ${wsMessage.latitude}');
              print('📍 Longitude: ${wsMessage.longitude}');
              print('📍 Zona Segura: ${wsMessage.isOutsideSafeZone ? "FORA" : "DENTRO"}');
              print('📍 Distância do Perímetro: ${wsMessage.distanciaDoPerimetro}m');
              print('📍 Timestamp: ${wsMessage.timestamp}');
              print('🎯 ==========================================');
            } else if (wsMessage is HeartrateUpdate) {
              _heartrateController.add(wsMessage);
              print('💓 ===== BATIMENTO RECEBIDO VIA STOMP =====');
              print('💓 Animal ID: ${wsMessage.animalId}');
              print('💓 Coleira ID: ${wsMessage.coleiraId}');
              print('💓 Frequência Média: ${wsMessage.frequenciaMedia} bpm');
              print('💓 Timestamp: ${wsMessage.timestamp}');
              print('💓 =====================================');
            }
          } catch (e) {
            print('❌ Erro ao processar corpo STOMP: $e');
            print('Corpo: $body');
          }
        }
      }
    } else if (command == 'ERROR') {
      print('❌ Erro STOMP recebido: $message');
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
      print('❌ Máximo de tentativas de reconexão atingido');
      return;
    }

    final delay = Duration(
      seconds: (_baseReconnectDelay.inSeconds * (1 << _reconnectAttempts)).clamp(2, 300),
    );

    print('🔄 Agendando reconexão em ${delay.inSeconds}s (tentativa ${_reconnectAttempts + 1}/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _currentAnimalId != null) {
        _reconnectAttempts++;
        print('🔄 Tentando reconectar... (tentativa $_reconnectAttempts/$_maxReconnectAttempts)');
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
          print('❌ Erro ao enviar heartbeat: $e');
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
      print('🔌 Desconectado do WebSocket');
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
}
