package com.petdex.api.domain.contracts.dto.usuario;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Requisição Usuário",
        description = "Dados necessários para criar ou atualizar um usuário no sistema",
        example = "{\"nome\": \"João Silva\", \"cpf\": \"12345678900\", \"whatsApp\": \"11987654321\", \"email\": \"usuario@petdex.com\", \"senha\": \"senha123\"}"
)
public class UsuarioReqDTO {

    @Schema(description = "Nome completo do usuário", example = "João Silva", requiredMode = Schema.RequiredMode.REQUIRED)
    private String nome;

    @Schema(description = "CPF do usuário (apenas números)", example = "12345678900", requiredMode = Schema.RequiredMode.REQUIRED)
    private String cpf;

    @Schema(description = "Número de WhatsApp do usuário", example = "11987654321", requiredMode = Schema.RequiredMode.REQUIRED)
    private String whatsApp;

    @Schema(description = "Email do usuário", example = "usuario@petdex.com", requiredMode = Schema.RequiredMode.REQUIRED)
    private String email;

    @Schema(description = "Senha do usuário", example = "senha123", requiredMode = Schema.RequiredMode.REQUIRED)
    private String senha;

    public UsuarioReqDTO() {
    }

    public UsuarioReqDTO(String nome, String cpf, String whatsApp, String email, String senha) {
        this.nome = nome;
        this.cpf = cpf;
        this.whatsApp = whatsApp;
        this.email = email;
        this.senha = senha;
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

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }
}
