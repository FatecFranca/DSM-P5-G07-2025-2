package com.petdex.api.domain.contracts.dto.coleira;

public class ColeiraReqDTO {
    private String descricao;
    private String animal;


    public ColeiraReqDTO() {
    }

    public ColeiraReqDTO(String descricao, String animal) {
        this.descricao = descricao;
        this.animal = animal;
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
