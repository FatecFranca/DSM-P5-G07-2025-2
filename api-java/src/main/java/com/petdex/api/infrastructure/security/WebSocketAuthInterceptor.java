package com.petdex.api.infrastructure.security;

import com.petdex.api.application.services.security.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * Interceptor para autenticação JWT em conexões WebSocket
 * Valida o token JWT presente no header ou query parameter da conexão STOMP
 */
@Component
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    @Autowired
    private JwtService jwtService;

    /**
     * Intercepta mensagens antes de serem enviadas ao canal
     * Valida o token JWT na conexão CONNECT
     */
    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = extractToken(accessor);

            if (token != null) {
                try {
                    if (jwtService.validateToken(token)) {
                        String userId = jwtService.extractUserId(token);

                        if (userId != null) {
                            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                                    userId,
                                    null,
                                    new ArrayList<>()
                            );

                            SecurityContextHolder.getContext().setAuthentication(authToken);
                            accessor.setUser(authToken);
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Erro ao validar token JWT no WebSocket: " + e.getMessage());
                }
            }
        }

        return message;
    }

    /**
     * Extrai o token JWT do header Authorization ou do query parameter
     * @param accessor Accessor do header STOMP
     * @return Token JWT ou null se não encontrado
     */
    private String extractToken(StompHeaderAccessor accessor) {
        // Tenta extrair do header Authorization
        List<String> authHeaders = accessor.getNativeHeader("Authorization");
        if (authHeaders != null && !authHeaders.isEmpty()) {
            String authHeader = authHeaders.get(0);
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                return authHeader.substring(7);
            }
        }

        // Tenta extrair do query parameter 'token'
        List<String> tokenParams = accessor.getNativeHeader("token");
        if (tokenParams != null && !tokenParams.isEmpty()) {
            return tokenParams.get(0);
        }

        return null;
    }
}

