import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/websocket_message.dart';
import 'background_websocket_service.dart';
import 'notification_service.dart';
import 'package:PetDex/main.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  bool _isInBackground = false;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _connectionCheckTimer;
  String? _currentAnimalId;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseReconnectDelay = Duration(seconds: 2);
  DateTime? _lastSuccessfulConnection;
  DateTime? _lastMessageReceived;

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



  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  Future<void> connect(String animalId) async {
    if (_isConnected) {
      print('⚠️ Já conectado ao WebSocket, ignorando nova tentativa');
      return;
    }

    // Verifica se o token está disponível
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      print('❌ ERRO CRÍTICO: Token não disponível!');
      print('   Tentando fazer novo login...');
      try {
        await authService.relogin();
        final newToken = authService.getToken();
        if (newToken == null || newToken.isEmpty) {
          print('❌ Falha ao obter novo token após relogin');
          _scheduleReconnect();
          return;
        }
        print('✅ Novo token obtido com sucesso');
      } catch (e) {
        print('❌ Erro ao fazer relogin: $e');
        _scheduleReconnect();
        return;
      }
    }

    _currentAnimalId = animalId;
    _reconnectAttempts = 0;

    final baseUrl = '$_javaApiBaseUrl/ws-petdex';
    print('🔌 Iniciando conexão WebSocket');
    print('📍 Base URL: $baseUrl');
    print('🐾 Animal ID: $animalId');
    print('🔐 Token disponível: ${token!.substring(0, 20)}...');

    // Lista de endpoints para tentar
    final endpoints = [
      baseUrl,
    ];

    for (String endpoint in endpoints) {
      if (_isConnected) break;

      try {
        String wsUrl = endpoint.trim();
        print('🔗 URL original: $wsUrl');

        // Parse a URL original para extrair componentes
        final uri = Uri.parse(wsUrl);
        print('🔗 URI parseada - scheme: ${uri.scheme}, host: ${uri.host}, path: ${uri.path}');

        // Determina o scheme correto para WebSocket
        String wsScheme = 'ws';
        if (uri.scheme == 'https') {
          wsScheme = 'wss';
        }

        // Reconstrói a URL com o scheme correto
        final wsUri = Uri(
          scheme: wsScheme,
          host: uri.host,
          port: uri.port == 0 ? null : uri.port, // Ignora porta 0
          path: uri.path,
        );

        print('🔗 URL WebSocket: ${wsUri.toString()}');

        // Obtém o token JWT do serviço de autenticação
        final token = authService.getToken();

        if (token == null || token.isEmpty) {
          print('❌ ERRO: Token é null ou vazio!');
          print('   Tentando recuperar do armazenamento...');
          continue;
        }

        print('🔐 Token obtido: ${token.substring(0, 20)}...');

        // Adiciona o token como query parameter na URL do WebSocket
        final wsUrlWithAuth = wsUri.replace(
          queryParameters: {
            ...wsUri.queryParameters,
            'token': token,
          },
        );

        print('🔗 URL com autenticação: ${wsUrlWithAuth.toString().substring(0, 80)}...');

        print('🔌 Tentando conectar ao WebSocket...');
        _channel = WebSocketChannel.connect(
          wsUrlWithAuth,
          protocols: ['v12.stomp', 'v11.stomp', 'v10.stomp'],
        );

        // Aguardar um pouco para ver se a conexão é estabelecida
        await Future.delayed(const Duration(seconds: 2));

        _channel!.stream.listen(
          (message) {
            _handleMessage(message);
          },
          onError: (error) {
            print('❌ Erro no stream WebSocket: $error');
            if (!_isConnected) {
              _handleDisconnection();
            }
          },
          onDone: () {
            print('🔌 Stream WebSocket finalizado');
            _handleDisconnection();
          },
        );

        _isConnected = true;
        _reconnectAttempts = 0;
        _lastSuccessfulConnection = DateTime.now();
        _lastMessageReceived = DateTime.now();
        _connectionController.add(true);
        print('✅ Conectado ao WebSocket com sucesso!');

        _sendConnectCommand();
        _startHeartbeat();
        _startConnectionHealthCheck();

        Future.delayed(const Duration(seconds: 1), () {
          _subscribeToTopic(animalId);
        });

        break;

      } catch (e) {
        print('❌ Erro ao conectar: $e');
        print('   Stack trace: ${StackTrace.current}');
        continue;
      }
    }

    if (!_isConnected) {
      print('❌ Falha ao conectar em todos os endpoints');
      _scheduleReconnect();
    }
  }

  void _sendConnectCommand() {
    if (_channel != null) {
      // Obtém o token JWT do serviço de autenticação
      final token = authService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ ERRO: Token é null ou vazio ao enviar CONNECT!');
        return;
      }

      // Monta o comando CONNECT com o token JWT no header Authorization
      String connectCommand = 'CONNECT\n'
          'accept-version:1.0,1.1,1.2\n'
          'heart-beat:10000,10000\n';

      // Adiciona o header Authorization se houver token
      connectCommand += 'Authorization:Bearer $token\n';
      connectCommand += '\n\x00';

      try {
        _channel!.sink.add(connectCommand);
        print('🔐 CONNECT enviado com autenticação JWT');
        print('   Token: ${token.substring(0, 20)}...');
      } catch (e) {
        print('❌ Erro ao enviar CONNECT: $e');
        print('   Stack trace: ${StackTrace.current}');
        _handleDisconnection();
      }
    } else {
      print('❌ ERRO: _channel é null ao tentar enviar CONNECT!');
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
    // Atualiza timestamp da última mensagem recebida
    _lastMessageReceived = DateTime.now();

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
      print('✅ Conectado ao WebSocket');
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
    if (_isConnected) {
      _isConnected = false;
      _connectionController.add(false);
      print('🔌 Desconectado do WebSocket');
    }

    _channel = null;

    // Agenda reconexão automática se não estiver em background
    if (!_isInBackground && _currentAnimalId != null) {
      print('🔄 Agendando reconexão automática...');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ Máximo de tentativas de reconexão atingido ($_maxReconnectAttempts)');
      return;
    }

    final delay = Duration(
      seconds: (_baseReconnectDelay.inSeconds * (1 << _reconnectAttempts)).clamp(2, 300),
    );

    _reconnectAttempts++;
    print('🔄 Agendando reconexão #$_reconnectAttempts em ${delay.inSeconds}s');
    print('   Tentativas restantes: ${_maxReconnectAttempts - _reconnectAttempts}');

    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _currentAnimalId != null) {
        print('🔄 Tentando reconectar (tentativa $_reconnectAttempts/$_maxReconnectAttempts)...');
        connect(_currentAnimalId!);
      } else if (_isConnected) {
        print('✅ Já conectado, cancelando reconexão');
      } else {
        print('⚠️ Animal ID é null, não é possível reconectar');
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          // Envia heartbeat no formato STOMP
          _channel!.sink.add('\n');
          print('💓 Heartbeat enviado');
        } catch (e) {
          print('❌ Erro ao enviar heartbeat: $e');
          _handleDisconnection();
        }
      } else {
        // Se não está conectado, cancela o timer
        timer.cancel();
      }
    });
  }

  void _startConnectionHealthCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_isConnected && _lastMessageReceived != null) {
        final timeSinceLastMessage = DateTime.now().difference(_lastMessageReceived!);

        // Se não recebeu mensagens há mais de 2 minutos, considera a conexão morta
        if (timeSinceLastMessage.inSeconds > 120) {
          print('⚠️ Conexão inativa há ${timeSinceLastMessage.inSeconds}s - reconectando...');
          _handleDisconnection();
        }
      } else if (!_isConnected) {
        // Se não está conectado, cancela o timer
        timer.cancel();
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;

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

  /// Verifica se o pet saiu da área segura e envia notificação
  void _checkAndNotifySafeZone(LocationUpdate locationUpdate) {
    if (locationUpdate.isOutsideSafeZone) {
      _notificationService.sendSafeZoneAlert(
        petName: _currentPetName ?? 'Seu pet',
        isOutside: true,
      );
    } else {
      // Pet voltou para área segura - reseta o estado de notificação
      _notificationService.sendSafeZoneAlert(
        petName: _currentPetName ?? 'Seu pet',
        isOutside: false,
      );
    }
  }
}
