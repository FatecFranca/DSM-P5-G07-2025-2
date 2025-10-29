package com.petdex.api.domain.contracts.dto.usuario;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Resposta Usuário",
        description = "Informações detalhadas de um usuário retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"nome\": \"João Silva\", \"cpf\": \"12345678900\", \"whatsApp\": \"11987654321\", \"email\": \"usuario@petdex.com\"}"
)
public class UsuarioResDTO {

    @Schema(description = "Código único identificador do usuário", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Nome completo do usuário", example = "João Silva")
    private String nome;

    @Schema(description = "CPF do usuário (apenas números)", example = "12345678900")
    private String cpf;

    @Schema(description = "Número de WhatsApp do usuário", example = "11987654321")
    private String whatsApp;

    @Schema(description = "Email do usuário", example = "usuario@petdex.com")
    private String email;

    public UsuarioResDTO() {
    }

    public UsuarioResDTO(String nome, String cpf, String whatsApp, String email) {
        this.nome = nome;
        this.cpf = cpf;
        this.whatsApp = whatsApp;
        this.email = email;
    }

    public UsuarioResDTO(String id, String nome, String cpf, String whatsApp, String email) {
        this.id = id;
        this.nome = nome;
        this.cpf = cpf;
        this.whatsApp = whatsApp;
        this.email = email;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getWhatsApp() {
        return whatsApp;
    }

    public void setWhatsApp(String whatsApp) {
        this.whatsApp = whatsApp;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
