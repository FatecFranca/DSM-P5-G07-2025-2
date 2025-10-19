package com.petdex.api.config;

import com.petdex.api.infrastructure.security.WebSocketAuthInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * Configuração do WebSocket para comunicação em tempo real
 * Permite que clientes se conectem via WebSocket e recebam notificações
 * sobre atualizações de localização e batimentos cardíacos dos animais
 *
 * AUTENTICAÇÃO JWT:
 * - O token pode ser enviado via header Authorization: Bearer <token>
 * - Ou via query parameter: ?token=<token>
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Autowired
    private WebSocketAuthInterceptor webSocketAuthInterceptor;

    /**
     * Configura o message broker para gerenciar as mensagens WebSocket
     * - /topic: prefixo para tópicos de broadcast (um-para-muitos)
     * - /app: prefixo para mensagens destinadas a métodos anotados com @MessageMapping
     */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Habilita um message broker simples em memória
        config.enableSimpleBroker("/topic");

        // Define o prefixo para mensagens destinadas a métodos anotados com @MessageMapping
        config.setApplicationDestinationPrefixes("/app");
    }

    /**
     * Registra os endpoints STOMP sobre WebSocket
     * - /ws-petdex: endpoint principal para conexão WebSocket
     * - SockJS: fallback para navegadores que não suportam WebSocket nativo
     * - setAllowedOriginPatterns("*"): permite conexões de qualquer origem
     */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws-petdex")
                .setAllowedOriginPatterns("*") // Permite todas as origens
                .withSockJS(); // Habilita fallback SockJS
    }

    /**
     * Configura interceptores para o canal de entrada
     * Adiciona o interceptor de autenticação JWT
     */
    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(webSocketAuthInterceptor);
    }
}

