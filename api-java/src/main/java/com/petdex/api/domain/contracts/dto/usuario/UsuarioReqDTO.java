package com.petdex.api.domain.contracts.dto.usuario;

public class UsuarioReqDTO {

    private String nome;
    private String cpf;
    private String whatsApp;
    private String email;
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
