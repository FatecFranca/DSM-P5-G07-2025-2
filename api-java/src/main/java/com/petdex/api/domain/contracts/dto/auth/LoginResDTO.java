package com.petdex.api.domain.contracts.dto.auth;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * DTO para resposta de login
 */
@Schema(
        name = "Resposta Login",
        description = "Informações retornadas após autenticação bem-sucedida",
        example = "{\"token\": \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\", \"animalId\": \"507f1f77bcf86cd799439011\", \"userId\": \"507f1f77bcf86cd799439011\", \"nome\": \"João Silva\", \"email\": \"usuario@petdex.com\", \"petName\": \"Rex\"}"
)
public class LoginResDTO {

    @Schema(description = "Token JWT para autenticação nas próximas requisições", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    private String token;

    @Schema(description = "ID do animal associado ao usuário", example = "507f1f77bcf86cd799439011")
    private String animalId;

    @Schema(description = "ID do usuário autenticado", example = "507f1f77bcf86cd799439011")
    private String userId;

    @Schema(description = "Nome do usuário autenticado", example = "João Silva")
    private String nome;

    @Schema(description = "Email do usuário autenticado", example = "usuario@petdex.com")
    private String email;

    @Schema(description = "Nome do animal associado ao usuário", example = "Rex")
    private String petName;

    public LoginResDTO() {
    }

    public LoginResDTO(String token, String animalId, String userId, String nome, String email) {
        this.token = token;
        this.animalId = animalId;
        this.userId = userId;
        this.nome = nome;
        this.email = email;
    }

    public LoginResDTO(String token, String animalId, String userId, String nome, String email, String petName) {
        this.token = token;
        this.animalId = animalId;
        this.userId = userId;
        this.nome = nome;
        this.email = email;
        this.petName = petName;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getAnimalId() {
        return animalId;
    }

    public void setAnimalId(String animalId) {
        this.animalId = animalId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPetName() {
        return petName;
    }

    public void setPetName(String petName) {
        this.petName = petName;
    }
}

