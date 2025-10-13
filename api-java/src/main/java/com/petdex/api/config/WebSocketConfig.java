package com.petdex.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * Configuração do WebSocket para comunicação em tempo real
 * Permite que clientes se conectem via WebSocket e recebam notificações
 * sobre atualizações de localização e batimentos cardíacos dos animais
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

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
     * - setAllowedOriginPatterns("*"): permite conexões de qualquer origem (sem autenticação)
     */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws-petdex")
                .setAllowedOriginPatterns("*") // Permite todas as origens (sem autenticação)
                .withSockJS(); // Habilita fallback SockJS
    }
}

