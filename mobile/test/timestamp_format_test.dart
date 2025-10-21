import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Timestamp Formatting - HeartLineChart', () {
    test('Should extract local date and time from timestamp with timezone offset', () {
      // Arrange
      final dateString = '2025-10-17 20:00:00-03:00';
      
      // Act
      final datePart = dateString.substring(0, 10); // "2025-10-17"
      final timePart = dateString.substring(11, 16); // "20:00"
      final parts = datePart.split('-');
      final formattedDate = '${parts[2]}/${parts[1]}'; // "17/10"
      final formatted = '$formattedDate\n$timePart'; // "17/10\n20:00"
      
      // Assert
      expect(formatted, equals('17/10\n20:00'));
      expect(formatted, isNot(contains('23:00'))); // Should NOT be converted to UTC
    });

    test('Should extract correct date and time from various timestamps', () {
      // Arrange
      final timestamps = [
        '2025-10-17 20:00:00-03:00',
        '2025-10-18 13:00:00-03:00',
        '2025-10-18 19:00:00-03:00',
        '2025-10-20 10:00:00-03:00',
        '2025-10-20 20:00:00-03:00',
      ];
      
      final expectedFormats = [
        '17/10\n20:00',
        '18/10\n13:00',
        '18/10\n19:00',
        '20/10\n10:00',
        '20/10\n20:00',
      ];
      
      // Act & Assert
      for (int i = 0; i < timestamps.length; i++) {
        final datePart = timestamps[i].substring(0, 10);
        final timePart = timestamps[i].substring(11, 16);
        final parts = datePart.split('-');
        final formattedDate = '${parts[2]}/${parts[1]}';
        final formatted = '$formattedDate\n$timePart';
        expect(formatted, equals(expectedFormats[i]));
      }
    });

    test('Should preserve original time without timezone conversion', () {
      // Arrange
      final dateString = '2025-10-17 20:00:00-03:00';
      
      // Act
      final timePart = dateString.substring(11, 16);
      
      // Assert - The time should be 20:00, not 23:00 (UTC)
      expect(timePart, equals('20:00'));
      expect(timePart, isNot(contains('23:00')));
    });
  });

  group('Timestamp Formatting - HeartChartBar', () {
    test('Should extract local date from timestamp with timezone offset', () {
      // Arrange
      final dateString = '2025-10-17 20:00:00-03:00';
      
      // Act
      final localDatePart = dateString.substring(0, 10); // "2025-10-17"
      final parts = localDatePart.split('-');
      final formattedDate = '${parts[2]}/${parts[1]}'; // "17/10"
      
      // Assert
      expect(formattedDate, equals('17/10'));
    });

    test('Should format dates correctly from various timestamps', () {
      // Arrange
      final timestamps = [
        '2025-10-17 20:00:00-03:00',
        '2025-10-18 13:00:00-03:00',
        '2025-10-20 10:00:00-03:00',
      ];
      
      final expectedDates = [
        '17/10',
        '18/10',
        '20/10',
      ];
      
      // Act & Assert
      for (int i = 0; i < timestamps.length; i++) {
        final localDatePart = timestamps[i].substring(0, 10);
        final parts = localDatePart.split('-');
        final formattedDate = '${parts[2]}/${parts[1]}';
        expect(formattedDate, equals(expectedDates[i]));
      }
    });
  });

  group('Timestamp Formatting - RealtimeDataWidget', () {
    test('Should extract time from timestamp with timezone offset', () {
      // Arrange
      final timestamp = '2025-10-17 20:00:00-03:00';
      
      // Act
      String formattedTime = timestamp;
      if (timestamp.contains(' ')) {
        final parts = timestamp.split(' ');
        if (parts.length >= 2) {
          final timePart = parts[1]; // "20:00:00-03:00"
          final cleanTime = timePart.split('-')[0].split('+')[0]; // "20:00:00"
          formattedTime = cleanTime;
        }
      }
      
      // Assert
      expect(formattedTime, equals('20:00:00'));
      expect(formattedTime, isNot(contains('-03:00')));
    });

    test('Should handle timestamps with positive timezone offset', () {
      // Arrange
      final timestamp = '2025-10-17 20:00:00+05:30';
      
      // Act
      String formattedTime = timestamp;
      if (timestamp.contains(' ')) {
        final parts = timestamp.split(' ');
        if (parts.length >= 2) {
          final timePart = parts[1];
          final cleanTime = timePart.split('-')[0].split('+')[0];
          formattedTime = cleanTime;
        }
      }
      
      // Assert
      expect(formattedTime, equals('20:00:00'));
      expect(formattedTime, isNot(contains('+05:30')));
    });

    test('Should handle various timestamp formats', () {
      // Arrange
      final timestamps = [
        '2025-10-17 20:00:00-03:00',
        '2025-10-18 13:00:00-03:00',
        '2025-10-20 10:00:00-03:00',
      ];
      
      final expectedTimes = [
        '20:00:00',
        '13:00:00',
        '10:00:00',
      ];
      
      // Act & Assert
      for (int i = 0; i < timestamps.length; i++) {
        String formattedTime = timestamps[i];
        if (timestamps[i].contains(' ')) {
          final parts = timestamps[i].split(' ');
          if (parts.length >= 2) {
            final timePart = parts[1];
            final cleanTime = timePart.split('-')[0].split('+')[0];
            formattedTime = cleanTime;
          }
        }
        expect(formattedTime, equals(expectedTimes[i]));
      }
    });
  });
}

