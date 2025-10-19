package com.petdex.api.domain.contracts.dto.usuario;

public class UsuarioResDTO {
    private String id;
    private String nome;
    private String cpf;
    private String whatsApp;
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
