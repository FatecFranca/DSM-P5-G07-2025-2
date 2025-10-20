import 'package:flutter_test/flutter_test.dart';
import 'package:PetDex/services/notification_service.dart';

void main() {
  group('NotificationService - Safe Zone Alerts', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
      notificationService.resetNotificationState();
    });

    tearDown(() {
      notificationService.cancelRepeatingNotifications();
      notificationService.resetNotificationState();
    });

    test('Detecta transição: dentro → fora (primeira saída)', () async {
      // Estado inicial: null (desconhecido)
      expect(notificationService.lastKnownSafeZoneState, isNull);

      // Pet sai da área
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );

      // Deve detectar transição e atualizar estado
      expect(notificationService.lastKnownSafeZoneState, isTrue);
    });

    test('Detecta transição: fora → dentro (retorno)', () async {
      // Primeiro, pet sai
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );
      expect(notificationService.lastKnownSafeZoneState, isTrue);

      // Depois, pet retorna
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: false,
      );

      // Deve detectar transição e atualizar estado
      expect(notificationService.lastKnownSafeZoneState, isFalse);
    });

    test('Não envia notificação duplicada se estado não muda', () async {
      // Pet sai
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );
      final firstNotificationTime = notificationService.lastNotificationTime;

      // Aguarda um pouco
      await Future.delayed(const Duration(milliseconds: 100));

      // Pet continua fora (sem mudança de estado)
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );
      final secondNotificationTime = notificationService.lastNotificationTime;

      // Tempo de notificação não deve mudar (não foi reenviada)
      expect(firstNotificationTime, equals(secondNotificationTime));
    });

    test('Timer de repetição é iniciado quando pet sai', () async {
      // Pet sai
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );

      // Timer deve estar ativo
      expect(notificationService.repeatingNotificationTimer, isNotNull);
    });

    test('Timer de repetição é cancelado quando pet retorna', () async {
      // Pet sai
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );
      expect(notificationService.repeatingNotificationTimer, isNotNull);

      // Pet retorna
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: false,
      );

      // Timer deve estar cancelado
      expect(notificationService.repeatingNotificationTimer, isNull);
    });

    test('resetNotificationState limpa todo o estado', () async {
      // Pet sai
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );

      // Reseta estado
      notificationService.resetNotificationState();

      // Tudo deve estar limpo
      expect(notificationService.lastKnownSafeZoneState, isNull);
      expect(notificationService.lastNotificationTime, isNull);
      expect(notificationService.repeatingNotificationTimer, isNull);
    });

    test('Múltiplas transições funcionam corretamente', () async {
      // Ciclo 1: Sai
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );
      expect(notificationService.lastKnownSafeZoneState, isTrue);

      // Ciclo 1: Retorna
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: false,
      );
      expect(notificationService.lastKnownSafeZoneState, isFalse);

      // Ciclo 2: Sai novamente
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: true,
      );
      expect(notificationService.lastKnownSafeZoneState, isTrue);

      // Ciclo 2: Retorna novamente
      await notificationService.sendSafeZoneAlert(
        petName: 'Fluffy',
        isOutside: false,
      );
      expect(notificationService.lastKnownSafeZoneState, isFalse);
    });
  });
}

