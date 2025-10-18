package com.petdex.api.application.services.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Serviço responsável pela criptografia e validação de senhas usando BCrypt
 */
@Service
public class PasswordService {

    private final BCryptPasswordEncoder passwordEncoder;

    /**
     * Construtor que inicializa o BCryptPasswordEncoder com a força configurada
     * @param strength Força do algoritmo BCrypt (número de rounds), configurável via variável de ambiente
     */
    public PasswordService(@Value("${bcrypt.salt:10}") int strength) {
        this.passwordEncoder = new BCryptPasswordEncoder(strength);
    }

    /**
     * Criptografa uma senha em texto plano usando BCrypt
     * @param rawPassword Senha em texto plano
     * @return Hash da senha
     */
    public String hashPassword(String rawPassword) {
        if (rawPassword == null || rawPassword.isEmpty()) {
            throw new IllegalArgumentException("A senha não pode ser nula ou vazia");
        }
        return passwordEncoder.encode(rawPassword);
    }

    /**
     * Valida se uma senha em texto plano corresponde ao hash armazenado
     * @param rawPassword Senha em texto plano fornecida pelo usuário
     * @param hashedPassword Hash da senha armazenado no banco de dados
     * @return true se a senha corresponde ao hash, false caso contrário
     */
    public boolean validatePassword(String rawPassword, String hashedPassword) {
        if (rawPassword == null || hashedPassword == null) {
            return false;
        }
        return passwordEncoder.matches(rawPassword, hashedPassword);
    }
}

