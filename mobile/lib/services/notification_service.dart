import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'logger_service.dart';

/// Serviço de notificações locais para alertas de área segura
/// Gerencia permissões, configuração e envio de notificações
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Rastreamento de estado da área segura
  bool? _lastKnownSafeZoneState; // null = desconhecido, true = fora, false = dentro
  DateTime? _lastNotificationTime; // Última vez que uma notificação foi enviada
  Timer? _repeatingNotificationTimer; // Timer para notificações repetidas

  static const Duration _notificationRepeatInterval = Duration(minutes: 5);

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_isInitialized) {
      LoggerService.info('✅ NotificationService já foi inicializado');
      return;
    }

    LoggerService.info('🔔 Inicializando NotificationService...');

    // Configurações para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configurações gerais
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializa o plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ✅ CRÍTICO: Cria o canal de notificação no Android
    await _createNotificationChannel();

    // Solicita permissões
    await _requestPermissions();

    _isInitialized = true;
    LoggerService.success('✅ NotificationService inicializado com sucesso');
  }

  /// Cria o canal de notificação no Android
  /// SEM ISSO, AS NOTIFICAÇÕES NÃO APARECEM!
  Future<void> _createNotificationChannel() async {
    LoggerService.info('📢 Criando canal de notificação...');

    if (defaultTargetPlatform == TargetPlatform.android) {
      LoggerService.info('🤖 Plataforma: Android - Criando canal de notificação');

      final androidChannel = AndroidNotificationChannel(
        'safe_zone_alerts', // ID do canal (deve ser o mesmo usado em sendSafeZoneAlert)
        'Alertas de Área Segura', // Nome do canal
        description: 'Notificações quando o pet sai da área segura',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
      );

      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(androidChannel);
        LoggerService.success('✅ Canal de notificação criado com sucesso');
      } else {
        LoggerService.error('❌ Não foi possível obter implementação Android para notificações');
      }
    } else {
      LoggerService.info('📱 Plataforma: iOS - Pulando criação de canal');
    }
  }

  /// Solicita permissões de notificação
  Future<void> _requestPermissions() async {
    LoggerService.info('🔐 Solicitando permissões de notificação...');

    // Android 13+ requer permissão explícita
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      LoggerService.info('🤖 Permissão de notificação Android: ${status.name}');
    }

    // iOS requer permissões específicas
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      LoggerService.info('📱 Permissões iOS solicitadas');
    }
  }

  /// Callback quando a notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    // Aqui você pode navegar para uma tela específica se necessário
  }

  /// Envia notificação de alerta quando o pet sai/retorna da área segura
  /// Implementa lógica de transição de estado e notificações repetidas
  Future<void> sendSafeZoneAlert({
    required String petName,
    required bool isOutside,
  }) async {
    LoggerService.debug('🔔 sendSafeZoneAlert chamado: petName=$petName, isOutside=$isOutside, _isInitialized=$_isInitialized');

    if (!_isInitialized) {
      LoggerService.warning('⚠️ NotificationService não inicializado, inicializando agora...');
      await initialize();
    }

    // Detecta transição de estado
    final hasStateChanged = _lastKnownSafeZoneState != isOutside;
    LoggerService.debug('🔄 Estado anterior: $_lastKnownSafeZoneState, Estado novo: $isOutside, Mudança detectada: $hasStateChanged');

    // Atualiza o estado conhecido
    _lastKnownSafeZoneState = isOutside;

    if (isOutside) {
      // Pet está FORA da área segura
      if (hasStateChanged) {
        // TRANSIÇÃO: Pet ACABOU DE SAIR da área segura
        LoggerService.warning('🚨 Pet saiu da área segura!');
        await _sendOutsideNotification(petName);
        _lastNotificationTime = DateTime.now();

        // Inicia timer para notificações repetidas a cada 5 minutos
        _startRepeatingNotificationTimer(petName);
      }
      // Se não houve mudança de estado, o timer já está ativo
    } else {
      // Pet está DENTRO da área segura
      if (hasStateChanged) {
        // TRANSIÇÃO: Pet RETORNOU à área segura
        LoggerService.success('✅ Pet retornou à área segura!');

        // Cancela timer de notificações repetidas
        _repeatingNotificationTimer?.cancel();
        _repeatingNotificationTimer = null;

        // Envia notificação de retorno
        await _sendReturnNotification(petName);
        _lastNotificationTime = DateTime.now();
      }
    }
  }

  /// Envia notificação quando o pet sai da área segura
  Future<void> _sendOutsideNotification(String petName) async {
    LoggerService.warning('📤 Enviando notificação de saída para $petName');

    final androidDetails = AndroidNotificationDetails(
      'safe_zone_alerts',
      'Alertas de Área Segura',
      channelDescription: 'Notificações quando o pet sai da área segura',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(
        'Seu pet está fora da área segura!',
        contentTitle: '⚠️ Atenção',
        summaryText: 'PetDex',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        1, // ID único para notificações de saída
        '⚠️ Atenção',
        '$petName está fora da área segura!',
        notificationDetails,
        payload: 'safe_zone_alert_outside',
      );
      LoggerService.success('✅ Notificação de saída enviada com sucesso');
    } catch (e) {
      LoggerService.error('❌ Erro ao enviar notificação de saída: $e', error: e);
    }
  }

  /// Envia notificação quando o pet retorna à área segura
  Future<void> _sendReturnNotification(String petName) async {
    LoggerService.success('📤 Enviando notificação de retorno para $petName');

    final androidDetails = AndroidNotificationDetails(
      'safe_zone_alerts',
      'Alertas de Área Segura',
      channelDescription: 'Notificações quando o pet retorna à área segura',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(
        'Seu pet retornou à área segura!',
        contentTitle: '✅ Seguro',
        summaryText: 'PetDex',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        2, // ID único para notificações de retorno
        '✅ Seguro',
        '$petName retornou à área segura!',
        notificationDetails,
        payload: 'safe_zone_alert_return',
      );
      LoggerService.success('✅ Notificação de retorno enviada com sucesso');
    } catch (e) {
      LoggerService.error('❌ Erro ao enviar notificação de retorno: $e', error: e);
    }
  }

  /// Inicia timer para enviar notificações repetidas a cada 5 minutos
  void _startRepeatingNotificationTimer(String petName) {
    // Cancela timer anterior se existir
    _repeatingNotificationTimer?.cancel();

    // Inicia novo timer
    _repeatingNotificationTimer = Timer.periodic(
      _notificationRepeatInterval,
      (timer) async {
        // Verifica se o pet ainda está fora (estado não mudou)
        if (_lastKnownSafeZoneState == true) {
          LoggerService.info('🔔 Reenviando notificação de área segura (5 minutos)');
          await _sendOutsideNotification(petName);
          _lastNotificationTime = DateTime.now();
        } else {
          // Pet retornou, cancela o timer
          timer.cancel();
          _repeatingNotificationTimer = null;
        }
      },
    );
  }

  /// Cancela todas as notificações
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Reseta o estado de notificações (útil para testes)
  void resetNotificationState() {
    _lastKnownSafeZoneState = null;
    _lastNotificationTime = null;
    _repeatingNotificationTimer?.cancel();
    _repeatingNotificationTimer = null;
  }

  /// Cancela o timer de notificações repetidas
  void cancelRepeatingNotifications() {
    _repeatingNotificationTimer?.cancel();
    _repeatingNotificationTimer = null;
  }

  /// Verifica se as permissões estão concedidas
  Future<bool> hasPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    // iOS sempre retorna true após solicitar permissões
    return true;
  }

  // Getters para testes
  bool? get lastKnownSafeZoneState => _lastKnownSafeZoneState;
  DateTime? get lastNotificationTime => _lastNotificationTime;
  Timer? get repeatingNotificationTimer => _repeatingNotificationTimer;
}

