package com.petdex.api.application.services.auth;

import com.petdex.api.domain.contracts.dto.auth.LoginReqDTO;
import com.petdex.api.domain.contracts.dto.auth.LoginResDTO;

/**
 * Interface para o serviço de autenticação
 */
public interface IAuthService {
    
    /**
     * Realiza o login do usuário
     * @param loginReqDTO Dados de login (email e senha)
     * @return Dados de resposta do login (token JWT e informações do usuário)
     */
    LoginResDTO login(LoginReqDTO loginReqDTO);
}

