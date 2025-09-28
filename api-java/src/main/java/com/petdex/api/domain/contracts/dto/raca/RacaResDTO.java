package com.petdex.api.domain.contracts.dto.raca;

public class RacaResDTO {

    private String id;
    private String nome;
    private String especie;

    public RacaResDTO() {
    }

    public RacaResDTO(String nome, String especie) {
        this.nome = nome;
        this.especie = especie;
    }

    public RacaResDTO(String id, String nome, String especie) {
        this.especie = especie;
        this.nome = nome;
        this.id = id;
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

    public String getespecie() {
        return especie;
    }

    public void setespecie(String especie) {
        this.especie = especie;
    }
}
