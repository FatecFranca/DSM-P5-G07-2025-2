package com.petdex.api.domain.collections;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "usuarios")
public class Usuario {
    @Id
    private String id;

    @NotBlank(message = "nome não pode ser nulo ou vazio")
    private String nome;

    @Indexed(unique = true)
    @NotBlank(message = "cpf não pode ser nulo ou vazio")
    @Pattern(regexp = "\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}", message = "O CPF deve estar no formato 000.000.000-00")
    private String cpf;

    @Pattern(regexp = "^\\(\\d{2}\\) \\d{5}-\\d{4}$", message = "O número de telefone deve estar no formato (00) 00000-0000")
    @NotBlank(message = "telefone não pode ser nulo ou vazio")
    private String whatsApp;

    @Indexed(unique = true)
    @Email(message = "O e-mail deve ser válido")
    @NotBlank(message = "email não pode ser nulo ou vazio")
    private String email;

    @NotBlank(message = "senha não pode ser nulo ou vazio")
    private String senha;

    public Usuario() {
    }

    public Usuario(String nome, String cpf, String whatsApp, String email, String senha) {
        this.nome = nome;
        this.cpf = cpf;
        this.whatsApp = whatsApp;
        this.email = email;
        this.senha = senha;
    }

    public Usuario(String id, String nome, String cpf, String whatsApp, String email, String senha) {
        this.id = id;
        this.nome = nome;
        this.cpf = cpf;
        this.whatsApp = whatsApp;
        this.email = email;
        this.senha = senha;
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

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }
}
