package com.petdex.api.domain.contracts.dto.especie;

public class EspecieReqDTO {

    private String nome;

    public EspecieReqDTO() {
    }

    public EspecieReqDTO(String nome) {
        this.nome = nome;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }
}
