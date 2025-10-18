package com.petdex.api.domain.contracts.dto.auth;

/**
 * DTO para resposta de login
 */
public class LoginResDTO {

    private String token;
    private String animalId;
    private String userId;
    private String nome;
    private String email;
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

