package com.petdex.api.view;

import com.petdex.api.application.services.auth.IAuthService;
import com.petdex.api.domain.contracts.dto.auth.LoginReqDTO;
import com.petdex.api.domain.contracts.dto.auth.LoginResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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

    @Operation(
            summary = "Realizar login",
            description = "Autentica um usuário no sistema através de email e senha, retornando um token JWT para acesso às rotas protegidas"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Login realizado com sucesso, token JWT retornado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = LoginResDTO.class))),
            @ApiResponse(responseCode = "401", description = "Credenciais inválidas - email ou senha incorretos",
                    content = @Content),
            @ApiResponse(responseCode = "400", description = "Dados inválidos fornecidos na requisição",
                    content = @Content),
            @ApiResponse(responseCode = "500", description = "Erro interno do servidor",
                    content = @Content)
    })
    @PostMapping("/login")
    public ResponseEntity<LoginResDTO> login(@Valid @RequestBody LoginReqDTO loginReqDTO) {
        try {
            LoginResDTO response = authService.login(loginReqDTO);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
}

