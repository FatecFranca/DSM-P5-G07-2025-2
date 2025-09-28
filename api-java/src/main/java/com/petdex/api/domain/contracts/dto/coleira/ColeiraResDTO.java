package com.petdex.api.domain.contracts.dto.coleira;

public class ColeiraResDTO {
    private String id;
    private String descricao;
    private String animal;


    public ColeiraResDTO() {
    }

    public ColeiraResDTO(String descricao, String animal) {
        this.descricao = descricao;
        this.animal = animal;
    }

    public ColeiraResDTO(String id, String descricao, String animal) {
        this.id = id;
        this.descricao = descricao;
        this.animal = animal;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getAnimal() {
        return animal;
    }

    public void setAnimal(String animal) {
        this.animal = animal;
    }
}
