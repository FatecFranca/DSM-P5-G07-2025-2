package com.petdex.api.application.services.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * Serviço responsável pela geração e validação de tokens JWT
 */
@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secretKey;

    /**
     * Gera a chave secreta para assinar os tokens JWT
     * Garante que a chave tenha pelo menos 256 bits (32 bytes) usando SHA-256
     * @return SecretKey gerada a partir da string configurada
     */
    private SecretKey getSigningKey() {
        try {
            // Usa SHA-256 para garantir que a chave tenha exatamente 256 bits
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] keyBytes = digest.digest(secretKey.getBytes(StandardCharsets.UTF_8));
            return Keys.hmacShaKeyFor(keyBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Erro ao gerar chave de assinatura JWT", e);
        }
    }

    /**
     * Gera um token JWT para um usuário
     * @param userId ID do usuário
     * @param email Email do usuário
     * @return Token JWT gerado
     */
    public String generateToken(String userId, String email) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("email", email);
        return createToken(claims, userId);
    }

    /**
     * Cria o token JWT com as claims fornecidas (sem expiração)
     * @param claims Informações adicionais a serem incluídas no token
     * @param subject Assunto do token (geralmente o ID do usuário)
     * @return Token JWT
     */
    private String createToken(Map<String, Object> claims, String subject) {
        Date now = new Date();

        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(now)
                .signWith(getSigningKey())
                .compact();
    }

    /**
     * Extrai o ID do usuário do token JWT
     * @param token Token JWT
     * @return ID do usuário
     */
    public String extractUserId(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Extrai o email do usuário do token JWT
     * @param token Token JWT
     * @return Email do usuário
     */
    public String extractEmail(String token) {
        return extractClaim(token, claims -> claims.get("email", String.class));
    }



    /**
     * Extrai uma claim específica do token
     * @param token Token JWT
     * @param claimsResolver Função para extrair a claim desejada
     * @return Valor da claim
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Extrai todas as claims do token
     * @param token Token JWT
     * @return Claims do token
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * Valida o token JWT
     * @param token Token JWT
     * @param userId ID do usuário esperado
     * @return true se o token é válido, false caso contrário
     */
    public Boolean validateToken(String token, String userId) {
        try {
            final String extractedUserId = extractUserId(token);
            return extractedUserId.equals(userId);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Valida apenas se o token é válido e bem formado
     * @param token Token JWT
     * @return true se o token é válido, false caso contrário
     */
    public Boolean validateToken(String token) {
        try {
            extractAllClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}

