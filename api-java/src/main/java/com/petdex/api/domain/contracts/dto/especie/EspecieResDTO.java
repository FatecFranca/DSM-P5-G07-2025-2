package com.petdex.api.domain.contracts.dto.especie;

public class EspecieResDTO {

    private String id;
    private String nome;

    public EspecieResDTO() {
    }

    public EspecieResDTO(String nome) {
        this.nome = nome;
    }

    public EspecieResDTO(String id, String nome) {
        this.id = id;
        this.nome = nome;
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
}
