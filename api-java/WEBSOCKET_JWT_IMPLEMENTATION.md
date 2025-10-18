# Implementação de Validação JWT no WebSocket

## 🔴 Problema Identificado

Atualmente, o endpoint WebSocket `/ws-petdex` **não valida o token JWT** antes de aceitar conexões. Isso permite que qualquer cliente se conecte ao WebSocket sem autenticação, representando um **risco de segurança crítico**.

### Configuração Atual (Insegura)
```java
// WebSocketConfig.java - LINHA 40-42
registry.addEndpoint("/ws-petdex")
        .setAllowedOriginPatterns("*") // ❌ Permite TODAS as origens SEM autenticação
        .withSockJS();
```

## ✅ Solução Recomendada

### 1. Criar um `HandshakeInterceptor` para Validar JWT

```java
package com.petdex.api.infrastructure.websocket;

import com.petdex.api.application.services.security.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * Interceptor que valida o token JWT antes de aceitar a conexão WebSocket
 */
@Component
public class JwtHandshakeInterceptor implements HandshakeInterceptor {

    @Autowired
    private JwtService jwtService;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) {
        try {
            // Tenta obter o token de diferentes fontes:
            // 1. Query parameter: ?token=xxx
            // 2. Header: Authorization: Bearer xxx
            
            String token = null;
            
            // Tenta obter do query parameter
            String query = request.getURI().getQuery();
            if (query != null && query.contains("token=")) {
                token = query.split("token=")[1].split("&")[0];
            }
            
            // Se não encontrou no query parameter, tenta no header
            if (token == null) {
                String authHeader = request.getHeaders().getFirst("Authorization");
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    token = authHeader.substring(7);
                }
            }
            
            // Valida o token
            if (token != null && jwtService.validateToken(token)) {
                String userId = jwtService.extractUserId(token);
                attributes.put("userId", userId);
                return true;
            }
            
            return false;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                               WebSocketHandler wsHandler, Exception exception) {
        // Não precisa fazer nada aqui
    }
}
```

### 2. Atualizar WebSocketConfig para Usar o Interceptor

```java
package com.petdex.api.config;

import com.petdex.api.infrastructure.websocket.JwtHandshakeInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Autowired
    private JwtHandshakeInterceptor jwtHandshakeInterceptor;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws-petdex")
                .addInterceptors(jwtHandshakeInterceptor) // ✅ Adiciona validação JWT
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }
}
```

## 📱 Cliente Flutter - Implementação

O cliente Flutter já foi atualizado para enviar o token JWT:

```dart
// websocket_service.dart
final token = authService.getToken();

String wsUrlWithAuth = wsUrl;
if (token != null && token.isNotEmpty) {
    final separator = wsUrl.contains('?') ? '&' : '?';
    wsUrlWithAuth = '$wsUrl${separator}token=$token';
}

_channel = WebSocketChannel.connect(
    Uri.parse(wsUrlWithAuth),
    protocols: ['v12.stomp', 'v11.stomp', 'v10.stomp'],
);
```

## 🔄 Fluxo de Autenticação WebSocket

1. **Cliente Flutter** → Obtém token JWT do `AuthService`
2. **Cliente Flutter** → Conecta ao WebSocket com token como query parameter
3. **Backend Java** → `JwtHandshakeInterceptor` intercepta a conexão
4. **Backend Java** → Valida o token usando `JwtService`
5. **Backend Java** → Se válido, aceita a conexão; se inválido, rejeita
6. **Backend Java** → Armazena `userId` nos atributos da sessão WebSocket

## ⚠️ Notas Importantes

- O token é enviado como **query parameter** porque `WebSocketChannel.connect()` do Flutter não suporta headers customizados
- Alternativa: Usar **SockJS** que suporta headers (já está configurado com `withSockJS()`)
- O backend deve validar o token **antes** de aceitar a conexão
- Se o token expirar, o cliente deve reconectar com um novo token

## 🧪 Teste de Segurança

Após implementar, teste:

```bash
# ❌ Deve FALHAR (sem token)
wscat -c ws://localhost:8080/ws-petdex/websocket

# ✅ Deve FUNCIONAR (com token válido)
wscat -c "ws://localhost:8080/ws-petdex/websocket?token=SEU_TOKEN_JWT"
```

## 📚 Referências

- Spring WebSocket: https://spring.io/guides/gs/messaging-stomp-websocket/
- JWT Service: `com.petdex.api.application.services.security.JwtService`
- Handshake Interceptor: `org.springframework.web.socket.server.HandshakeInterceptor`

