package com.petdex.api.infrastructure.security;

import com.petdex.api.application.services.security.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Filtro de autenticação JWT que intercepta todas as requisições
 * Valida o token JWT presente no header Authorization
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtService jwtService;

    /**
     * Intercepta cada requisição HTTP e valida o token JWT
     * @param request Requisição HTTP
     * @param response Resposta HTTP
     * @param filterChain Cadeia de filtros
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // Log da requisição
        logger.info("=== JWT Filter - Requisição: " + request.getMethod() + " " + request.getRequestURI());

        // Extrai o header Authorization
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userId;

        // Log do header Authorization
        if (authHeader == null) {
            logger.warn("Header Authorization não encontrado");
        } else {
            logger.info("Header Authorization presente: " + authHeader.substring(0, Math.min(20, authHeader.length())) + "...");
        }

        // Se não houver header ou não começar com "Bearer ", continua sem autenticação
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            logger.warn("Token JWT não encontrado ou formato inválido. Continuando sem autenticação.");
            filterChain.doFilter(request, response);
            return;
        }

        // Extrai o token (remove "Bearer " do início)
        jwt = authHeader.substring(7);
        logger.info("Token JWT extraído (primeiros 20 caracteres): " + jwt.substring(0, Math.min(20, jwt.length())) + "...");

        try {
            // Valida o token e extrai o userId
            logger.info("Validando token JWT...");
            if (jwtService.validateToken(jwt)) {
                logger.info("Token JWT válido!");
                userId = jwtService.extractUserId(jwt);
                logger.info("UserId extraído do token: " + userId);

                // Se o token é válido e não há autenticação no contexto
                if (userId != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    // Cria um objeto de autenticação
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userId,
                            null,
                            new ArrayList<>() // Sem roles/authorities por enquanto
                    );

                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    // Define a autenticação no contexto de segurança
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    logger.info("Autenticação estabelecida com sucesso para userId: " + userId);
                } else if (userId == null) {
                    logger.error("UserId extraído é null!");
                } else {
                    logger.info("Autenticação já existe no contexto");
                }
            } else {
                logger.error("Token JWT inválido! Falha na validação.");
            }
        } catch (io.jsonwebtoken.ExpiredJwtException e) {
            logger.error("Token JWT expirado: " + e.getMessage());
            request.setAttribute("jwt_error", "Token JWT expirado");
        } catch (io.jsonwebtoken.MalformedJwtException e) {
            logger.error("Token JWT malformado: " + e.getMessage());
            request.setAttribute("jwt_error", "Token JWT malformado ou inválido");
        } catch (io.jsonwebtoken.security.SignatureException e) {
            logger.error("Assinatura do token JWT inválida: " + e.getMessage());
            request.setAttribute("jwt_error", "Assinatura do token JWT inválida");
        } catch (Exception e) {
            // Token inválido - continua sem autenticação
            logger.error("Erro ao validar token JWT: " + e.getMessage(), e);
            request.setAttribute("jwt_error", "Erro ao validar token JWT: " + e.getMessage());
        }

        // Continua a cadeia de filtros
        logger.info("Continuando cadeia de filtros...");
        filterChain.doFilter(request, response);
    }
}

