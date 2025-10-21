import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Serviço de logging que funciona em builds debug e release
/// Usa dart:developer.log para logging em release builds
class LoggerService {
  static const String _tag = 'PetDex';

  /// Log de informação
  static void info(String message, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      print('ℹ️ [$logTag] $message');
    }
    developer.log(message, name: logTag, level: 800);
  }

  /// Log de sucesso
  static void success(String message, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      print('✅ [$logTag] $message');
    }
    developer.log(message, name: logTag, level: 900);
  }

  /// Log de aviso
  static void warning(String message, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      print('⚠️ [$logTag] $message');
    }
    developer.log(message, name: logTag, level: 700);
  }

  /// Log de erro
  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      print('❌ [$logTag] $message');
      if (error != null) {
        print('   Erro: $error');
      }
      if (stackTrace != null) {
        print('   Stack: $stackTrace');
      }
    }
    developer.log(
      message,
      name: logTag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de debug (apenas em debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      print('🔍 [$logTag] $message');
      developer.log(message, name: logTag, level: 500);
    }
  }

  /// Log de WebSocket
  static void websocket(String message) {
    info(message, tag: 'WebSocket');
  }

  /// Log de conexão
  static void connection(String message) {
    info(message, tag: 'Connection');
  }

  /// Log de erro de conexão
  static void connectionError(String message, {dynamic error, StackTrace? stackTrace}) {
    error(message, tag: 'Connection', error: error, stackTrace: stackTrace);
  }
}

