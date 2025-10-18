package com.petdex.api.view;

import com.petdex.api.application.services.auth.IAuthService;
import com.petdex.api.domain.contracts.dto.auth.LoginReqDTO;
import com.petdex.api.domain.contracts.dto.auth.LoginResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller responsável pelos endpoints de autenticação
 */
@RestController
@RequestMapping("/auth")
@Tag(name = "Autenticação", description = "Operações de autenticação e login")
public class AuthController {

    @Autowired
    private IAuthService authService;

    /**
     * Endpoint de login
     * @param loginReqDTO Dados de login (email e senha)
     * @return Token JWT e informações do usuário autenticado
     */
    @PostMapping("/login")
    @Operation(summary = "Realizar login", description = "Autentica um usuário e retorna um token JWT")
    public ResponseEntity<LoginResDTO> login(@Valid @RequestBody LoginReqDTO loginReqDTO) {
        try {
            LoginResDTO response = authService.login(loginReqDTO);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
}

