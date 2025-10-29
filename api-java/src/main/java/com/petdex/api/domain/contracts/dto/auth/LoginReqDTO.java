package com.petdex.api.domain.contracts.dto.auth;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * DTO para requisição de login
 */
@Schema(
        name = "Requisição Login",
        description = "Credenciais necessárias para autenticação no sistema",
        example = "{\"email\": \"usuario@petdex.com\", \"senha\": \"senha123\"}"
)
public class LoginReqDTO {

    @Schema(description = "Email do usuário para autenticação", example = "usuario@petdex.com", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "Email não pode ser nulo ou vazio")
    @Email(message = "Email deve ser válido")
    private String email;

    @Schema(description = "Senha do usuário para autenticação", example = "senha123", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "Senha não pode ser nula ou vazia")
    private String senha;

    public LoginReqDTO() {
    }

    public LoginReqDTO(String email, String senha) {
        this.email = email;
        this.senha = senha;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }
}

