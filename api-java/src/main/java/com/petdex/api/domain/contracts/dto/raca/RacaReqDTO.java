package com.petdex.api.domain.contracts.dto.raca;

public class RacaReqDTO {

    private String nome;
    private String especie;

    public RacaReqDTO() {
    }

    public RacaReqDTO(String nome, String especie) {
        this.nome = nome;
        this.especie = especie;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEspecie() {
        return especie;
    }

    public void setEspecie(String especie) {
        this.especie = especie;
    }
}
