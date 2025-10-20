# ProGuard rules for PetDex WebSocket and critical functionality
# Protege classes essenciais de serem ofuscadas ou removidas

# ============================================================================
# WebSocket Channel - CRÍTICO
# ============================================================================
-keep class io.flutter.** { *; }
-keep class com.google.dart.** { *; }

# Protege a biblioteca web_socket_channel
-keep class com.example.web_socket_channel.** { *; }
-keep interface com.example.web_socket_channel.** { *; }

# Protege classes de WebSocket nativas
-keep class java.net.Socket { *; }
-keep class java.net.ServerSocket { *; }
-keep class javax.net.ssl.SSLSocket { *; }
-keep class javax.net.ssl.SSLContext { *; }
-keep class javax.net.ssl.SSLSocketFactory { *; }

# ============================================================================
# Dart/Flutter Runtime - CRÍTICO
# ============================================================================
-keep class dart.** { *; }
-keep interface dart.** { *; }
-keep class com.google.dart.** { *; }
-keep interface com.google.dart.** { *; }

# ============================================================================
# Reflection - Necessário para serialização JSON
# ============================================================================
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes LocalVariableTable,LocalVariableTypeTable

# ============================================================================
# Modelos de dados (JSON serialization)
# ============================================================================
-keep class com.example.mobile.models.** { *; }
-keep class com.example.mobile.services.** { *; }

# ============================================================================
# Enums - Necessários para serialização
# ============================================================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ============================================================================
# Métodos nativos
# ============================================================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================================================
# Construtores de classes que usam reflexão
# ============================================================================
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# ============================================================================
# Callbacks e listeners
# ============================================================================
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ============================================================================
# Google Play Core - Necessário para Flutter
# ============================================================================
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ============================================================================
# Notificações - CRÍTICO para alertas de área segura
# ============================================================================
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationCompat$* { *; }
-keep class android.app.Notification { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationChannelGroup { *; }
-keep class com.google.android.material.notification.** { *; }

# Flutter Local Notifications Plugin
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep interface com.dexterous.flutterlocalnotifications.** { *; }

# ============================================================================
# Logging - Manter para debug
# ============================================================================
-keep class android.util.Log { *; }

# ============================================================================
# Otimizações seguras
# ============================================================================
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Remover logging em release (comentado para manter debug)
# -assumenosideeffects class android.util.Log {
#     public static *** d(...);
#     public static *** v(...);
#     public static *** i(...);
# }

# ============================================================================
# Manter nomes de classes para debugging
# ============================================================================
-keepnames class * { *; }
-keepnames interface * { *; }

