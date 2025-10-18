import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Serviço de notificações locais para alertas de área segura
/// Gerencia permissões, configuração e envio de notificações
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _lastNotificationWasOutside = false; // Previne notificações duplicadas

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_isInitialized) return;

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
  }

  /// Cria o canal de notificação no Android
  /// SEM ISSO, AS NOTIFICAÇÕES NÃO APARECEM!
  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
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
      }
    }
  }

  /// Solicita permissões de notificação
  Future<void> _requestPermissions() async {
    // Android 13+ requer permissão explícita
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
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
    }
  }

  /// Callback quando a notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    // Aqui você pode navegar para uma tela específica se necessário
  }

  /// Envia notificação de alerta quando o pet sai da área segura
  /// Previne notificações duplicadas
  Future<void> sendSafeZoneAlert({
    required String petName,
    required bool isOutside,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Previne notificações duplicadas
    if (isOutside && _lastNotificationWasOutside) {
      return;
    }

    // Atualiza o estado
    _lastNotificationWasOutside = isOutside;

    // Só envia notificação quando sai da área
    if (!isOutside) {
      return;
    }

    // Configurações de notificação para Android
    final androidDetails = AndroidNotificationDetails(
      'safe_zone_alerts', // ID do canal
      'Alertas de Área Segura', // Nome do canal
      channelDescription: 'Notificações quando o pet sai da área segura',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]), // Padrão de vibração
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(
        'Seu pet está fora da área segura!',
        contentTitle: '⚠️ Atenção',
        summaryText: 'PetDex',
      ),
    );

    // Configurações de notificação para iOS
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    // Detalhes gerais da notificação
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Envia a notificação
    try {
      await _notifications.show(
        0, // ID da notificação (0 = sempre substitui a anterior)
        '⚠️ Atenção',
        'Seu pet está fora da área segura!',
        notificationDetails,
        payload: 'safe_zone_alert',
      );
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação: $e');
    }
  }

  /// Cancela todas as notificações
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Reseta o estado de notificações (útil para testes)
  void resetNotificationState() {
    _lastNotificationWasOutside = false;
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
}

